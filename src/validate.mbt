///|
/// Check that all required keys are present in `map`.
/// Returns an array of missing keys. Empty array means all present.
pub fn validate(
  map : Map[String, String],
  required : Array[String],
) -> Array[String] {
  let missing : Array[String] = []
  for key in required {
    if !map.contains(key) {
      missing.push(key)
    }
  }
  missing
}
