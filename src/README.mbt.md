# lizhentao/dotenv

MoonBit 版 Dotenv —— 从 `.env` 文件中加载环境变量。

移植自 [motdotla/dotenv](https://github.com/motdotla/dotenv) (npm)。

## 安装

```
moon add lizhentao/dotenv
```

## 使用方法

### parse

将 `.env` 格式的字符串解析为 `Map[String, String]`。

```moonbit nocheck
///|
let result = @dotenv.parse("DB_HOST=localhost\nDB_PORT=5432")
```

test "parse basic key-value" {
  let result = @dotenv.parse("DB_HOST=localhost\nDB_PORT=5432")
  assert_eq(result["DB_HOST"], "localhost")
  assert_eq(result["DB_PORT"], "5432")
}

### 支持的格式

**引号值** —— 单引号（字面量）、双引号（支持转义序列）、反引号（字面量）：

test "parse quoted values" {
  let result = @dotenv.parse("SINGLE='hello'\nDOUBLE=\"world\"")
  assert_eq(result["SINGLE"], "hello")
  assert_eq(result["DOUBLE"], "world")
}

**换行转义** —— 双引号值中的 `\n` 和 `\r`：

test "parse newline escapes" {
  let result = @dotenv.parse("KEY=\"line1\\nline2\"")
  assert_eq(result["KEY"], "line1\nline2")
}

**多行值** —— 引号内的实际换行：

test "parse multiline values" {
  let result = @dotenv.parse("KEY=\"line1\nline2\nline3\"")
  assert_eq(result["KEY"], "line1\nline2\nline3")
}

**export 前缀** —— 静默忽略：

test "parse export prefix" {
  let result = @dotenv.parse("export APP_ENV=production")
  assert_eq(result["APP_ENV"], "production")
}

**行内注释** —— `#` 开始注释：

test "parse inline comments" {
  let result = @dotenv.parse("KEY=value # this is a comment")
  assert_eq(result["KEY"], "value")
}

**空值**：

test "parse empty values" {
  let result = @dotenv.parse("EMPTY=\nQUOTED_EMPTY=\"\"")
  assert_eq(result["EMPTY"], "")
  assert_eq(result["QUOTED_EMPTY"], "")
}

**重复键** —— 后者覆盖前者：

test "parse duplicate keys" {
  let result = @dotenv.parse("KEY=first\nKEY=second")
  assert_eq(result["KEY"], "second")
}

### expand

展开已解析值中的 `$VAR` 和 `${VAR}` 变量引用。

```moonbit nocheck
///|
let parsed = @dotenv.parse("BASE=hello\nREF=${BASE}_world")

///|
let result = @dotenv.expand(parsed)
```

test "expand variables" {
  let parsed = @dotenv.parse("BASE=hello\nREF=${BASE}_world")
  let result = @dotenv.expand(parsed)
  assert_eq(result["REF"], "hello_world")
}

可以传入外部 `env` Map 来补充 `.env` 文件中未定义的变量：

test "expand with external env" {
  let parsed = @dotenv.parse("REF=$EXTERNAL")
  let env = Map([("EXTERNAL", "from_env")], capacity=1)
  let result = @dotenv.expand(parsed, env=env)
  assert_eq(result["REF"], "from_env")
}

已解析 Map 中的变量优先级高于外部 env：

test "expand precedence" {
  let parsed = @dotenv.parse("KEY=parsed\nREF=$KEY")
  let env = Map([("KEY", "env")], capacity=1)
  let result = @dotenv.expand(parsed, env=env)
  assert_eq(result["REF"], "parsed")
}

未定义的变量保持原样：

test "expand undefined variable" {
  let parsed = @dotenv.parse("REF=$UNDEFINED")
  let result = @dotenv.expand(parsed)
  assert_eq(result["REF"], "$UNDEFINED")
}

## API 参考

| 函数 | 签名 | 说明 |
|------|------|------|
| `parse` | `(String) -> Map[String, String]` | 将 `.env` 字符串解析为键值对 Map |
| `expand` | `(Map[String, String], env~ : Map[String, String]) -> Map[String, String]` | 展开值中的 `$VAR` / `${VAR}` 引用 |

## 许可证

Apache-2.0
