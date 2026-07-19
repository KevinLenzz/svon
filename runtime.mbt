///|
/// Core reactive runtime — dependency tracking, dirtiness propagation,
/// and reaction execution.
pub(all) struct Runtime {
  mut reactions : Array[Reaction]
  mut active_reaction : Int
  mut active_effect : Int
  mut write_version : Int
  mut read_version : Int
  mut untracking : Bool
  mut new_deps : Array[Int]
  mut skipped_deps : Int
  mut untracked_writes : Array[Int]
  mut effect_map : Map[Int, Effect]
  mut pending_updates : Array[Int]
  mut self_dirty : Bool
  mut derived_map : Map[Int, () -> Unit]
}

fn Runtime::default() -> Runtime {
  {
    reactions: Array::new(capacity=0),
    active_reaction: none_index,
    active_effect: none_index,
    write_version: 0,
    read_version: 0,
    untracking: false,
    new_deps: Array::new(capacity=0),
    skipped_deps: 0,
    untracked_writes: Array::new(capacity=0),
    effect_map: Map([]),
    pending_updates: Array::new(capacity=0),
    self_dirty: false,
    derived_map: Map([]),
  }
}

let rt : Runtime = Runtime::default()

fn register(r : Reaction) -> Int {
  rt.reactions.push(r)
  rt.reactions.length() - 1
}

fn reaction_at(id : Int) -> Reaction {
  rt.reactions[id]
}

fn set_reaction_at(id : Int, r : Reaction) -> Unit {
  rt.reactions[id] = r
}

fn set_status(id : Int, status : Int) -> Unit {
  let r = reaction_at(id)
  r.f = r.f.land(status_mask).lor(status)
  set_reaction_at(id, r)
}

fn make_reaction(flags : Int) -> Reaction {
  {
    f: flags,
    deps: Array::new(capacity=0),
    reactions: Array::new(capacity=0),
    wv: 0,
    rv: 0,
    parent: none_index,
    first: none_index,
    last: none_index,
    next: none_index,
    prev: none_index,
    effects: Array::new(capacity=0),
  }
}

fn link_child(parent_id : Int, child_id : Int) -> Unit {
  if parent_id != none_index {
    let p = reaction_at(parent_id)
    if p.last == none_index {
      p.first = child_id
      p.last = child_id
    } else {
      let prev = reaction_at(p.last)
      prev.next = child_id
      set_reaction_at(p.last, prev)
      p.last = child_id
    }
    set_reaction_at(parent_id, p)
  }
}

fn[T] new_source(v : T, eq : (T, T) -> Bool) -> Source[T] {
  let r = make_reaction(0)
  let id = register(r)
  { id, v, eq }
}

fn[T] new_derived(compute : () -> T) -> Derived[T] {
  let f = flag_derived.lor(flag_dirty)
  let r = make_reaction(f)
  r.parent = rt.active_effect
  let id = register(r)
  let d : Derived[T] = { id, v: compute(), compute }
  rt.derived_map[id] = fn() { update_derived(d) }
  d
}

fn new_effect(run : () -> (() -> Unit)?) -> Effect {
  let f = flag_effect.lor(flag_dirty).lor(flag_clean)
  let parent = rt.active_effect
  let r = make_reaction(f)
  r.parent = parent
  let id = register(r)
  link_child(parent, id)
  let e : Effect = { id, run }
  rt.effect_map[id] = e
  do_update_effect(id, e)
  e
}

fn track_dep(id : Int) -> Unit {
  let r = reaction_at(id)
  if rt.active_reaction != none_index && !rt.untracking {
    let active_id = rt.active_reaction
    if r.rv < rt.read_version {
      let updated = r
      updated.rv = rt.read_version
      set_reaction_at(id, updated)
      let active = reaction_at(active_id)
      if active.deps.length() > rt.skipped_deps && active.deps[rt.skipped_deps] == id {
        rt.skipped_deps = rt.skipped_deps + 1
      } else {
        rt.new_deps.push(id)
      }
      let sig = reaction_at(id)
      let mut found = false
      for i in 0..<sig.reactions.length() {
        if sig.reactions[i] == active_id {
          found = true
          break
        }
      }
      if !found {
        sig.reactions.push(active_id)
        set_reaction_at(id, sig)
      }
    }
  }
}

