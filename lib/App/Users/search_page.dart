import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  GoogleMapController? mapController;
  LatLng _defaultPosition = LatLng(
    23.8103,
    90.4125,
  ); // Temporary default (Dhaka)

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Forcefully request location permission and set position
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return _determinePosition();
    }

    LocationPermission permission;
    do {
      permission = await Geolocator.requestPermission();
    } while (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever);

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _defaultPosition = LatLng(position.latitude, position.longitude);
      pickupController.text =
          "Lat: ${position.latitude}, Lng: ${position.longitude}";
    });

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_defaultPosition, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
              _setMapStyle(isDarkMode);
              _determinePosition(); // Ensure the camera moves when the location is found
            },
            initialCameraPosition: CameraPosition(
              target: _defaultPosition,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // Input Fields
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildInputField(
                  "Pick-up Point",
                  Icons.my_location,
                  pickupController,
                  isDarkMode,
                ),
                SizedBox(height: 10),
                _buildInputField(
                  "Destination",
                  Icons.location_on,
                  destinationController,
                  isDarkMode,
                ),
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // Apply Google Map Style based on Theme
  void _setMapStyle(bool isDarkMode) async {
    if (mapController != null) {
      String darkMapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [{"color": "#212121"}]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#ffffff"}]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [{"color": "#424242"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [{"color": "#383838"}]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#ffffff"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [{"color": "#616161"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#f3f3f3"}]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [{"color": "#484848"}]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#ffffff"}]
      },
      {
        "featureType": "road.local",
        "elementType": "geometry",
        "stylers": [{"color": "#303030"}]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#ffffff"}]
      },
      {
        "featureType": "poi",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [{"color": "#000000"}]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#ffffff"}]
      }
    ]
    ''';

      String lightMapStyle = ""; // Default Google Map style
      mapController!.setMapStyle(isDarkMode ? darkMapStyle : lightMapStyle);
    }
  }

  Widget _buildInputField(
    String hint,
    IconData icon,
    TextEditingController controller,
    bool isDarkMode,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black54 : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          icon: Icon(icon, color: isDarkMode ? Colors.white : Colors.blue),
          hintText: hint,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white60 : Colors.black54,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
