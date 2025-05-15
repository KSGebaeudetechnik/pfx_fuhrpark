import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fahrtenbuch_repository.dart';
import '../objects/fahrt.dart';

final fahrtenbuchRepositoryProvider = Provider((ref) => FahrtenbuchRepository());

final fahrtenbuchProvider = FutureProvider.family<List<Fahrt>, (String userId, DateTime date)>((ref, params) async {
  final repository = ref.watch(fahrtenbuchRepositoryProvider);
  return await repository.fetchFahrtenbuch(params.$1, params.$2);
});