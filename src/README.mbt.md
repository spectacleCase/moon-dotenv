# spectacleCase/dotenv

MoonBit 版 Dotenv —— 从 `.env` 文件中加载环境变量。

移植自 [motdotla/dotenv](https://github.com/motdotla/dotenv) (npm)。

## 安装

```
moon add spectacleCase/dotenv
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

### stringify

将 `Map[String, String]` 序列化为 `.env` 格式字符串。需要转义的值会自动双引号包裹。

test "stringify roundtrip" {
  let parsed = @dotenv.parse("HOST=localhost\nPORT=5432")
  let output = @dotenv.stringify(parsed)
  let reparsed = @dotenv.parse(output)
  assert_eq(reparsed["HOST"], "localhost")
  assert_eq(reparsed["PORT"], "5432")
}

### diff

对比两个 Map，返回新增、删除、变更的键。

test "diff detects changes" {
  let base = @dotenv.parse("A=1\nB=2")
  let other = @dotenv.parse("A=1\nC=3")
  let d = @dotenv.diff(base, other)
  assert_eq(d.removed.length(), 1)
  assert_eq(d.added.length(), 1)
}

### try_parse

类似 `parse`，但遇到未闭合引号时返回 `Err(ParseError)` 而非静默忽略。

test "try_parse error" {
  let result = @dotenv.try_parse("KEY='unclosed")
  assert_true(result is Err(_))
}

### defaults

为缺失的键设置默认值，不影响已存在的键。

test "defaults fills missing" {
  let env = @dotenv.parse("HOST=localhost")
  let defs = Map([("PORT", "5432"), ("HOST", "127.0.0.1")], capacity=2)
  let result = @dotenv.defaults(env, defs)
  assert_eq(result["HOST"], "localhost")
  assert_eq(result["PORT"], "5432")
}

### validate

校验必需的 key 是否存在，返回缺失的 key 列表。

test "validate finds missing keys" {
  let env = @dotenv.parse("HOST=localhost")
  let missing = @dotenv.validate(env, ["HOST", "PORT", "DB"])
  assert_eq(missing.length(), 2)
}

### `$$` 转义

`$$` 在 `expand` 中表示字面量 `$`，不会触发变量展开：

test "dollar dollar escape" {
  let parsed = @dotenv.parse("PRICE=$$100")
  let result = @dotenv.expand(parsed)
  assert_eq(result["PRICE"], "$100")
}

## API 参考

| 函数 | 签名 | 说明 |
|------|------|------|
| `parse` | `(String) -> Map[String, String]` | 将 `.env` 字符串解析为键值对 Map（自动剥离 UTF-8 BOM） |
| `try_parse` | `(String) -> Result[Map[String, String], ParseError]` | 解析，遇到错误返回 `Err` |
| `expand` | `(Map[String, String], env? : Map[String, String]) -> Map[String, String]` | 展开 `$VAR` / `${VAR}`，`$$` 表示字面量 `$` |
| `stringify` | `(Map[String, String]) -> String` | 将 Map 序列化为 `.env` 格式字符串 |
| `diff` | `(Map[String, String], Map[String, String]) -> DiffResult` | 对比两个 Map，返回 added/removed/changed |
| `defaults` | `(Map[String, String], Map[String, String]) -> Map[String, String]` | 为缺失的键设置默认值 |
| `validate` | `(Map[String, String], Array[String]) -> Array[String]` | 校验必需 key，返回缺失列表 |
| `config` | `(String, env? : Map[String, String], force? : Bool) -> Map[String, String]` | 解析并合并环境变量，可选 force 覆盖 |
| `merge` | `(Map[String, String], Map[String, String], force? : Bool) -> Map[String, String]` | 合并两个 Map |
| `load_multi` | `(Array[String]) -> Map[String, String]` | 解析多个 `.env` 字符串并合并 |
| `config_multi` | `(Array[String], env? : Map[String, String], force? : Bool) -> Map[String, String]` | 多文件解析合并，可与外部 env 合并 |
| `populate` | `(Map[String, String], Map[String, String], force? : Bool) -> Int` | 将解析结果写入目标 Map，返回写入数量 |

## 许可证

Apache-2.0
