///|
/// Signal flag constants for bitmask operations on `Reaction.f`.
/// Each signal carries a bitmask that encodes both its type and its
/// cleanliness state.  Type bits and status bits occupy separate ranges
/// so they can coexist in a single `Int` field.
///
/// ## Type flags — what kind of signal this is
///
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
/// ## Cleanliness state — whether a signal needs re-evaluation
///
let flag_clean : Int = 1 << 10
///|
let flag_dirty : Int = 1 << 11
///|
/// A MAYBE_DIRTY signal must walk its dependency list and compare
/// write-version numbers to determine whether it is actually stale.
/// This is the key to Svelte's fine-grained reactivity.
let flag_maybe_dirty : Int = 1 << 12

///|
let flag_destroyed : Int = 1 << 14

///|
/// Sentinel value for "no reaction" — used in parent/child/sibling
/// pointers within the effect tree.
let none_index : Int = -1

///|
/// Pre-computed bitmasks for efficient status manipulation.
/// `status_bits` collects all cleanliness flags.
let status_bits : Int = flag_dirty.lor(flag_maybe_dirty).lor(flag_clean)

///|
/// `status_mask` is the bitwise NOT of `status_bits`.
/// Used to CLEAR the cleanliness bits before OR'ing in a new status:
/// `reaction.f = reaction.f.land(status_mask).lor(new_status)`
let status_mask : Int = status_bits.lnot()

///|
/// Reaction is the shared graph node stored in a global `Array[Reaction]`
/// registry and referenced everywhere by index (`Int`).  Every Source,
/// Derived, and Effect creates one Reaction node.  Using integer indices
/// instead of pointers avoids circular-reference issues in MoonBit's
/// ownership model.
///
/// ## Fields
/// * `f`     — bitmask of type and cleanliness flags (see above)
/// * `deps`  — indices of upstream signals this reaction reads
/// * `reactions` — indices of downstream signals/effects that depend on this one
/// * `wv`    — write-version at last evaluation (used for version-checking dirtyness)
/// * `rv`    — read-version within a single reaction execution (dedup optimisation)
/// * `parent`/`first`/`last`/`next`/`prev` — doubly-linked effect tree pointers
/// * `effects` — child effects owned by this (used for deriveds)
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
