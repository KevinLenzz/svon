///|
/// Black-box tests for the Svon reactive signal system.
test "source read/write" {
  let s = @svon.source(0, fn(a, b) { a == b })
  let v = @svon.read_source(s)
  inspect(v, content="0")
  @svon.write_source(s, 42)
  inspect(@svon.read_source(s), content="42")
}

///|
test "source does not propagate on same value" {
  let s = @svon.source(10, fn(a, b) { a == b })
  let runs = Ref(0)
  let _e = @svon.effect(fn() {
    let _ = @svon.read_source(s)
    runs.val = runs.val + 1
    Option::None
  })
  @svon.write_source(s, 10)
  @svon.write_source(s, 10)
  inspect(runs.val, content="1")
}

///|
test "effect re-runs on dependency change" {
  let s = @svon.source(0, fn(a, b) { a == b })
  let runs = Ref(0)
  let _e = @svon.effect(fn() {
    let _ = @svon.read_source(s)
    runs.val = runs.val + 1
    Option::None
  })
  inspect(runs.val, content="1")
  @svon.write_source(s, 1)
  inspect(runs.val, content="2")
  @svon.write_source(s, 2)
  inspect(runs.val, content="3")
}

///|
test "derived computes lazily" {
  let s = @svon.source(2, fn(a, b) { a == b })
  let d = @svon.derived(fn() { @svon.read_source(s) * 10 })
  inspect(@svon.read_derived(d), content="20")
  @svon.write_source(s, 5)
  inspect(@svon.read_derived(d), content="50")
}

///|
test "derived tracks multiple sources" {
  let a = @svon.source(1, fn(x, y) { x == y })
  let b = @svon.source(2, fn(x, y) { x == y })
  let sum = @svon.derived(fn() { @svon.read_source(a) + @svon.read_source(b) })
  inspect(@svon.read_derived(sum), content="3")
  @svon.write_source(a, 10)
  inspect(@svon.read_derived(sum), content="12")
  @svon.write_source(b, 20)
  inspect(@svon.read_derived(sum), content="30")
}

///|
test "untrack avoids dependency" {
  let a = @svon.source(0, fn(x, y) { x == y })
  let b = @svon.source(0, fn(x, y) { x == y })
  let runs = Ref(0)
  let _e = @svon.effect(fn() {
    let _a = @svon.read_source(a)
    let _b = @svon.untrack(fn() { @svon.read_source(b) })
    runs.val = runs.val + 1
    Option::None
  })
  inspect(runs.val, content="1")
  @svon.write_source(b, 1)
  inspect(runs.val, content="1")
  @svon.write_source(a, 1)
  inspect(runs.val, content="2")
}

///|
test "effect chain" {
  let s = @svon.source(0, fn(x, y) { x == y })
  let d = @svon.derived(fn() { @svon.read_source(s) + 1 })
  let last = Ref(-1)
  let runs = Ref(0)
  let _e = @svon.effect(fn() {
    last.val = @svon.read_derived(d)
    runs.val = runs.val + 1
    Option::None
  })
  inspect(last.val, content="1")
  inspect(runs.val, content="1")
  @svon.write_source(s, 5)
  inspect(last.val, content="6")
  inspect(runs.val, content="3")
}
