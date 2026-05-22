///|
/// Set default values for keys that are missing in `map`.
///
/// Keys from `default_map` are only added when they do not already exist
/// in `map`. Returns a new map with defaults applied.
pub fn defaults(
  map : Map[String, String],
  default_map : Map[String, String],
) -> Map[String, String] {
  let result = Map([], capacity=map.length() + default_map.length())
  for k, v in map {
    result[k] = v
  }
  for k, v in default_map {
    if !result.contains(k) {
      result[k] = v
    }
  }
  result
}
