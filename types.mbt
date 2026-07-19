///|
/// Signal flag constants for bitmask operations on `Reaction.f`.
/// Prefixed with `flag_` to avoid collisions with function names.
let flag_derived : Int = 1 << 1

///|
let flag_effect : Int = 1 << 2

///|
let flag_block_effect : Int = 1 << 4

///|
let flag_branch_effect : Int = 1 << 5

///|
let flag_root_effect : Int = 1 << 6

///|
let flag_clean : Int = 1 << 10

///|
let flag_dirty : Int = 1 << 11

///|
let flag_maybe_dirty : Int = 1 << 12

///|
let flag_destroyed : Int = 1 << 14

///|
let none_index : Int = -1

///|
let status_bits : Int = flag_dirty.lor(flag_maybe_dirty).lor(flag_clean)

///|
let status_mask : Int = status_bits.lnot()

///|
/// Reaction node in the dependency graph. Stored in a global Array registry;
/// referenced by index throughout the system.
pub(all) struct Reaction {
  mut f : Int
  mut deps : Array[Int]
  mut reactions : Array[Int]
  mut wv : Int
  mut rv : Int
  mut parent : Int
  mut first : Int
  mut last : Int
  mut next : Int
  mut prev : Int
  mut effects : Array[Int]
}
