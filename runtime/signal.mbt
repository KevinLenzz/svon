///|
/// Source is a writable reactive signal — Svelte's `$state(v)`.
///
/// Writing to a source increments its `wv` and marks all dependent
/// reactions (deriveds + effects) as DIRTY or MAYBE_DIRTY.
///
/// ## Fields
/// * `id`  — index of the Reaction node in the global registry
/// * `v`   — current value (mutable, read via `.get()`/`read_source()`)
/// * `eq`  — equality function; write is skipped if `eq(old, new)` is true
pub(all) struct Source[T] {
  id : Int
  mut v : T
  eq : (T, T) -> Bool
}

///|
/// Derived is a read-only computed signal — Svelte's `$derived(fn)`.
///
/// It lazily recomputes when any of its dependencies change.
/// The `is_dirty()` check walks the dep list and compares version
/// numbers; if a source's `wv` is newer than the derived's `wv`,
/// re-computation is triggered.
///
/// ## Fields
/// * `id`      — index of the owning Reaction node
/// * `v`       — cached computed value (mutable)
/// * `compute` — closure that reads source signals and returns a value
pub(all) struct Derived[T] {
  id : Int
  mut v : T
  compute : () -> T
}

///|
/// Effect is a reactive side-effect — Svelte's `$effect(fn)`.
///
/// When created it runs immediately to capture its dependencies.
/// Whenever any dependency changes, the effect is marked dirty and
/// re-scheduled for execution via the batch flush.
///
/// ## Fields
/// * `id`  — index of the owning Reaction node
/// * `run` — effect body; returns `Option::None` (no cleanup) or
///           `Option::Some(cleanup_fn)` to run before next execution
pub(all) struct Effect {
  id : Int
  run : () -> (() -> Unit)?
}
