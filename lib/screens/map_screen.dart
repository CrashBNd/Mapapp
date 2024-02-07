import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async'; // Importa dart:async para usar Timer

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? myPosition;
  late Timer _timer;
  double _previousLatitude = 0.0;
  double _previousLongitude = 0.0;
  static const double MIN_DISTANCE_CHANGE_FOR_UPDATE = 0.001;

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      // Calcula la distancia entre la nueva ubicación y la anterior
      double distanceChange = Geolocator.distanceBetween(
          _previousLatitude, _previousLongitude, latitude, longitude);

      // Si la distancia es mayor que el cambio mínimo, actualiza la ubicación
      if (distanceChange > MIN_DISTANCE_CHANGE_FOR_UPDATE) {
        setState(() {
          myPosition = LatLng(latitude, longitude);
          print(myPosition); // Imprime las coordenadas en la consola
          _previousLatitude = latitude;
          _previousLongitude = longitude;
        });
      }
    } catch (e) {
      print('Error obteniendo la ubicación: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Llama a getCurrentLocation inicialmente
    getCurrentLocation();
    // Llama a getCurrentLocation cada dos minutos
    _timer = Timer.periodic(Duration(minutes: 2), (timer) {
      getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mapa'),
        backgroundColor: Colors.blueAccent,
      ),
      body: myPosition == null
          ? const CircularProgressIndicator()
          : FlutterMap(
              options: MapOptions(
                center: myPosition,
                minZoom: 5,
                maxZoom: 25,
                zoom: 18,
              ),
              nonRotatedChildren: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: const {
                    'accessToken': MAPBOX_ACCESS_TOKEN,
                    'id': 'mapbox/streets-v12'
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: myPosition!,
                      width: 40,
                      height: 40,
                      anchorPos: AnchorPos.align(AnchorAlign.top),
                      builder: (context) => const Icon(
                        Icons.person_pin,
                        color: Colors.blueAccent,
                        size: 40,
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