fn[T] set_source_value(s : Source[T], value : T) -> Unit {
  if (s.eq)(s.v, value) {
    return
  }
  s.v = value
  rt.write_version = rt.write_version + 1
  let r = reaction_at(s.id)
  r.wv = rt.write_version
  set_reaction_at(s.id, r)
  rt.pending_updates = Array::new(capacity=0)
  mark_reactions(s.id, flag_dirty)
  flush_pending()
}

fn mark_reactions(id : Int, status : Int) -> Unit {
  let r = reaction_at(id)
  let list = r.reactions
  for i in 0..<list.length() {
    let rid = list[i]
    let react = reaction_at(rid)
    let flags = react.f
    if flags.land(flag_dirty) == 0 {
      set_status(rid, status)
    }
    if flags.land(flag_derived) != 0 {
      mark_reactions(rid, flag_maybe_dirty)
    } else if flags.land(flag_dirty) == 0 && flags.land(flag_block_effect) == 0 {
      if rid == rt.active_effect {
        rt.self_dirty = true
      } else {
        rt.pending_updates.push(rid)
      }
    }
  }
}

///|
/// Check if a reaction needs re-evaluation.
/// Matches Svelte's `is_dirty`: recursively checks derived dependencies
/// and eagerly recomputes them so that `dep.wv > reaction.wv` correctly
/// detects the change.
fn is_dirty(id : Int) -> Bool {
  let r = reaction_at(id)
  let flags = r.f
  if flags.land(flag_dirty) != 0 {
    return true
  }
  if flags.land(flag_maybe_dirty) != 0 {
    let deps = r.deps
    for i in 0..<deps.length() {
      let dep_id = deps[i]
      let dep = reaction_at(dep_id)
      if dep.f.land(flag_derived) != 0 {
        if is_dirty(dep_id) {
          eager_recompute_derived(dep_id)
        }
      }
      let dep2 = reaction_at(dep_id)
      if dep2.wv > r.wv {
        return true
      }
    }
    set_status(id, flag_clean)
  }
  false
}

///|
/// Eagerly recompute a derived. Called from `is_dirty` when a derived
/// dependency is found to be dirty — matches Svelte's
/// `update_derived(dependency)` call inside `is_dirty`.
fn eager_recompute_derived(id : Int) -> Unit {
  match rt.derived_map.get(id) {
    Option::Some(rc) => (rc)()
    Option::None => ()
  }
}

fn run_reaction(id : Int, body : () -> Unit) -> Unit {
  let prev_active = rt.active_reaction
  let prev_new = rt.new_deps
  let prev_skipped = rt.skipped_deps
  let prev_untracked = rt.untracked_writes
  let prev_untracking = rt.untracking
  let flags = reaction_at(id).f
  let is_branch = flags.land(flag_branch_effect.lor(flag_root_effect)) != 0

  rt.active_reaction = if is_branch { none_index } else { id }
  rt.new_deps = Array::new(capacity=0)
  rt.skipped_deps = 0
  rt.untracked_writes = Array::new(capacity=0)
  rt.untracking = false
  rt.read_version = rt.read_version + 1

  body()

  let r2 = reaction_at(id)
  let old = r2.deps
  let nd = rt.new_deps
  let nd_len = nd.length()
  if old.length() > 0 && rt.skipped_deps > 0 {
    let merged = Array::new(capacity=rt.skipped_deps + nd_len)
    for i in 0..<rt.skipped_deps {
      merged.push(old[i])
    }
    for i in 0..<nd_len {
      merged.push(nd[i])
    }
    r2.deps = merged
  } else {
    r2.deps = nd
  }
  set_reaction_at(id, r2)

  let writes = rt.untracked_writes
  if !rt.untracking && r2.deps.length() > 0 {
    for i in 0..<writes.length() {
      propagate_self(writes[i], id)
    }
  }

  rt.active_reaction = prev_active
  rt.new_deps = prev_new
  rt.skipped_deps = prev_skipped
  rt.untracked_writes = prev_untracked
  rt.untracking = prev_untracking
}

