import 'package:flutter_messaging_app/repository/user_repository.dart';
import 'package:flutter_messaging_app/services/fake_auth_service.dart';
import 'package:flutter_messaging_app/services/firabase_auth_service.dart';
import 'package:flutter_messaging_app/services/firestore_db_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.asNewInstance();

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => FirestoreDBService());
  locator.registerLazySingleton(() => FakeAuthenticationService());
  locator.registerLazySingleton(() => UserRepository());
}
