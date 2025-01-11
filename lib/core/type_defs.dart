import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
//here T is the type of the data that we are going to return it can be anything like String, int, UserModel etc.
typedef FutureVoid = FutureEither< void>;
//here we are not returning anything for success so we are using void.but we are returning failure in case of error.