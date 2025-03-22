import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class AddToilet extends StatefulWidget {
  const AddToilet({Key? key}) : super(key: key);

  @override
  _AddToiletState createState() => _AddToiletState();
}

class _AddToiletState extends State<AddToilet> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  LatLng? _location;
  int _cleanlinessRating = 0;
  int _accessibilityRating = 0;
  bool _requiresKey = false;
  bool _requiresPurchase = false;
  bool _isSaving = false; // Prevent duplicate submissions

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid address. Try again.")),
      );
    }
  }

  Future<void> _submitToilet() async {
    if (_businessNameController.text.isEmpty || _location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid name and location")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Convert `LatLng` to Firestore's `GeoPoint`
    final newToilet = {
      'name': _businessNameController.text,
      'address': _addressController.text,
      'location': GeoPoint(_location!.latitude, _location!.longitude),
      'cleanliness': _cleanlinessRating,
      'accessibility': _accessibilityRating,
      'requiresKey': _requiresKey,
      'requiresPurchase': _requiresPurchase,
      'notes': _notesController.text,
    };

    try {
      await _firestoreService.addToilet(newToilet);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Toilet added successfully!")),
      );
      Navigator.pop(context); // Close the page after adding
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving toilet: $e")),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
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
              _buildRatingSection('Accessibility:', (rating) {
                setState(() {
                  _accessibilityRating = rating;
                });
              }, _accessibilityRating),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Requires Key:'),
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
                onPressed: _isSaving ? null : _submitToilet,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text("Add Toilet"),
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
