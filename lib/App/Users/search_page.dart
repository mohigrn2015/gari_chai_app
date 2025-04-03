import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gari_chai/App/AppServices/home_page.dart';
import 'package:gari_chai/App/AppServices/services_page.dart';
import 'package:gari_chai/App/AppServices/activity_page.dart';
import 'package:gari_chai/App/AppServices/profile_page.dart';
import 'package:flutter/widgets.dart';
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/services.dart';
import 'dart:ui' as ui; // For image-related operations like ImageByteFormat

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  TextEditingController pickupController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  GoogleMapController? mapController;
  LatLng _defaultPosition = LatLng(23.8103, 90.4125); // Default: Dhaka
  Set<Marker> _markers = {};
  int _selectedIndex = 0;
  StreamSubscription<Position>? _locationSubscription;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  @override
  void dispose() {
    _locationSubscription?.cancel();
    mapController?.dispose();
    _animationController.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Animation for rotating and scaling the icon
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true); // Repeat the animation (like a shaking effect)

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.4, // Increased rotation range for better visibility
    ).animate(_animationController);

    // Scaling animation: make the icon grow and shrink
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2, // Adjust scale for better visibility
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startLocationUpdates(); // Start updating the location
  }

  // Start fetching the user's location periodically
  void _startLocationUpdates() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Update location when moved 10 meters
      ),
    ).listen((Position position) {
      _onLocationUpdated(position);
    });
  }

  // Location update callback
  void _onLocationUpdated(Position position) async {
    LatLng newPosition = LatLng(position.latitude, position.longitude);
    String locationName = await _getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    BitmapDescriptor customMarker = await _getCustomMarker();

    setState(() {
      pickupController.text = locationName;
      _defaultPosition = newPosition;

      _markers = {
        Marker(
          markerId: MarkerId("current_location"),
          position: newPosition,
          infoWindow: InfoWindow(title: "Your Location"),
          icon: customMarker, // Use the custom GIF as a marker icon
        ),
      };
    });

    // Apply animation (shake/rotate effect)
    _animationController.forward(from: 0.0); // Restart animation on each update
  }

  Future<BitmapDescriptor> _getCustomMarker() async {
    // Load the GIF from assets
    final ByteData data = await rootBundle.load(
      'assets/animations/locator.gif',
    );
    final Uint8List bytes = data.buffer.asUint8List();

    // Decode the GIF into an image
    final ui.Image image = await decodeImageFromList(bytes);

    // Resize the image (e.g., to 100x100 pixels)
    final resizedImage = await _resizeImage(image, 160, 160);

    // Convert the resized image to byte data in PNG format
    final ByteData? byteData = await resizedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    // Return the BitmapDescriptor using the resized image
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // Function to resize the image
  Future<ui.Image> _resizeImage(ui.Image image, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        Offset(0, 0),
        Offset(width.toDouble(), height.toDouble()),
      ),
    );

    // Draw the image on the canvas with the new size
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint(),
    );

    // End recording and return the resized image
    final picture = recorder.endRecording();
    final resizedImage = await picture.toImage(width, height);
    return resizedImage;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });

    String phoneNumber = "+8801932658719";
    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = HomePage();
        break;
      case 1:
        nextPage = ServicesPage(phoneNumber: phoneNumber);
        break;
      case 2:
        nextPage = ActivityPage(phoneNumber: phoneNumber);
        break;
      case 3:
        nextPage = ProfilePage(phoneNumber: phoneNumber);
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      String locationName = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Update the marker and the camera
      BitmapDescriptor customMarker = await _getCustomMarker();

      setState(() {
        pickupController.text = locationName;
        _defaultPosition = newPosition;

        _markers = {
          Marker(
            markerId: MarkerId("current_location"),
            position: newPosition,
            infoWindow: InfoWindow(title: "Your Location"),
            icon: customMarker, // Use the custom GIF as a marker icon
          ),
        };
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_defaultPosition, 15),
        );
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
              _setMapStyle(isDarkMode);
              _determinePosition();
            },
            initialCameraPosition: CameraPosition(
              target: _defaultPosition,
              zoom: 17,
            ),
            markers: _markers,
            myLocationEnabled: true,
            //myLocationButtonEnabled: true,
          ),
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
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 30,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          Positioned(
            top: 150, // Position the animated location icon
            left: 20,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value, // Apply rotation
                  child: Transform.scale(
                    scale: _scaleAnimation.value, // Apply scaling
                    child: Image.asset(
                      'assets/animations/locator.gif', // Load the GIF image
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _determinePosition,
        child: Icon(Icons.my_location, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Services"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Activity",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
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

  Future<String> _getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        return "Unknown location";
      }
    } catch (e) {
      print("Geocoding Error: $e");
      return "Unable to fetch location";
    }
  }
}
