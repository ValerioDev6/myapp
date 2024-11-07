import 'dart:async';
import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionStatus { online, offline }

class CheckInternetConnection {
  final Connectivity _connectivity = Connectivity();

  // El estado por defecto sera Online. Este controlador nos va
  // ayudar a emitir nuevos estados cuando la conexion cambie.
  final _controller = BehaviorSubject.seeded(ConnectionStatus.online);
  StreamSubscription? _connectionSubscription;

  CheckInternetConnection() {
    _checkInternetConnection();
  }

  // La clase [ConnectionStatusValueNotifier] va suscribirse a este Stream
  // y cuando la conexión cambie el status se va actualizar
  Stream<ConnectionStatus> internetStatus() {
    _connectionSubscription ??= _connectivity.onConnectivityChanged
        .listen((_) => _checkInternetConnection());
    return _controller.stream;
  }

  // Solución de stackoverflow
  Future<void> _checkInternetConnection() async {
    try {
      // Algunas veces, después de conectarnos a la red, esta función
      // se ejecuta cuando el dispositivo todavía no establece
      // conexión a internet. Este delay de 3 segundos le da tiempo
      // al dispositivo a conectarse y evitar falsos negativos.
      await Future.delayed(const Duration(seconds: 3));
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _controller.sink.add(ConnectionStatus.online);
      } else {
        _controller.sink.add(ConnectionStatus.offline);
      }
    } on SocketException catch (_) {
      _controller.sink.add(ConnectionStatus.offline);
    }
  }

  Future<void> close() async {
    // Cancelamos la suscripción y cerramos el controlador
    await _connectionSubscription?.cancel();
    await _controller.close();
  }
}
