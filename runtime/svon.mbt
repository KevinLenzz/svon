///|
/// ## Svon — public API facade
///
/// All functions in this file are thin wrappers around package-private
/// implementations in `runtime.mbt`.  External packages (`cmd/*`, `out/*`)
/// use `@svon.source(...)`, `@svon.effect(...)`, etc. to access the
/// reactive system.
///
/// ## Core primitives
/// * `source`   — writable signal (Svelte's `$state`)
/// * `derived`  — computed signal (Svelte's `$derived`)
/// * `effect`   — side-effect signal (Svelte's `$effect`)
///
/// ## Example
///
/// ```mbt check
/// test "counter" {
///   let count = @svon.source(0, fn(a, b) { a == b })
///   let calls = Ref(0)
///   let _e = @svon.effect(fn() {
///     let _ = @svon.read_source(count)
///     calls.val = calls.val + 1
///     Option::None
///   })
///   @svon.write_source(count, 1)
///   @svon.write_source(count, 2)
///   inspect(calls.val, content="3")
/// }
/// ```

///|
/// Create a writable reactive value. Changes propagate to all dependents.
pub fn[T] source(v : T, eq : (T, T) -> Bool) -> Source[T] {
  new_source(v, eq)
}

///|
/// Create a computed reactive value. The compute function's signal reads
/// are automatically tracked; it lazily recomputes when deps change.
pub fn[T] derived(compute : () -> T) -> Derived[T] {
  new_derived(compute)
}

///|
/// Create a reactive side-effect. Runs immediately to capture deps,
/// re-runs whenever any dependency changes.
/// Returns `Option::None` for no cleanup, or `Option::Some(fn)` for a
/// cleanup function that runs before the next execution.
pub fn effect(run : () -> (() -> Unit)?) -> Effect {
  new_effect(run)
}

///|
/// Read a Source's value, registering the active reaction as a dependency.
pub fn[T] read_source(s : Source[T]) -> T {
  get_source(s)
}

///|
/// Read a Derived's value. Lazily recomputes if dirty, then registers
/// the active reaction as a dependency.
pub fn[T] read_derived(d : Derived[T]) -> T {
  get_derived(d)
}

///|
/// Write to a Source. Skips if the new value equals the old (per `eq`).
/// Otherwise increments write_version and propagates dirtiness.
pub fn[T] write_source(s : Source[T], value : T) -> Unit {
  set_source_value(s, value)
}

///|
/// Check whether a Derived needs recomputation. Useful for debugging.
pub fn[T] derived_is_dirty(d : Derived[T]) -> Bool {
  is_dirty(d.id)
}

///|
/// Execute `body` without registering the signal reads inside as
/// dependencies of the active reaction. Equivalent to Svelte's `untrack()`.
pub fn[T] untrack(body : () -> T) -> T {
  do_untrack(body)
}
