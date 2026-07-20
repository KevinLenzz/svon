///|
/// ## Core reactive runtime
///
/// Implements the Svelte-5-compatible signal graph: automatic dependency
/// tracking, three-state dirtiness propagation (DIRTY → MAYBE_DIRTY → CLEAN),
/// batched effect flushing, and version-number-based staleness detection.
///
/// All state is held in a single global `Runtime` instance `rt`.
/// Signals are stored in a growable `Array[Reaction]` and referenced by
/// integer index throughout — this avoids the need for reference counting
/// or cyclic pointers in MoonBit.

///|
/// Global runtime state.  All fields are mutable; only `rt` is the
/// canonical instance (module-level `let` binding).
pub(all) struct Runtime {
  /// Registry of all Reaction nodes, indexed by integer ID.
  mut reactions : Array[Reaction]
  /// The reaction currently being tracked (set during `run_reaction`).
  /// `none_index` when no reaction is executing.
  mut active_reaction : Int
  /// The currently-executing effect (set during `do_update_effect`).
  /// Used to detect self-invalidation (`self_dirty`).
  mut active_effect : Int
  /// Monotonically-increasing counter. Incremented on every source write
  /// and derived recomputation. Used for version-number dirty-checking.
  mut write_version : Int
  /// Monotonically-increasing counter. Incremented at the start of each
  /// reaction execution. Used by `track_dep` to deduplicate dependency
  /// registrations within a single reaction run.
  mut read_version : Int
  /// When `true`, `track_dep` does NOT register dependencies.
  /// Toggled by `untrack()`.
  mut untracking : Bool
  /// Newly-discovered dependencies during the current reaction execution.
  /// Replaces `deps` on the reaction at the end of `run_reaction`.
  mut new_deps : Array[Int]
  /// Number of leading dependencies that are unchanged from the previous
  /// execution. Enables O(k) dep rebuild (only swap out changed deps).
  mut skipped_deps : Int
  /// Signals written during the current reaction that were NOT tracked
  /// (written inside `untrack` blocks). After the reaction completes,
  /// these are checked for self-invalidation.
  mut untracked_writes : Array[Int]
  /// Maps reaction ID → Effect struct. Used by `flush_pending` to
  /// look up the effect body for re-execution.
  mut effect_map : Map[Int, Effect]
  /// Queue of effect IDs that need to be re-executed. Populated by
  /// `mark_reactions`; drained by `flush_pending`.
  mut pending_updates : Array[Int]
  /// Set to `true` when a derived dependency of the currently-running
  /// effect is recomputed. After the effect body finishes, the effect
  /// is re-pushed to `pending_updates` so it runs again with fresh values.
  mut self_dirty : Bool
  /// Maps reaction ID → recompute closure. Each derived registers a
  /// `() -> Unit` closure that calls `update_derived` on itself.
  /// Called eagerly by `is_dirty` — matches Svelte's pattern.
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

/// Global singleton — one Reactive graph per application.
let rt : Runtime = Runtime::default()

///|
/// ## Registry helpers — read/write Reaction nodes in the global Array

/// Push a Reaction to the registry and return its index.
fn register(r : Reaction) -> Int {
  rt.reactions.push(r)
  rt.reactions.length() - 1
}

/// Read a Reaction at index (returns a copy — mutations must be written back).
fn reaction_at(id : Int) -> Reaction {
  rt.reactions[id]
}

/// Write a Reaction back to the registry after mutation.
fn set_reaction_at(id : Int, r : Reaction) -> Unit {
  rt.reactions[id] = r
}

///|
/// Clear the cleanliness bits from `f` and OR in the new status.
/// Bits outside the cleanliness range (type flags, lifecycle flags)
/// are preserved.
fn set_status(id : Int, status : Int) -> Unit {
  let r = reaction_at(id)
  r.f = r.f.land(status_mask).lor(status)
  set_reaction_at(id, r)
}

/// Create a fresh Reaction node with the given type flags.
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

///|
/// ## Effect tree helpers

/// Insert `child_id` as the last child of `parent_id` in the doubly-linked
/// sibling list. Effects form a tree so that destroying a BRANCH effect
/// automatically destroys all its children.
fn link_child(parent_id : Int, child_id : Int) -> Unit {
  if parent_id != none_index {
    let p = reaction_at(parent_id)
    if p.last == none_index {
      // first child
      p.first = child_id
      p.last = child_id
    } else {
      // append to end of sibling list
      let prev = reaction_at(p.last)
      prev.next = child_id
      set_reaction_at(p.last, prev)
      p.last = child_id
    }
    set_reaction_at(parent_id, p)
  }
}

///|
/// ## Signal constructors — create Source / Derived / Effect

/// Create a writable Source signal. No type flags are set.
fn[T] new_source(v : T, eq : (T, T) -> Bool) -> Source[T] {
  let r = make_reaction(0)
  let id = register(r)
  { id, v, eq }
}

/// Create a Derived signal. Starts as DIRTY so it computes on first read.
/// Registers a recompute closure in `derived_map` so `is_dirty` can
/// eagerly recompute it when checking downstream effects.
fn[T] new_derived(compute : () -> T) -> Derived[T] {
  let f = flag_derived.lor(flag_dirty)
  let r = make_reaction(f)
  r.parent = rt.active_effect  // derived inherits parent from creating effect
  let id = register(r)
  let d : Derived[T] = { id, v: compute(), compute }
  // Wire up recompute so is_dirty can call update_derived directly
  rt.derived_map[id] = fn() { update_derived(d) }
  d
}

/// Create an Effect. Links into the parent's child list.
/// Runs immediately (`do_update_effect`) to capture initial dependencies.
fn new_effect(run : () -> (() -> Unit)?) -> Effect {
  let f = flag_effect.lor(flag_dirty).lor(flag_clean)
  let parent = rt.active_effect
  let r = make_reaction(f)
  r.parent = parent
  let id = register(r)
  link_child(parent, id)
  let e : Effect = { id, run }
  rt.effect_map[id] = e
  do_update_effect(id, e)  // run immediately to register deps
  e
}

///|
/// ## Dependency tracking — called on every signal read

/// Register the signal at `id` as a dependency of the currently-executing
/// reaction (`rt.active_reaction`). Uses `rv` (read-version) to avoid
/// registering the same signal twice within a single reaction execution.
///
/// The `skipped_deps` optimisation: if the current dep matches the old
/// dep at the same position, we just increment a counter instead of
/// allocating a new array. At the end of `run_reaction`, the deps array
/// is rebuilt by keeping old `[0..skipped) + new[0..]`.
fn track_dep(id : Int) -> Unit {
  let r = reaction_at(id)
  // Only track if we're inside a reaction and not suppressing tracking
  if rt.active_reaction != none_index && !rt.untracking {
    let active_id = rt.active_reaction
    // Dedup: skip if this signal was already seen in this reaction run
    if r.rv < rt.read_version {
      let updated = r
      updated.rv = rt.read_version
      set_reaction_at(id, updated)
      let active = reaction_at(active_id)
      // skipped_deps optimisation: if the dep at the expected position
      // matches, just bump the counter without pushing to new_deps
      if active.deps.length() > rt.skipped_deps && active.deps[rt.skipped_deps] == id {
        rt.skipped_deps = rt.skipped_deps + 1
      } else {
        rt.new_deps.push(id)
      }
      // Add active reaction to this signal's reactions list (bidirectional link)
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

///|
/// ## Write propagation — source → derived → effect

/// Set a Source's value. If the value actually changed (per `eq`),
/// increments `write_version`, updates the source's `wv`, and propagates
/// dirtiness through the graph via `mark_reactions`. Then flushes
/// any effects that were scheduled.
fn[T] set_source_value(s : Source[T], value : T) -> Unit {
  // Short-circuit if the value hasn't changed
  if (s.eq)(s.v, value) {
    return
  }
  s.v = value
  rt.write_version = rt.write_version + 1
  let r = reaction_at(s.id)
  r.wv = rt.write_version
  set_reaction_at(s.id, r)
  // Create a fresh pending_updates array for this write cycle
  rt.pending_updates = Array::new(capacity=0)
  mark_reactions(s.id, flag_dirty)
  flush_pending()
}

/// Recursively walk the dependency graph starting from `id`, marking all
/// downstream reactions with the given `status`.
///
/// * Sources → mark reactions DIRTY
/// * Deriveds → recursively mark reactions MAYBE_DIRTY (lazy check)
/// * Effects → push to `pending_updates` (or set `self_dirty` if it's
///   the currently-executing effect)
///
/// Uses the `flags` snapshot pattern: reads `react.f` BEFORE calling
/// `set_status` so that the downstream check (`flags.land(flag_dirty) == 0`)
/// works correctly regardless of status changes.
fn mark_reactions(id : Int, status : Int) -> Unit {
  let r = reaction_at(id)
  let list = r.reactions
  for i in 0..<list.length() {
    let rid = list[i]
    let react = reaction_at(rid)
    // Snapshot flags BEFORE any set_status call
    let flags = react.f
    // Only mark if not already dirty (prevents redundant work)
    if flags.land(flag_dirty) == 0 {
      set_status(rid, status)
    }
    if flags.land(flag_derived) != 0 {
      // Derived: recursively mark its dependents as MAYBE_DIRTY.
      // They'll be lazily checked when read (is_dirty -> compare wv).
      mark_reactions(rid, flag_maybe_dirty)
    } else if flags.land(flag_dirty) == 0 && flags.land(flag_block_effect) == 0 {
      // Effect: schedule for re-execution.
      // If it's the currently-running effect, set self_dirty flag
      // instead — it'll be re-scheduled after the current run finishes.
      if rid == rt.active_effect {
        rt.self_dirty = true
      } else {
        rt.pending_updates.push(rid)
      }
    }
  }
}

///|
/// ## Dirtiness checking — three-state + version numbers + eager recompute

/// Check whether a reaction needs re-evaluation.
///
/// Three states:
/// * DIRTY → immediately true (was explicitly marked)
/// * MAYBE_DIRTY → recursively check each dependency:
///   - If the dep is a dirty derived, eagerly recompute it first
///     (increments its `wv` so the version comparison below works)
///   - Then compare `dep.wv > reaction.wv` — if any dep has been
///     updated since this reaction last ran, it's dirty
/// * CLEAN → immediately false
///
/// Matches Svelte's `is_dirty` exactly: recursively checks derived
/// dependencies and calls `update_derived` on dirty ones so that
/// downstream effects can detect the change via `dep.wv > reaction.wv`.
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
      // If the dependency is a derived that IS dirty, recompute it first.
      // This matches Svelte's: if (is_dirty(dependency)) update_derived(dependency)
      if dep.f.land(flag_derived) != 0 {
        if is_dirty(dep_id) {
          eager_recompute_derived(dep_id)
        }
      }
      // Now compare write-version numbers.
      // After recompute, dep.wv > r.wv will be true if dep was actually stale.
      let dep2 = reaction_at(dep_id)
      if dep2.wv > r.wv {
        return true
      }
    }
    // All deps are up-to-date — mark as clean
    set_status(id, flag_clean)
  }
  false
}

/// Look up the derived's recompute closure and call it.
/// The closure was registered in `new_derived` via `rt.derived_map[id]`.
fn eager_recompute_derived(id : Int) -> Unit {
  match rt.derived_map.get(id) {
    Option::Some(rc) => (rc)()
    Option::None => ()
  }
}

///|
/// ## Reaction execution — run a derived or effect body with tracking

/// Enter a tracking context for reaction `id`, execute `body`, then
/// rebuild the reaction's dependency list.
///
/// During `body()`, any `track_dep` calls will register dependencies
/// because `rt.active_reaction` is set.
///
/// After `body()` finishes:
/// 1. Rebuild `deps` by merging `old[0..skipped] + new[0..]`
/// 2. Check `untracked_writes` for self-invalidation (writes inside
///    `untrack()` blocks that might make this reaction stale)
fn run_reaction(id : Int, body : () -> Unit) -> Unit {
  // Save current tracking state on the stack (allows nesting)
  let prev_active = rt.active_reaction
  let prev_new = rt.new_deps
  let prev_skipped = rt.skipped_deps
  let prev_untracked = rt.untracked_writes
  let prev_untracking = rt.untracking
  let flags = reaction_at(id).f
  // Branch/root effects don't set themselves as active_reaction —
  // their children do the tracking
  let is_branch = flags.land(flag_branch_effect.lor(flag_root_effect)) != 0

  // Set up fresh tracking context
  rt.active_reaction = if is_branch { none_index } else { id }
  rt.new_deps = Array::new(capacity=0)
  rt.skipped_deps = 0
  rt.untracked_writes = Array::new(capacity=0)
  rt.untracking = false
  rt.read_version = rt.read_version + 1

  // Execute the reaction body — track_dep calls inside will populate new_deps
  body()

  // Rebuild dependency list
  let r2 = reaction_at(id)
  let old = r2.deps
  let nd = rt.new_deps
  let nd_len = nd.length()
  if old.length() > 0 && rt.skipped_deps > 0 {
    // Keep unchanged leading deps, append new deps after
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

  // Check for untracked writes that might self-invalidate this reaction
  let writes = rt.untracked_writes
  if !rt.untracking && r2.deps.length() > 0 {
    for i in 0..<writes.length() {
      propagate_self(writes[i], id)
    }
  }

  // Restore saved state — supports nested reaction execution
  rt.active_reaction = prev_active
  rt.new_deps = prev_new
  rt.skipped_deps = prev_skipped
  rt.untracked_writes = prev_untracked
  rt.untracking = prev_untracking
}

/// Walk the derived chain from `signal_id` to see if `effect_id` is
/// downstream. If so, mark the effect DIRTY — the write inside `untrack`
/// invalidated this effect.
fn propagate_self(signal_id : Int, effect_id : Int) -> Unit {
  let r = reaction_at(signal_id)
  for i in 0..<r.reactions.length() {
    let rid = r.reactions[i]
    let react = reaction_at(rid)
    if react.f.land(flag_derived) != 0 {
      // Follow through deriveds transitively
      propagate_self(rid, effect_id)
    } else if rid == effect_id {
      // Found the effect — mark it dirty
      set_status(effect_id, flag_dirty)
    }
  }
}

///|
/// ## Derived recomputation

/// Recompute a Derived value. Called lazily when `is_dirty` returns true
/// (from `get_derived`), or eagerly from `is_dirty` when checking
/// downstream effects.
///
/// 1. Compute the new value (outside the tracking context)
/// 2. Run `run_reaction` to rebuild the derived's own dependency list
/// 3. Update the struct value and reaction's `wv`
/// 4. Mark downstream reactions dirty
fn[T] update_derived(d : Derived[T]) -> Unit {
  // Compute first (outside tracking — avoids capturing d in a closure)
  let new_val = (d.compute)()
  // Re-run inside tracking context to rebuild deps
  run_reaction(d.id, fn() { let _ = (d.compute)() })
  d.v = new_val
  rt.write_version = rt.write_version + 1
  let r = reaction_at(d.id)
  r.wv = rt.write_version
  set_reaction_at(d.id, r)
  set_status(d.id, flag_clean)
  // Propagate to downstream reactions
  mark_reactions(d.id, flag_dirty)
}

///|
/// ## Effect execution

/// Execute or re-execute an effect.
///
/// 1. Skip if destroyed or not dirty
/// 2. Set CLEAN, destroy child effects, reset self_dirty
/// 3. Run the effect body inside a tracking context
/// 4. Update write-version
/// 5. If the effect self-invalidated (a derived it read was recomputed
///    during its execution), re-push to pending_updates so it runs again
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
  destroy_children(id)  // tear down any nested effects from previous run
  rt.self_dirty = false
  run_reaction(id, fn() { let _ = (e.run)() })
  let r2 = reaction_at(id)
  r2.wv = rt.write_version
  set_reaction_at(id, r2)
  rt.active_effect = prev_effect
  // If a derived dependency was recomputed during execution,
  // re-schedule this effect so it sees the fresh value
  if rt.self_dirty {
    rt.self_dirty = false
    rt.pending_updates.push(id)
  }
}

///|
/// ## Effect tree destruction

/// Recursively destroy all child effects of a reaction.
/// Walks the `first→next` sibling chain.
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

/// Unlink a single effect from its parent's doubly-linked sibling list,
/// recursively destroy its children, and mark it DESTROYED.
fn destroy_single(id : Int) -> Unit {
  let r = reaction_at(id)
  destroy_children(id)
  // Unlink from parent
  let parent = r.parent
  if parent != none_index {
    let p = reaction_at(parent)
    if p.first == id { p.first = r.next }
    if p.last == id { p.last = r.prev }
    set_reaction_at(parent, p)
  }
  // Unlink from previous sibling
  if r.prev != none_index {
    let prev = reaction_at(r.prev)
    prev.next = r.next
    set_reaction_at(r.prev, prev)
  }
  // Unlink from next sibling
  if r.next != none_index {
    let next = reaction_at(r.next)
    next.prev = r.prev
    set_reaction_at(r.next, next)
  }
  // Clear links and mark destroyed
  let rr = reaction_at(id)
  rr.next = none_index
  rr.prev = none_index
  rr.deps = Array::new(capacity=0)
  rr.f = rr.f.lor(flag_destroyed)
  set_reaction_at(id, rr)
}

///|
/// ## Signal read helpers — called from the public API facade

/// Read a Source's value. Registers the active reaction as a dependency.
fn[T] get_source(s : Source[T]) -> T {
  track_dep(s.id)
  s.v
}

/// Read a Derived's value. Lazily recomputes if dirty.
fn[T] get_derived(d : Derived[T]) -> T {
  if is_dirty(d.id) {
    update_derived(d)
  }
  track_dep(d.id)
  d.v
}

///|
/// ## Utility

/// Temporarily suppress dependency tracking during `body()`.
/// Any signal reads inside will NOT be registered as dependencies.
fn[T] do_untrack(body : () -> T) -> T {
  let prev = rt.untracking
  rt.untracking = true
  let result = body()
  rt.untracking = prev
  result
}

///|
/// ## Batch flushing — drain the pending_updates queue

/// Process all effects in `rt.pending_updates`. Uses a `while` loop
/// that re-checks `.length()` each iteration, so effects that re-push
/// themselves (via `self_dirty`) are processed in the same flush cycle.
/// No dedup — `is_dirty` inside `do_update_effect` prevents redundant
/// executions.
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
