///|
test "defaults fills missing keys" {
  let map = Map([("A", "1")], capacity=1)
  let defs = Map([("A", "x"), ("B", "2"), ("C", "3")], capacity=3)
  let result = defaults(map, defs)
  assert_eq(result["A"], "1")
  assert_eq(result["B"], "2")
  assert_eq(result["C"], "3")
}

///|
test "defaults does not override existing" {
  let map = Map([("HOST", "localhost")], capacity=1)
  let defs = Map([("HOST", "127.0.0.1"), ("PORT", "3000")], capacity=2)
  let result = defaults(map, defs)
  assert_eq(result["HOST"], "localhost")
  assert_eq(result["PORT"], "3000")
}

///|
test "defaults empty map" {
  let map : Map[String, String] = Map([], capacity=0)
  let defs = Map([("A", "1")], capacity=1)
  let result = defaults(map, defs)
  assert_eq(result["A"], "1")
}

///|
test "defaults empty defaults" {
  let map = Map([("A", "1")], capacity=1)
  let defs : Map[String, String] = Map([], capacity=0)
  let result = defaults(map, defs)
  assert_eq(result["A"], "1")
  assert_eq(result.length(), 1)
}
