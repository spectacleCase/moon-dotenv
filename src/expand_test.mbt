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

///|
test "expand default value when undefined" {
  let parsed = parse("REF=${UNDEFINED:-fallback}")
  let result = expand(parsed)
  assert_eq(result["REF"], "fallback")
}

///|
test "expand default value ignored when defined" {
  let parsed = parse("KEY=actual\nREF=${KEY:-fallback}")
  let result = expand(parsed)
  assert_eq(result["REF"], "actual")
}

///|
test "expand default value empty string" {
  let parsed = parse("REF=${UNDEFINED:-}")
  let result = expand(parsed)
  assert_eq(result["REF"], "")
}

///|
test "expand default value with special chars" {
  let parsed = parse("REF=${UNDEFINED:-hello world}")
  let result = expand(parsed)
  assert_eq(result["REF"], "hello world")
}

///|
test "expand alt value when defined" {
  let parsed = parse("KEY=original\nREF=${KEY:+replaced}")
  let result = expand(parsed)
  assert_eq(result["REF"], "replaced")
}

///|
test "expand alt value empty when undefined" {
  let parsed = parse("REF=${UNDEFINED:+replaced}")
  let result = expand(parsed)
  assert_eq(result["REF"], "")
}

///|
test "expand alt value empty string when defined" {
  let parsed = parse("KEY=val\nREF=${KEY:+}")
  let result = expand(parsed)
  assert_eq(result["REF"], "")
}

///|
test "expand chained references" {
  let parsed = parse("A=$B\nB=$C\nC=hello")
  let result = expand(parsed)
  assert_eq(result["A"], "hello")
  assert_eq(result["B"], "hello")
  assert_eq(result["C"], "hello")
}

///|
test "expand deep chain" {
  let parsed = parse("A=$B\nB=$C\nC=$D\nD=$E\nE=deep")
  let result = expand(parsed)
  assert_eq(result["A"], "deep")
}

///|
test "expand circular reference does not loop" {
  let parsed = parse("A=$B\nB=$A")
  let result = expand(parsed)
  let a = result["A"]
  assert_true(a == "$A" || a == "$B" || a == "A" || a.contains("$"))
}

///|
test "expand self reference does not loop" {
  let parsed = parse("A=$A")
  let result = expand(parsed)
  assert_eq(result["A"], "$A")
}

///|
test "expand partial chain with literal" {
  let parsed = parse("URL=${PROTO}://${HOST}:${PORT}\nPROTO=https\nHOST=example.com\nPORT=8080")
  let result = expand(parsed)
  assert_eq(result["URL"], "https://example.com:8080")
}

///|
test "expand dollar dollar escape" {
  let parsed = parse("PRICE=$$100")
  let result = expand(parsed)
  assert_eq(result["PRICE"], "$100")
}

///|
test "expand dollar dollar before var" {
  let parsed = parse("ESCAPE=$$\nREF=$$HOME")
  let result = expand(parsed)
  assert_eq(result["ESCAPE"], "$")
  assert_eq(result["REF"], "$HOME")
}

///|
test "expand dollar dollar with normal var" {
  let parsed = parse("LITERAL=$$\nVAR=hello\nREF=$$${VAR}")
  let result = expand(parsed)
  assert_eq(result["LITERAL"], "$")
  assert_eq(result["REF"], "$hello")
}
