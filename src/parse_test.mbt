///|
test "basic variable" {
  let result = parse("BASIC=basic")
  assert_eq(result["BASIC"], "basic")
}

///|
test "empty value" {
  let result = parse("EMPTY=")
  assert_eq(result["EMPTY"], "")
}

///|
test "empty single quotes" {
  let result = parse("EMPTY_SINGLE_QUOTES=''")
  assert_eq(result["EMPTY_SINGLE_QUOTES"], "")
}

///|
test "empty double quotes" {
  let result = parse("EMPTY_DOUBLE_QUOTES=\"\"")
  assert_eq(result["EMPTY_DOUBLE_QUOTES"], "")
}

///|
test "empty backticks" {
  let result = parse("EMPTY_BACKTICKS=``")
  assert_eq(result["EMPTY_BACKTICKS"], "")
}

///|
test "single quoted value" {
  let result = parse("SINGLE_QUOTES='single_quotes'")
  assert_eq(result["SINGLE_QUOTES"], "single_quotes")
}

///|
test "single quoted with spaces" {
  let result = parse("SINGLE_QUOTES_SPACED='    single quotes    '")
  assert_eq(result["SINGLE_QUOTES_SPACED"], "    single quotes    ")
}

///|
test "double quoted value" {
  let result = parse("DOUBLE_QUOTES=\"double_quotes\"")
  assert_eq(result["DOUBLE_QUOTES"], "double_quotes")
}

///|
test "double quoted with spaces" {
  let result = parse("DOUBLE_QUOTES_SPACED=\"    double quotes    \"")
  assert_eq(result["DOUBLE_QUOTES_SPACED"], "    double quotes    ")
}

///|
test "double quotes inside single" {
  let result = parse("KEY='double \"quotes\" work inside single quotes'")
  assert_eq(result["KEY"], "double \"quotes\" work inside single quotes")
}

///|
test "single quotes inside double" {
  let result = parse("KEY=\"single 'quotes' work inside double quotes\"")
  assert_eq(result["KEY"], "single 'quotes' work inside double quotes")
}

///|
test "backticks inside single" {
  let result = parse("KEY='`backticks` work inside single quotes'")
  assert_eq(result["KEY"], "`backticks` work inside single quotes")
}

///|
test "backticks inside double" {
  let result = parse("KEY=\"`backticks` work inside double quotes\"")
  assert_eq(result["KEY"], "`backticks` work inside double quotes")
}

///|
test "backtick quoted value" {
  let result = parse("BACKTICKS=`backticks`")
  assert_eq(result["BACKTICKS"], "backticks")
}

///|
test "backtick quoted with spaces" {
  let result = parse("BACKTICKS_SPACED=`    backticks    `")
  assert_eq(result["BACKTICKS_SPACED"], "    backticks    ")
}

///|
test "expand newlines in double quotes" {
  let result = parse("KEY=\"expand\\nnew\\nlines\"")
  assert_eq(result["KEY"], "expand\nnew\nlines")
}

///|
test "dont expand newlines unquoted" {
  let result = parse("KEY=dontexpand\\nnewlines")
  assert_eq(result["KEY"], "dontexpand\\nnewlines")
}

///|
test "dont expand newlines single quoted" {
  let result = parse("KEY='dontexpand\\nnewlines'")
  assert_eq(result["KEY"], "dontexpand\\nnewlines")
}

///|
test "ignore comment lines" {
  let result = parse("# COMMENTS=work\nKEY=value")
  assert_eq(result["KEY"], "value")
  let keys_count = result.length()
  assert_eq(keys_count, 1)
}

///|
test "inline comments" {
  let result = parse("KEY=inline comments # work #very #well")
  assert_eq(result["KEY"], "inline comments")
}

///|
test "inline comments single quotes" {
  let result = parse("KEY='inline comments outside of #singlequotes' # work")
  assert_eq(result["KEY"], "inline comments outside of #singlequotes")
}

///|
test "inline comments double quotes" {
  let result = parse("KEY=\"inline comments outside of #doublequotes\" # work")
  assert_eq(result["KEY"], "inline comments outside of #doublequotes")
}

///|
test "inline comments backticks" {
  let result = parse("KEY=`inline comments outside of #backticks` # work")
  assert_eq(result["KEY"], "inline comments outside of #backticks")
}

///|
test "inline comments space" {
  let result = parse(
    "KEY=inline comments start with a#number sign. no space required.",
  )
  assert_eq(result["KEY"], "inline comments start with a")
}

///|
test "equals in value" {
  let result = parse("EQUAL_SIGNS=equals==")
  assert_eq(result["EQUAL_SIGNS"], "equals==")
}

///|
test "retain inner quotes" {
  let result = parse("KEY={\"foo\": \"bar\"}")
  assert_eq(result["KEY"], "{\"foo\": \"bar\"}")
}

///|
test "retain inner quotes as string" {
  let result = parse("KEY='{\"foo\": \"bar\"}'")
  assert_eq(result["KEY"], "{\"foo\": \"bar\"}")
}

///|
test "trim space from unquoted" {
  let result = parse("KEY=    some spaced out string")
  assert_eq(result["KEY"], "some spaced out string")
}

///|
test "email address" {
  let result = parse("USERNAME=therealnerdybeast@example.tld")
  assert_eq(result["USERNAME"], "therealnerdybeast@example.tld")
}

///|
test "spaced key" {
  let result = parse("    SPACED_KEY = parsed")
  assert_eq(result["SPACED_KEY"], "parsed")
}

///|
test "export prefix" {
  let result = parse("export EXPORT_IS_DECLARED=parsed")
  assert_eq(result["EXPORT_IS_DECLARED"], "parsed")
}

