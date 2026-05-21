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

///|
test "load_multi merges in order" {
  let sources = ["A=1", "B=2"]
  let result = load_multi(sources)
  assert_eq(result["A"], "1")
  assert_eq(result["B"], "2")
}

///|
test "load_multi later overrides earlier" {
  let sources = ["KEY=first", "KEY=second"]
  let result = load_multi(sources)
  assert_eq(result["KEY"], "second")
}

///|
test "load_multi empty array" {
  let sources : Array[String] = []
  let result = load_multi(sources)
  assert_eq(result.length(), 0)
}

///|
test "config_multi with env" {
  let env = Map([("EXISTING", "val")], capacity=1)
  let result = config_multi(["NEW=1"], env~)
  assert_eq(result["EXISTING"], "val")
  assert_eq(result["NEW"], "1")
}

///|
test "config_multi force override" {
  let env = Map([("KEY", "env")], capacity=1)
  let result = config_multi(["KEY=parsed"], env~, force=true)
  assert_eq(result["KEY"], "parsed")
}
