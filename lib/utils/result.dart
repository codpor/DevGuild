// lib/utils/result.dart
// Sealed class untuk error handling yang type-safe
// Menggantikan return bool dengan informasi error yang spesifik

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
}
