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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and address in a row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business name field
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _businessNameController,
                      decoration: InputDecoration(
                        labelText: 'Business Name',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Address field with search button
                  Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search, color: Colors.purple.shade400),
                          onPressed: () => _getCoordinatesFromAddress(_addressController.text),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Map area with reduced height
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _location == null
                    ? Center(
                    child: Text(
                        'Enter an address to see the location',
                        style: TextStyle(color: Colors.grey.shade600)
                    )
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: GoogleMap(
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
              ),

              const SizedBox(height: 12),

              // Ratings section - stacked vertically
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Ratings',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700
                        )
                    ),
                    const SizedBox(height: 8),

                    // Cleanliness rating
                    _buildRatingRow(
                        'Cleanliness:',
                            (rating) {
                          setState(() {
                            _cleanlinessRating = rating;
                          });
                        },
                        _cleanlinessRating
                    ),

                    const SizedBox(height: 12),

                    // Accessibility rating
                    _buildRatingRow(
                        'Accessibility:',
                            (rating) {
                          setState(() {
                            _accessibilityRating = rating;
                          });
                        },
                        _accessibilityRating
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Requirements in a row with chips
              Row(
                children: [
                  // Key requirement
                  Expanded(
                    child: _buildToggleChip(
                      'Requires Key',
                      Icons.key,
                      _requiresKey,
                          (value) {
                        setState(() {
                          _requiresKey = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Purchase requirement
                  Expanded(
                    child: _buildToggleChip(
                      'Requires Purchase',
                      Icons.shopping_bag,
                      _requiresPurchase,
                          (value) {
                        setState(() {
                          _requiresPurchase = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Notes field with reduced height
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Notes (optional)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Submit button - full width
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitToilet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                  )
                      : const Text(
                    "ADD TOILET",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow(String title, Function(int) onRatingSelected, int currentRating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.purple.shade700
            )
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                color: index < currentRating ? Colors.amber.shade600 : Colors.grey.shade400,
                size: 20,
              ),
              onPressed: () => onRatingSelected(index + 1),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              splashRadius: 20,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildToggleChip(String label, IconData icon, bool value, Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: value ? Colors.purple.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? Colors.purple.shade400 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: value ? Colors.purple.shade700 : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: value ? Colors.purple.shade700 : Colors.grey.shade800,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: value ? Colors.purple.shade700 : Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}
