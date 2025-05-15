import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../authentication/data/auth_repository.dart';
import '../data/fahrzeug_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      resizeToAvoidBottomInset: false,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (user) {
          final fahrzeugeAsync = ref.watch(fahrzeugeProvider(user.personalnummer.toString()));

          return fahrzeugeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (fahrzeuge) {
              return ListView.builder(
                itemCount: fahrzeuge.length + 1,
                itemBuilder: (context, index) {
                  if (index == fahrzeuge.length) return const SizedBox(height: 50);
                  final fzg = fahrzeuge[index];

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 35.0),
                            child: GestureDetector(
                              onTap: () {
                                context.push('/home/editFahrzeug',
                                    extra: fzg).then((value) => setState((){}));
                              },
                              child: fzg.imagePath != null
                                  ? Container(
                                width: 314,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18.0)),
                                  image: DecorationImage(
                                    image: FileImage(File(fzg.imagePath!)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                                  : Container(
                                width: 314,
                                height: 200,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(18.0)),
                                  // image: DecorationImage(
                                  //   image: AssetImage('images/placeholder-img.jpg'),
                                  //   fit: BoxFit.cover,
                                  // ),
                                  color: Colors.blueGrey
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 160),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Card(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.vertical(top: Radius.circular(18.0)),
                                    ),
                                    margin: EdgeInsets.zero,
                                    elevation: 0.0,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 15.0, 6.0),
                                      child: Text(
                                        fzg.name ?? "Unbekanntes Fahrzeug",
                                        style: Theme.of(context).textTheme.headlineMedium,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  CustomPaint(
                                    painter: InvertedRoundedRectanglePainter(
                                      color: Colors.white,
                                      radius: 15.0,
                                    ),
                                    child: const SizedBox(height: 15.0, width: 50.0),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Card(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(18.0),
                                        bottomLeft: Radius.circular(18.0),
                                        bottomRight: Radius.circular(18.0),
                                      ),
                                    ),
                                    margin: EdgeInsets.zero,
                                    elevation: 0.0,
                                    child: SizedBox(
                                      height: 112.0,
                                      width: 314,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18.0, vertical: 8.0),
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 3.0),
                                            Row(
                                              children: [
                                                Icon(Icons.schedule,
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    size: 23.0),
                                                const SizedBox(width: 4.0),
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                      fzg.gpsTimeString ?? "Zeit unbekannt",
                                                      style:
                                                      Theme.of(context).textTheme.displaySmall),
                                                ),
                                                const SizedBox(width: 8.0),
                                                Icon(Icons.pin_drop_outlined,
                                                    color: Theme.of(context).colorScheme.onSecondary,
                                                    size: 23.0),
                                                const SizedBox(width: 4.0),
                                                SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                      "${fzg.latitude?.toStringAsFixed(2) ?? "-"}, ${fzg.longitude?.toStringAsFixed(2) ?? "-"}",
                                                      style:
                                                      Theme.of(context).textTheme.displaySmall),
                                                ),
                                                const SizedBox(width: 9.0),
                                                RotatedBox(
                                                  quarterTurns: 1,
                                                  child: Icon(
                                                    Icons.battery_full,
                                                    color:
                                                    Theme.of(context).colorScheme.onSecondary,
                                                    size: 23.0,
                                                  ),
                                                ),
                                                const SizedBox(width: 4.0),
                                                SizedBox(
                                                  width: 40,
                                                  child: Text(
                                                    "${fzg.externalPower?.toStringAsFixed(1) ?? '-'} V",
                                                    style: Theme.of(context).textTheme.displaySmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2.0),
                                            Divider(color: Theme.of(context).colorScheme.outline),
                                            const SizedBox(height: 6.0),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 37.0,
                                                  child: OutlinedButton(
                                                    onPressed: () {
                                                      context.push('/home/editFahrzeug',
                                                          extra: fzg);
                                                    },
                                                    child: Text("Details",
                                                        style: Theme.of(context).textTheme.labelLarge),
                                                  ),
                                                ),
                                                const SizedBox(width: 7.0),
                                                SizedBox(
                                                  height: 37.0,
                                                  child: FilledButton(
                                                    onPressed: () {
                                                      // Maps oder Navigation öffnen
                                                    },
                                                    style: ButtonStyle(
                                                      padding:
                                                      MaterialStateProperty.all(
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 14.0)),
                                                    ),
                                                    child: Text("   Karte   ",
                                                        style: Theme.of(context).textTheme.labelSmall),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 35.0),
                            child: Card(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18.0),
                                  bottomLeft: Radius.circular(18.0),
                                ),
                              ),
                              margin: EdgeInsets.zero,
                              elevation: 0.0,
                              child: SizedBox(
                                height: 36.0,
                                width: 36.0,
                                child: Icon(
                                  fzg.ignition == true
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class InvertedRoundedRectanglePainter extends CustomPainter {
  InvertedRoundedRectanglePainter({
    required this.radius,
    required this.color,
  });

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cornerSize = Size.square(radius * 2);
    canvas.drawPath(
      Path()
        ..addArc(
          // top-left arc
          Offset(0, -radius) & cornerSize,
          // 180 degree startAngle (left of circle)
          pi,
          // -90 degree sweepAngle (counter-clockwise to the bottom)
          -pi / 2,
        )
      //   ..arcTo(
      //     // top-right arc
      //     Offset(size.width - cornerSize.width, -radius) & cornerSize,
      //     // 90 degree startAngle (bottom of circle)
      //     pi / 2,
      //     // -90 degree sweepAngle (counter-clockwise to the right)
      //     -pi / 2,
      //     false,
      //   )
      // // bottom right of painter
      //   ..lineTo(size.width, size.height)
      // bottom left of painter
        ..lineTo(0, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(InvertedRoundedRectanglePainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}

class InvertedRoundedRectanglePainterLeft extends CustomPainter {
  InvertedRoundedRectanglePainterLeft({
    required this.radius,
    required this.color,
  });

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cornerSize = Size.square(radius * 2);
    canvas.drawPath(
      Path()
        ..addArc(
          // top-left arc
          Offset(0, -radius) & cornerSize,
          // 180 degree startAngle (left of circle)
          0,
          // -90 degree sweepAngle (counter-clockwise to the bottom)
          pi / 2,
        )
      // bottom left of painter
        ..lineTo(cornerSize.width, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(InvertedRoundedRectanglePainterLeft oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}

