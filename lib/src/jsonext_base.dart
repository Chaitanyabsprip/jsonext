import 'dart:convert';

/// Generic type for json
typedef Json<T extends Object?> = Map<String, T>;

/// Signature of Callbacks that accept json and return a value;
typedef FromJsonCallback<T extends Object?> = T Function(Json);

/// Empty json
const emptyJson = <String, Object?>{};

/// Extensions on [Json] type
extension JsonParse on Json {
  /// Try to get value at [key] as int. If the key does not exist or value is
  /// an invalid int, return [fallback].
  int asInt(String key, {int fallback = -1}) =>
      int.tryParse(this[key].toString()) ?? fallback;

  /// Try to get value at [key] as int. If the key does not exist or value
  /// is an invalid int, return null.
  int? asIntN(String key) => int.tryParse(this[key].toString());

  /// Try to get value at [key] as String. If the key does not exist or value
  /// is null, return [fallback].
  String asString(String key, {String fallback = ''}) =>
      this[key]?.toString() ?? fallback;

  /// Try to get value at [key] as String. If the key does not exist or value
  /// is null, return null.
  String? asStringN(String key) => this[key]?.toString();

  /// Try to get value at [key] as bool. If the key does not exist or value
  /// can't be converted to bool, return [fallback].
  bool asBool(String key, {bool fallback = false}) =>
      this.asBoolN(key) ?? fallback;

  /// Try to get value at [key] as bool. If the key does not exist or value
  /// can't be converted to bool, return null.
  bool? asBoolN(String key) {
    if (this[key] is bool) return this[key] as bool;

    final str = this[key]?.toString().toLowerCase();
    return str == 'true'
        ? true
        : str == 'false'
            ? false
            : null;
  }

  /// Try to get value at [key] as DateTime. If the key does not exist or value
  /// is an invalid DateTime, return [fallback]. If fallback is not passed,
  /// DateTime.now() is returned as a default value.
  DateTime asDateTime(String key, {DateTime? fallback}) {
    if (this[key] == null) return fallback ?? DateTime.now();
    return DateTime.tryParse(this[key].toString()) ??
        fallback ??
        DateTime.now();
  }

  /// Try to get value at [key] as DateTime. If the key does not exist or value
  /// is an invalid DateTime, return null.
  DateTime? asDateTimeN(String key) {
    if (this[key] == null) return null;
    return DateTime.tryParse(this[key].toString());
  }

  /// Try to get value at [key] as double. If the key does not exist or value
  /// is an invalid double, return [fallback].
  double asDouble(String key, {double fallback = -1}) =>
      double.tryParse(this[key].toString()) ?? fallback;

  /// Try to get value at [key] as double. If the key does not exist or value
  /// is an invalid double, return null.
  double? asDoubleN(String key) => double.tryParse(this[key].toString());

  /// Try to get value at [key] as Map. If the key does not exist or value is
  /// null, return [fallback].
  Map<K, T> asMap<K, T>(String key, {Map<K, T>? fallback}) {
    return (asMapN<K, T>(key) ?? fallback ?? <K, T>{}).cast<K, T>();
  }

  /// Try to get value at [key] as [Map<K, T>]. If the key does not exist or
  /// value is null, return null.
  Map<K, T>? asMapN<K, T>(String key) {
    if (this[key] is! Map?) {
      return null;
    }
    return (this[key] as Map?)?.cast<K, T>();
  }

  /// Try to get value at [key] as [Json<T>]. If the key does not exist or value
  /// is null, return [fallback].
  Json<T> asJson<T extends Object?>(String key, {Json<T>? fallback}) =>
      asMap<String, T>(key, fallback: fallback);

  /// Try to get value at [key] as [Json<T>]. If the key does not exist or value
  /// is null, return null.
  Json<T>? asJsonN<T extends Object?>(String key) => asMapN<String, T>(key);

  /// Try to get value at [key] as [List<T>]. If the key does not exist or value
  /// is null, return [fallback]. If fallback is null, then empty [List<T>] is
  /// returned.
  List<T> asList<T>(String key, {List<T>? fallback}) =>
      (asListN<T>(key) ?? fallback ?? <T>[]).cast<T>();

  /// Try to get value at [key] as [List<Json>]. If the key does not exist or
  /// value is null, return [fallback]. If fallback is null, then empty
  /// [List<Json>] is returned.
  List<Json> asJsonList(String key, {List<Json>? fallback}) =>
      asList<Json>(key, fallback: fallback);

  /// Try to get value at [key] as [List<Json>]. If the key does not exist or
  /// value is null, return null.
  List<T>? asListN<T>(String key) {
    if (this[key] is! List?) {
      return null;
    }
    return (this[key] as List?)?.cast<T>();
  }

  /// Try to get value at [key] as [List<Json>]. If the key does not exist or
  /// value is null, return null.
  List<Json>? asJsonListN(String key) => asListN<Json>(key);

  /// Check whether the json has a value for [key]
  bool has(String key) => this[key] != null;

  /// Passes the value at [key] to [parser] and returns the generated value. If
  /// the value at [key] is null or the parser callback throws an exception, it
  /// is passed through.
  T parse<T>(String key, FromJsonCallback<T> parser) {
    return parser(asJson(key));
  }

  /// Passes the value at [key] to [parser] and returns the generated value. If
  /// the value at [key] is null or the parser callback throws an exception,
  /// returns fallback.
  T? parseN<T>(String key, T Function(Json) parser, {T? fallback}) {
    try {
      return parser(asJson(key));
    } catch (e) {
      return fallback;
    }
  }
}

/// Extensions for decoding json
extension DecodeString on String {
  /// Decode string to [Json?].
  /// Json strings that start with '[' or are only lists are not supported.
  Json? get decode {
    assert(startsWith('{'), 'should be a non list json string');
    return jsonDecode(this) as Json?;
  }
}
