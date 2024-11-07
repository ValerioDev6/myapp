import 'dart:async';

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/conecction_util.dart';

final internetChecker = CheckInternetConnection();

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: HomeScreen(),
        bottomNavigationBar:
            const WarningWidgetValueNotifier(), // Aquí se coloca el widget de advertencia en el footer
      ),
    );
  }
}

class ConnectionStatusValueNotifier extends ValueNotifier<ConnectionStatus> {
  // Nos ayuda a mantener una suscripción con la
  // clase [CheckInternetConnection]
  late StreamSubscription _connectionSubscription;

  ConnectionStatusValueNotifier() : super(ConnectionStatus.online) {
    // Cada vez que se emite un nuevos estado actualizamos [value]
    // esto va hacer que nuestro widget se vuelva a construir.
    _connectionSubscription = internetChecker
        .internetStatus()
        .listen((newStatus) => value = newStatus);
  }

  @override
  void dispose() {
    // Cancelamos la subscription
    _connectionSubscription.cancel();
    super.dispose();
  }
}

class WarningWidgetValueNotifier extends StatelessWidget {
  const WarningWidgetValueNotifier({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ConnectionStatusValueNotifier(),
      builder: (context, ConnectionStatus status, child) {
        return Visibility(
          visible: status != ConnectionStatus.online,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 60,
            color: Colors.red,
            child: Row(
              children: [
                const Icon(Icons.wifi_off),
                const SizedBox(width: 8),
                const Text('No internet connection.'),
              ],
            ),
          ),
        );
      },
    );
  }
}