fn propagate_self(signal_id : Int, effect_id : Int) -> Unit {
  let r = reaction_at(signal_id)
  for i in 0..<r.reactions.length() {
    let rid = r.reactions[i]
    let react = reaction_at(rid)
    if react.f.land(flag_derived) != 0 {
      propagate_self(rid, effect_id)
    } else if rid == effect_id {
      set_status(effect_id, flag_dirty)
    }
  }
}

fn[T] update_derived(d : Derived[T]) -> Unit {
  let new_val = (d.compute)()
  run_reaction(d.id, fn() { let _ = (d.compute)() })
  d.v = new_val
  rt.write_version = rt.write_version + 1
  let r = reaction_at(d.id)
  r.wv = rt.write_version
  set_reaction_at(d.id, r)
  set_status(d.id, flag_clean)
  mark_reactions(d.id, flag_dirty)
}

fn do_update_effect(id : Int, e : Effect) -> Unit {
  let r = reaction_at(id)
  let flags = r.f
  if flags.land(flag_destroyed) != 0 {
    return
  }
  if !is_dirty(id) {
    return
  }
  set_status(id, flag_clean)
  let prev_effect = rt.active_effect
  rt.active_effect = id
  destroy_children(id)
  rt.self_dirty = false
  run_reaction(id, fn() { let _ = (e.run)() })
  let r2 = reaction_at(id)
  r2.wv = rt.write_version
  set_reaction_at(id, r2)
  rt.active_effect = prev_effect
  if rt.self_dirty {
    rt.self_dirty = false
    rt.pending_updates.push(id)
  }
}

fn destroy_children(id : Int) -> Unit {
  let r = reaction_at(id)
  let mut child = r.first
  while child != none_index {
    let c = reaction_at(child)
    let next = c.next
    destroy_single(child)
    child = next
  }
}

fn destroy_single(id : Int) -> Unit {
  let r = reaction_at(id)
  destroy_children(id)
  let parent = r.parent
  if parent != none_index {
    let p = reaction_at(parent)
    if p.first == id {
      p.first = r.next
    }
    if p.last == id {
      p.last = r.prev
    }
    set_reaction_at(parent, p)
  }
  if r.prev != none_index {
    let prev = reaction_at(r.prev)
    prev.next = r.next
    set_reaction_at(r.prev, prev)
  }
  if r.next != none_index {
    let next = reaction_at(r.next)
    next.prev = r.prev
    set_reaction_at(r.next, next)
  }
  let rr = reaction_at(id)
  rr.next = none_index
  rr.prev = none_index
  rr.deps = Array::new(capacity=0)
  rr.f = rr.f.lor(flag_destroyed)
  set_reaction_at(id, rr)
}

fn[T] get_source(s : Source[T]) -> T {
  track_dep(s.id)
  s.v
}

fn[T] get_derived(d : Derived[T]) -> T {
  if is_dirty(d.id) {
    update_derived(d)
  }
  track_dep(d.id)
  d.v
}

fn[T] do_untrack(body : () -> T) -> T {
  let prev = rt.untracking
  rt.untracking = true
  let result = body()
  rt.untracking = prev
  result
}

fn flush_pending() -> Unit {
  let mut i = 0
  while i < rt.pending_updates.length() {
    let id = rt.pending_updates[i]
    i = i + 1
    match rt.effect_map.get(id) {
      Option::Some(ef) => do_update_effect(id, ef)
      Option::None => ()
    }
  }
}
