///|
test "stringify simple values" {
  let map = Map([("HOST", "localhost"), ("PORT", "5432")], capacity=2)
  let result = stringify(map)
  assert_true(result.contains("HOST=localhost"))
  assert_true(result.contains("PORT=5432"))
}

///|
test "stringify empty value" {
  let map = Map([("EMPTY", "")], capacity=1)
  let result = stringify(map)
  assert_eq(result, "EMPTY=\"\"")
}

///|
test "stringify value with spaces" {
  let map = Map([("MSG", "hello world")], capacity=1)
  let result = stringify(map)
  assert_eq(result, "MSG=\"hello world\"")
}

///|
test "stringify value with newline" {
  let map = Map([("MULTI", "line1\nline2")], capacity=1)
  let result = stringify(map)
  assert_eq(result, "MULTI=\"line1\\nline2\"")
}

///|
test "stringify value with tab" {
  let map = Map([("TAB", "col1\tcol2")], capacity=1)
  let result = stringify(map)
  assert_eq(result, "TAB=\"col1\\tcol2\"")
}

///|
test "stringify value with backslash" {
  let map = Map([("PATH", "C:\\Users\\test")], capacity=1)
  let result = stringify(map)
  assert_eq(result, "PATH=\"C:\\\\Users\\\\test\"")
}

///|
test "stringify value with hash" {
  let map = Map([("COMMENT", "has#hash")], capacity=1)
  let result = stringify(map)
  assert_eq(result, "COMMENT=\"has#hash\"")
}

///|
test "stringify value with quotes" {
  let map = Map([("JSON", "{\"key\":\"val\"}")], capacity=1)
  let result = stringify(map)
  assert_eq(result, "JSON=\"{\\\"key\\\":\\\"val\\\"}\"")
}

///|
test "stringify roundtrip" {
  let input = "HOST=localhost\nPORT=5432\nEMPTY=\nMSG=\"hello world\""
  let parsed = parse(input)
  let output = stringify(parsed)
  let reparsed = parse(output)
  assert_eq(reparsed["HOST"], "localhost")
  assert_eq(reparsed["PORT"], "5432")
  assert_eq(reparsed["EMPTY"], "")
  assert_eq(reparsed["MSG"], "hello world")
}

///|
test "stringify multiline value roundtrip" {
  let input = "KEY=\"line1\nline2\nline3\""
  let parsed = parse(input)
  let output = stringify(parsed)
  let reparsed = parse(output)
  assert_eq(reparsed["KEY"], "line1\nline2\nline3")
}
