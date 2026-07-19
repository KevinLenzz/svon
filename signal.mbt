///|
/// Source — writable reactive signal (Svelte's `$state`).
/// Writing to a source marks all dependents as dirty.
pub(all) struct Source[T] {
  id : Int
  mut v : T
  eq : (T, T) -> Bool
}

///|
/// A Derived is a read-only computed value (Svelte's `$derived`).
/// Lazily recomputes when its dependencies change.
pub(all) struct Derived[T] {
  id : Int
  mut v : T
  compute : () -> T
}

///|
/// An Effect is a reactive side-effect (Svelte's `$effect`).
/// Automatically re-runs when its dependencies change.
/// The function returns an optional cleanup function.
pub(all) struct Effect {
  id : Int
  run : () -> (() -> Unit)?
}
