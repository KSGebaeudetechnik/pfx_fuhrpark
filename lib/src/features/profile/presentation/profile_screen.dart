import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/data/auth_repository.dart';
import '../data/fahrtenbuch_provider.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  DateTime selectedDate = DateTime.now();

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _pickDate(context),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 8),
              Text(
                "${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Fehler beim Laden des Benutzers: $e")),
        data: (user) {
          final fahrtenAsync = ref.watch(
            fahrtenbuchProvider((user.personalnummer.toString(), selectedDate)),
          );

          return fahrtenAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Fehler beim Laden: $e", style: TextStyle(color: Colors.black))),
            data: (fahrten) {
              if (fahrten.isEmpty) {
                return const Center(child: Text("Keine Fahrten für diesen Tag", style: TextStyle(color: Colors.black)));
              }

              return ListView.builder(
                itemCount: fahrten.length,
                itemBuilder: (context, index) {
                  final fahrt = fahrten[index];
                  return ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text("${fahrt.startOrt ?? "Start"} → ${fahrt.zielOrt ?? "Ziel"}", style: TextStyle(color: Colors.black)),
                    subtitle: Text(
                      "${fahrt.startzeit.hour}:${fahrt.startzeit.minute.toString().padLeft(2, '0')} – "
                          "${fahrt.stopzeit.hour}:${fahrt.stopzeit.minute.toString().padLeft(2, '0')}",
                     style: TextStyle(color: Colors.black)),
                    trailing: Text(
                      fahrt.strecke >= 1000
                          ? "${(fahrt.strecke / 1000).toStringAsFixed(1)} km"
                          : "${fahrt.strecke.toStringAsFixed(0)} m",
                     style: TextStyle(color: Colors.black)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
