///|
test "validate all present" {
  let map = Map([("A", "1"), ("B", "2")], capacity=2)
  let missing = validate(map, ["A", "B"])
  assert_eq(missing.length(), 0)
}

///|
test "validate some missing" {
  let map = Map([("A", "1")], capacity=1)
  let missing = validate(map, ["A", "B", "C"])
  assert_eq(missing.length(), 2)
  assert_eq(missing[0], "B")
  assert_eq(missing[1], "C")
}

///|
test "validate all missing" {
  let map : Map[String, String] = Map([], capacity=0)
  let missing = validate(map, ["X", "Y"])
  assert_eq(missing.length(), 2)
}

///|
test "validate empty requirements" {
  let map = Map([("A", "1")], capacity=1)
  let missing = validate(map, [])
  assert_eq(missing.length(), 0)
}
