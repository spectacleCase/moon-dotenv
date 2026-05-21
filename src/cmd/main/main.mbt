///|
/// dotenv 使用示例
/// 运行: moon run cmd/main
fn main {
  let env_content = "DB_HOST=localhost\nDB_PORT=5432\nDB_URL=\"postgres://$DB_HOST:$DB_PORT/mydb\""
  let parsed = @lib.parse(env_content)
  let result = @lib.expand(parsed)
  for key, value in result {
    println("\{key}=\{value}")
  }
}
