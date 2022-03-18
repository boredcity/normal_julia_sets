class Nullable<T> {
  const Nullable(this.value);
  final T? value;

  static T? getValueWithFallback<T>(Nullable<T>? nullable, [T? fallback]) {
    if (nullable != null) {
      return nullable.value;
    }
    return fallback;
  }
}
