import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Paquete para geolocalización inversa
import 'package:intl/intl.dart'; // Paquete para formatear fechas

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _location = 'Ubicación desconocida';
  String _address = 'Cargando dirección...';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'El servicio de ubicación está deshabilitado';
      });
      return;
    }

    // Verificar si los permisos de ubicación están concedidos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Permiso denegado';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Los permisos de ubicación están denegados permanentemente';
      });
      return;
    }

    // Obtener la ubicación actual
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
    });

    // Convertir coordenadas a dirección
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // Filtrar por el país si es necesario
    Placemark place = placemarks.firstWhere(
        (placemark) => placemark.country == 'Perú',
        orElse: () => placemarks[
            0] // Si no se encuentra Perú, toma el primer lugar disponible
        );

    setState(() {
      _address = '${place.locality}, ${place.country}'; // Ciudad y país
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubicación del Dispositivo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent, // Fondo azul de la AppBar
        elevation: 8,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: _getLocation, // Actualiza la ubicación al presionar
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _location,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Dirección:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _address,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Fecha y Hora:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Mostrar la fecha formateada según la localización
              Text(
                DateFormat.yMMMd('es_PE')
                    .add_jm()
                    .format(DateTime.now()), // Fecha y hora en formato peruano
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _getLocation,
                child: const Text('Actualizar Ubicación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
