import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class AddToilet extends StatefulWidget {
  final Function(Map<String, dynamic>) onToiletAdded; // Callback function

  const AddToilet({Key? key, required this.onToiletAdded}) : super(key: key);

  @override
  _AddToiletState createState() => _AddToiletState();
}

class _AddToiletState extends State<AddToilet> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  LatLng? _location;
  int _cleanlinessRating = 0;
  int _facilitiesRating = 0;
  bool _requiresKey = false;
  bool _requiresPurchase = false;

  Future<void> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _location = LatLng(locations.first.latitude, locations.first.longitude);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _submitToilet() {
    if (_businessNameController.text.isEmpty || _location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid name and location")),
      );
      return;
    }

    // Create toilet entry
    final newToilet = {
      'name': _businessNameController.text,
      'address': _addressController.text,
      'location': _location!,
      'cleanliness': _cleanlinessRating,
      'facilities': _facilitiesRating,
      'requiresKey': _requiresKey,
      'requiresPurchase': _requiresPurchase,
      'notes': _notesController.text,
    };

    // Pass the new toilet back to main.dart
    widget.onToiletAdded(newToilet);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Toilet')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address or Coordinates',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _getCoordinatesFromAddress,
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                child: _location == null
                    ? const Center(child: Text('Enter an address to see the location'))
                    : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _location!,
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('newToilet'),
                      position: _location!,
                    ),
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildRatingSection('Cleanliness:', (rating) {
                setState(() {
                  _cleanlinessRating = rating;
                });
              }, _cleanlinessRating),
              const SizedBox(height: 8),
              _buildRatingSection('Facilities:', (rating) {
                setState(() {
                  _facilitiesRating = rating;
                });
              }, _facilitiesRating),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Requires Key:'),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: _requiresKey,
                    onChanged: (bool? value) {
                      setState(() {
                        _requiresKey = value!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Requires Purchase:'),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: _requiresPurchase,
                    onChanged: (bool? value) {
                      setState(() {
                        _requiresPurchase = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitToilet,
                child: const Text("Add Toilet"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(String title, Function(int) onRatingSelected, int currentRating) {
    return Row(
      children: [
        Text(title),
        const SizedBox(width: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                onRatingSelected(index + 1);
              },
            );
          }),
        ),
      ],
    );
  }
}
