import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../authentication/data/privatfahrt_repository.dart';
import '../objects/fahrzeug.dart';
import 'fahrzeug_repository.dart';
import '../../../utils/objectbox.dart'; // Enthält die globale `objectBox`-Instanz

/// Provider für das Repository
final fahrzeugRepositoryProvider = Provider<FahrzeugRepository>((ref) {
  return FahrzeugRepository(objectBox); // Nutzt zentrale Instanz
});

/// Holt Fahrzeuge aus der API und speichert sie lokal
final fahrzeugeProvider = FutureProvider.family<List<Fahrzeug>, String>((ref, userId) async {
  final repository = ref.watch(fahrzeugRepositoryProvider);
  return await repository.fetchAndStoreFahrzeuge(userId);
});

/// Gibt nur lokal gespeicherte Fahrzeuge (Offline-Modus)
final lokaleFahrzeugeProvider = Provider<List<Fahrzeug>>((ref) {
  final repository = ref.watch(fahrzeugRepositoryProvider);
  return repository.getLocalFahrzeuge();
});


final privatfahrtRepositoryProvider = Provider<PrivatfahrtRepository>((ref) {
  return PrivatfahrtRepository();
});