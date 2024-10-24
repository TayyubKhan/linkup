import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/core/repository/connection_repository.dart'; // For WidgetRef

final GetIt getIt = GetIt.instance;

void setupLocator(WidgetRef ref) {
  // Check if ConnectionRepositoryImplementation is already registered
  if (!getIt.isRegistered<ConnectionRepositoryImplementation>()) {
    // Register the ConnectionRepositoryImplementation with GetIt
    getIt.registerLazySingleton<ConnectionRepositoryImplementation>(
            () => ConnectionRepositoryImplementation(ref));
  }
}
