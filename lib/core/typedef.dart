// lib/core/typedef.dart
import 'package:fpdart/fpdart.dart';
import 'package:fusion/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<Unit>; // Using Unit for void success