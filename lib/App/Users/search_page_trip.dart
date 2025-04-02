import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class SearchPageTrip extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPageTrip> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();

  GoogleMapController? mapController;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      pickupController.text =
          "Lat: ${position.latitude}, Lng: ${position.longitude}";
    });

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    }
  }

  Future<void> _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      dateTimeController.text = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).format(finalDateTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target:
                  _currentPosition != null
                      ? LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      )
                      : LatLng(23.8103, 90.4125), // Default to Dhaka
              zoom: 15,
            ),
            myLocationEnabled: true,
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
                ),
                SizedBox(height: 10),
                _buildInputField(
                  "Destination",
                  Icons.location_on,
                  destinationController,
                ),
                SizedBox(height: 10),
                _buildDateTimeField(
                  "Booking Date & Time",
                  Icons.calendar_today,
                  dateTimeController,
                ),
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Curve Style
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return GestureDetector(
      onTap: _selectDateTime, // Make entire field clickable
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Curve Style
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(
              child: AbsorbPointer(
                // Prevents keyboard from opening
                child: TextField(
                  controller: controller,
                  focusNode: AlwaysDisabledFocusNode(), // Disables text input
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom focus node to disable text input
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
