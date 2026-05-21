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

///|
test "populate basic" {
  let target = Map([], capacity=4)
  let parsed = parse("A=1\nB=2")
  let count = populate(target, parsed)
  assert_eq(count, 2)
  assert_eq(target["A"], "1")
  assert_eq(target["B"], "2")
}

///|
test "populate skips existing by default" {
  let target = Map([("A", "existing")], capacity=2)
  let parsed = parse("A=new\nB=2")
  let count = populate(target, parsed)
  assert_eq(count, 1)
  assert_eq(target["A"], "existing")
  assert_eq(target["B"], "2")
}

///|
test "populate force overwrites" {
  let target = Map([("A", "existing")], capacity=2)
  let parsed = parse("A=new\nB=2")
  let count = populate(target, parsed, force=true)
  assert_eq(count, 2)
  assert_eq(target["A"], "new")
  assert_eq(target["B"], "2")
}
