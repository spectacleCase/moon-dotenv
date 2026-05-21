///|
test "expand simple variable" {
  let parsed = parse("BASE=hello\nREF=$BASE")
  let result = expand(parsed)
  assert_eq(result["REF"], "hello")
}

///|
test "expand braced variable" {
  let parsed = parse("BASE=hello\nREF=${BASE}_world")
  let result = expand(parsed)
  assert_eq(result["REF"], "hello_world")
}

///|
test "expand undefined variable stays as-is" {
  let parsed = parse("REF=$UNDEFINED")
  let result = expand(parsed)
  assert_eq(result["REF"], "$UNDEFINED")
}

///|
test "expand undefined braced variable stays as-is" {
  let parsed = parse("REF=${UNDEFINED}")
  let result = expand(parsed)
  assert_eq(result["REF"], "${UNDEFINED}")
}

///|
test "expand with env override" {
  let parsed = parse("REF=$EXTERNAL")
  let env = Map([("EXTERNAL", "from_env")], capacity=1)
  let result = expand(parsed, env~)
  assert_eq(result["REF"], "from_env")
}

///|
test "expand parsed takes precedence over env" {
  let parsed = parse("KEY=from_parsed\nREF=$KEY")
  let env = Map([("KEY", "from_env")], capacity=1)
  let result = expand(parsed, env~)
  assert_eq(result["REF"], "from_parsed")
}
