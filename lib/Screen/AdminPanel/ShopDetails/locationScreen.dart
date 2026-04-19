import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMapPicker extends StatefulWidget {
  @override
  _OpenStreetMapPickerState createState() => _OpenStreetMapPickerState();
}

class _OpenStreetMapPickerState extends State<OpenStreetMapPicker> {
  LatLng selectedLocation = LatLng(18.5204, 73.8567); // Default: Pune

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pick Shop Location")),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                center: selectedLocation,
                zoom: 13.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    selectedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation,
                      width: 80,
                      height: 80,
                      child:  Icon(Icons.location_pin, color: Colors.red, size: 40) ,
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                child: Text("Confirm Location"),
                onPressed: () {
                  Navigator.pop(context, selectedLocation);
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