///|
test "export prefix with spacing" {
  let result = parse("export   EXPORT_IS_DECLARED_WITH_SPACING=parsed")
  assert_eq(result["EXPORT_IS_DECLARED_WITH_SPACING"], "parsed")
}

///|
test "export prefix with value" {
  let result = parse("export EXPORT_IS_DECLARED_WITH_SOME_VALUE=some_value")
  assert_eq(result["EXPORT_IS_DECLARED_WITH_SOME_VALUE"], "some_value")
}

///|
test "export prefix with value and spacing" {
  let result = parse(
    "export   EXPORT_IS_DECLARED_WITH_SOME_VALUE_AND_SPACING  =some_value",
  )
  assert_eq(
    result["EXPORT_IS_DECLARED_WITH_SOME_VALUE_AND_SPACING"],
    "some_value",
  )
}

///|
test "duplicate key last wins" {
  let result = parse("DUP=one\nDUP=two")
  assert_eq(result["DUP"], "two")
}

///|
test "windows line endings" {
  let result = parse("SERVER=localhost\rPASSWORD=password\rDB=tests\r")
  assert_eq(result["SERVER"], "localhost")
  assert_eq(result["PASSWORD"], "password")
  assert_eq(result["DB"], "tests")
}

///|
test "unix line endings" {
  let result = parse("SERVER=localhost\nPASSWORD=password\nDB=tests\n")
  assert_eq(result["SERVER"], "localhost")
  assert_eq(result["PASSWORD"], "password")
  assert_eq(result["DB"], "tests")
}

///|
test "multiline double quoted" {
  let result = parse("KEY=\"THIS\nIS\nA\nMULTILINE\nSTRING\"")
  assert_eq(result["KEY"], "THIS\nIS\nA\nMULTILINE\nSTRING")
}

///|
test "multiline single quoted" {
  let result = parse("KEY='THIS\nIS\nA\nMULTILINE\nSTRING'")
  assert_eq(result["KEY"], "THIS\nIS\nA\nMULTILINE\nSTRING")
}

///|
test "multiline backtick quoted" {
  let result = parse("KEY=`THIS\nIS\nA\n\"MULTILINE'S\"\nSTRING`")
  assert_eq(result["KEY"], "THIS\nIS\nA\n\"MULTILINE'S\"\nSTRING")
}

///|
test "colon separator" {
  let result = parse("KEY: value")
  assert_eq(result["KEY"], "value")
}

///|
test "blank lines between entries" {
  let result = parse("A=1\n\nB=2\n\n\nC=3")
  assert_eq(result["A"], "1")
  assert_eq(result["B"], "2")
  assert_eq(result["C"], "3")
}

///|
test "dots and dashes in key" {
  let result = parse("my.key-name=value")
  assert_eq(result["my.key-name"], "value")
}

///|
test "expand tabs in double quotes" {
  let result = parse("KEY=\"col1\\tcol2\"")
  assert_eq(result["KEY"], "col1\tcol2")
}

///|
test "expand backslash in double quotes" {
  let result = parse("KEY=\"path\\\\to\\\\file\"")
  assert_eq(result["KEY"], "path\\to\\file")
}

///|
test "backslash n stays literal in double quotes" {
  let result = parse("KEY=\"keep\\nliteral\"")
  assert_eq(result["KEY"], "keep\nliteral")
}

///|
test "try_parse returns ok on valid input" {
  let result = try_parse("KEY=value")
  assert_true(result is Ok(_))
  assert_eq(result.unwrap()["KEY"], "value")
}

///|
test "try_parse returns err on unclosed single quote" {
  let result = try_parse("KEY='unclosed")
  assert_true(result is Err(_))
  let err = result.unwrap_err()
  assert_eq(err.message, "unclosed single quote")
  assert_eq(err.line, 1)
}

///|
test "try_parse returns err on unclosed double quote" {
  let result = try_parse("KEY=\"unclosed")
  assert_true(result is Err(_))
  let err = result.unwrap_err()
  assert_eq(err.message, "unclosed double quote")
  assert_eq(err.line, 1)
}

///|
test "try_parse returns err on unclosed backtick" {
  let result = try_parse("KEY=`unclosed")
  assert_true(result is Err(_))
  let err = result.unwrap_err()
  assert_eq(err.message, "unclosed backtick")
  assert_eq(err.line, 1)
}

///|
test "try_parse error line number" {
  let result = try_parse("A=ok\nB=ok\nC='unclosed")
  assert_true(result is Err(_))
  assert_eq(result.unwrap_err().line, 3)
}

///|
test "ParseError to_string" {
  let result = try_parse("KEY='unclosed")
  assert_true(result is Err(_))
  let err = result.unwrap_err()
  assert_eq(err.to_string(), "ParseError(line 1): unclosed single quote")
}

///|
test "ParseError to_string multiline" {
  let result = try_parse("A=ok\nB=\"unclosed")
  assert_true(result is Err(_))
  let err = result.unwrap_err()
  assert_eq(err.to_string(), "ParseError(line 2): unclosed double quote")
}

///|
test "strip utf-8 bom" {
  let src = "\u{FEFF}KEY=value"
  let result = parse(src)
  assert_eq(result["KEY"], "value")
}

///|
test "strip utf-8 bom with multiple keys" {
  let src = "\u{FEFF}A=1\nB=2"
  let result = parse(src)
  assert_eq(result["A"], "1")
  assert_eq(result["B"], "2")
}

///|
test "no bom is harmless" {
  let src = "KEY=value"
  let result = parse(src)
  assert_eq(result["KEY"], "value")
}

///|
test "try_parse strips utf-8 bom" {
  let src = "\u{FEFF}KEY=value"
  let result = try_parse(src)
  assert_true(result is Ok(_))
  assert_eq(result.unwrap()["KEY"], "value")
}
