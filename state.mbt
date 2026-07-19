///|
/// State[T] is an ergonomic wrapper around Source[T].
pub(all) struct State[T] {
  source : Source[T]
}

///|
pub fn[T : Eq] state(v : T) -> State[T] {
  { source: source(v, fn(x, y) { x == y }) }
}

///|
pub fn[T] State::get(self : State[T]) -> T {
  read_source(self.source)
}

///|
pub fn[T] State::set(self : State[T], v : T) -> Unit {
  write_source(self.source, v)
}

///|
/// Provide .get() on Derived for template ergonomics.
pub fn[T] Derived::get(self : Derived[T]) -> T {
  read_derived(self)
}

///|
/// Provide .set() on Derived — delegates to .get() (read-only).
pub fn[T] Derived::set(self : Derived[T], _v : T) -> Unit {}

