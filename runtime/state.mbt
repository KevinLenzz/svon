///|
/// State[T] wraps Source[T] to provide `.get()` and `.set()` methods
/// for ergonomic template usage.  Equivalent to Svelte's `$state()`.
///
/// The `T : Eq` constraint on `state()` means built-in types (Int, String,
/// Bool) are supported out of the box; custom types must derive `Eq`.
pub(all) struct State[T] {
  source : Source[T]
}

///|
/// Create a new reactive state initialized to `v`.
/// Equality check prevents redundant propagation when writing the same value.
pub fn[T : Eq] state(v : T) -> State[T] {
  { source: source(v, fn(x, y) { x == y }) }
}

///|
/// Read the current value.  Automatically registers the active reaction
/// (if any) as a dependency of this signal — the read is tracked.
pub fn[T] State::get(self : State[T]) -> T {
  read_source(self.source)
}

///|
/// Write a new value.  Skips propagation if `eq(old, new)` is true.
/// Otherwise increments the global `write_version`, updates the source's
/// `wv`, and calls `mark_reactions` to dirty all downstream signals.
pub fn[T] State::set(self : State[T], v : T) -> Unit {
  write_source(self.source, v)
}

///|
/// Allow reading a Derived with `.get()` for uniform template syntax
/// (`{doubled.get()}` works on both State and Derived).
pub fn[T] Derived::get(self : Derived[T]) -> T {
  read_derived(self)
}

///|
/// No-op `.set()` on Derived — deriveds are read-only.  Kept for
/// type-system symmetry so code using `.set()` on a variable works
/// regardless of whether it's State or Derived.
pub fn[T] Derived::set(self : Derived[T], _v : T) -> Unit { let _ = self }
