import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      locale: Locale('de'),
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
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: FilledButton(
            onPressed: () async {
              // Abmelden
              final authRepo = ref.read(authProvider.notifier);  // falls du im Widget Zugriff auf ref hast

              await authRepo.logout();

              // Danach zur Login-Seite navigieren
              context.push('/login'); // oder dein gewünschter Pfad
            },
            style: ButtonStyle(
              padding:
              WidgetStateProperty
                  .all(const EdgeInsets
                  .symmetric(
                  horizontal:
                  14.0)),
            backgroundColor: WidgetStateProperty.all<Color>(Colors.blueAccent)),
            child: Text("   Abmelden   ",
                style: Theme.of(context)
                    .textTheme
                    .labelSmall),
          ),
        ),],
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
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        // leading: Expanded(child: RotatedBox(child: Text("Kennzeichen"), quarterTurns: 3,)),
                          title: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "${(fahrt.startOrt ?? "Start").replaceAll(', Germany', '')} \n → ${(fahrt.zielOrt ?? "Ziel").replaceAll(', Germany', '')}",
                              style: const TextStyle(color: Colors.black, fontSize: 13.0),
                            ),
                          ),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Text(
                                "${fahrt.startzeit.hour}:${fahrt.startzeit.minute.toString().padLeft(2, '0')} – "
                                    "${fahrt.stopzeit.hour}:${fahrt.stopzeit.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(width: 50),
                              Text(
                                "${fahrt.stopzeit.difference(fahrt.startzeit).inHours}:"
                                    "${fahrt.stopzeit.difference(fahrt.startzeit).inMinutes.remainder(60).toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        trailing: Text(
                          fahrt.strecke >= 1000
                              ? "${(fahrt.strecke / 1000).toStringAsFixed(1)} km"
                              : "${fahrt.strecke.toStringAsFixed(0)} m",
                         style: TextStyle(color: Colors.black)),

                      ),
                    ),
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
