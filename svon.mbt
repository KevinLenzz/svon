///|
/// Svon — a fine-grained reactive signal system inspired by Svelte 5.
///
/// Core primitives:
/// * `source`   — writable signal (Svelte's `$state`)
/// * `derived`  — computed signal (Svelte's `$derived`)
/// * `effect`   — side-effect signal (Svelte's `$effect`)
///
/// # Example
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
pub fn[T] source(v : T, eq : (T, T) -> Bool) -> Source[T] {
  new_source(v, eq)
}

///|
pub fn[T] derived(compute : () -> T) -> Derived[T] {
  new_derived(compute)
}

///|
pub fn effect(run : () -> (() -> Unit)?) -> Effect {
  new_effect(run)
}

///|
pub fn[T] read_source(s : Source[T]) -> T {
  get_source(s)
}

///|
pub fn[T] read_derived(d : Derived[T]) -> T {
  get_derived(d)
}

///|
pub fn[T] write_source(s : Source[T], value : T) -> Unit {
  set_source_value(s, value)
}

///|
pub fn[T] derived_is_dirty(d : Derived[T]) -> Bool {
  is_dirty(d.id)
}

///|
pub fn[T] untrack(body : () -> T) -> T {
  do_untrack(body)
}
