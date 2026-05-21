///|
test "config basic" {
  let result = config("KEY=value")
  assert_eq(result["KEY"], "value")
}

///|
test "config with existing env no override" {
  let env = Map([("KEY", "existing")], capacity=1)
  let result = config("KEY=new", env~)
  assert_eq(result["KEY"], "existing")
}

///|
test "config with existing env force override" {
  let env = Map([("KEY", "existing")], capacity=1)
  let result = config("KEY=new", env~, force=true)
  assert_eq(result["KEY"], "new")
}

///|
test "config merges new keys" {
  let env = Map([("A", "1")], capacity=1)
  let result = config("B=2", env~)
  assert_eq(result["A"], "1")
  assert_eq(result["B"], "2")
}

///|
test "merge basic" {
  let base = Map([("A", "1")], capacity=1)
  let other = Map([("B", "2")], capacity=1)
  let result = merge(base, other)
  assert_eq(result["A"], "1")
  assert_eq(result["B"], "2")
}

///|
test "merge base wins by default" {
  let base = Map([("KEY", "base")], capacity=1)
  let other = Map([("KEY", "other")], capacity=1)
  let result = merge(base, other)
  assert_eq(result["KEY"], "base")
}

///|
test "merge force other wins" {
  let base = Map([("KEY", "base")], capacity=1)
  let other = Map([("KEY", "other")], capacity=1)
  let result = merge(base, other, force=true)
  assert_eq(result["KEY"], "other")
}
