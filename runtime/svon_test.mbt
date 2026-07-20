///|
/// Black-box tests for the Svon reactive signal system.
test "source read/write" {
  let s = source(0, fn(a, b) { a == b })
  let v = read_source(s)
  inspect(v, content="0")
  write_source(s, 42)
  inspect(read_source(s), content="42")
}

///|
test "source does not propagate on same value" {
  let s = source(10, fn(a, b) { a == b })
  let runs = Ref(0)
  let _e = effect(fn() {
    let _ = read_source(s)
    runs.val = runs.val + 1
    Option::None
  })
  write_source(s, 10)
  write_source(s, 10)
  inspect(runs.val, content="1")
}

///|
test "effect re-runs on dependency change" {
  let s = source(0, fn(a, b) { a == b })
  let runs = Ref(0)
  let _e = effect(fn() {
    let _ = read_source(s)
    runs.val = runs.val + 1
    Option::None
  })
  inspect(runs.val, content="1")
  write_source(s, 1)
  inspect(runs.val, content="2")
  write_source(s, 2)
  inspect(runs.val, content="3")
}

///|
test "derived computes lazily" {
  let s = source(2, fn(a, b) { a == b })
  let d = derived(fn() { read_source(s) * 10 })
  inspect(read_derived(d), content="20")
  write_source(s, 5)
  inspect(read_derived(d), content="50")
}

///|
test "derived tracks multiple sources" {
  let a = source(1, fn(x, y) { x == y })
  let b = source(2, fn(x, y) { x == y })
  let sum = derived(fn() { read_source(a) + read_source(b) })
  inspect(read_derived(sum), content="3")
  write_source(a, 10)
  inspect(read_derived(sum), content="12")
  write_source(b, 20)
  inspect(read_derived(sum), content="30")
}

///|
test "untrack avoids dependency" {
  let a = source(0, fn(x, y) { x == y })
  let b = source(0, fn(x, y) { x == y })
  let runs = Ref(0)
  let _e = effect(fn() {
    let _a = read_source(a)
    let _b = untrack(fn() { read_source(b) })
    runs.val = runs.val + 1
    Option::None
  })
  inspect(runs.val, content="1")
  write_source(b, 1)
  inspect(runs.val, content="1")
  write_source(a, 1)
  inspect(runs.val, content="2")
}

///|
test "effect chain" {
  let s = source(0, fn(x, y) { x == y })
  let d = derived(fn() { read_source(s) + 1 })
  let last = Ref(-1)
  let runs = Ref(0)
  let _e = effect(fn() {
    last.val = read_derived(d)
    runs.val = runs.val + 1
    Option::None
  })
  inspect(last.val, content="1")
  inspect(runs.val, content="1")
  write_source(s, 5)
  inspect(last.val, content="6")
  inspect(runs.val, content="3")
}
