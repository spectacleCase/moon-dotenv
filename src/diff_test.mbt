///|
test "diff detects added keys" {
  let base = Map([("A", "1")], capacity=1)
  let other = Map([("A", "1"), ("B", "2")], capacity=2)
  let d = diff(base, other)
  assert_eq(d.added.length(), 1)
  assert_eq(d.added[0], "B")
  assert_eq(d.removed.length(), 0)
  assert_eq(d.changed.length(), 0)
}

///|
test "diff detects removed keys" {
  let base = Map([("A", "1"), ("B", "2")], capacity=2)
  let other = Map([("A", "1")], capacity=1)
  let d = diff(base, other)
  assert_eq(d.removed.length(), 1)
  assert_eq(d.removed[0], "B")
  assert_eq(d.added.length(), 0)
  assert_eq(d.changed.length(), 0)
}

///|
test "diff detects changed values" {
  let base = Map([("A", "old")], capacity=1)
  let other = Map([("A", "new")], capacity=1)
  let d = diff(base, other)
  assert_eq(d.changed.length(), 1)
  assert_eq(d.changed[0], "A")
  assert_eq(d.added.length(), 0)
  assert_eq(d.removed.length(), 0)
}

///|
test "diff mixed changes" {
  let base = Map([("KEEP", "same"), ("OLD", "val")], capacity=2)
  let other = Map(
    [("KEEP", "same"), ("NEW", "val"), ("OLD", "changed")],
    capacity=3,
  )
  let d = diff(base, other)
  assert_eq(d.added.length(), 1)
  assert_eq(d.added[0], "NEW")
  assert_eq(d.removed.length(), 0)
  assert_eq(d.changed.length(), 1)
  assert_eq(d.changed[0], "OLD")
}

///|
test "diff identical maps" {
  let base = Map([("A", "1"), ("B", "2")], capacity=2)
  let other = Map([("A", "1"), ("B", "2")], capacity=2)
  let d = diff(base, other)
  assert_eq(d.added.length(), 0)
  assert_eq(d.removed.length(), 0)
  assert_eq(d.changed.length(), 0)
}

///|
test "diff empty maps" {
  let base : Map[String, String] = Map([], capacity=0)
  let other : Map[String, String] = Map([], capacity=0)
  let d = diff(base, other)
  assert_eq(d.added.length(), 0)
  assert_eq(d.removed.length(), 0)
  assert_eq(d.changed.length(), 0)
}
