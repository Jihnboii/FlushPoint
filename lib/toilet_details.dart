import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ToiletDetails extends StatelessWidget {
  final String businessName;
  final String address;
  final LatLng location;
  final int cleanliness;
  final int facilities;
  final bool requiresKey;
  final bool requiresPurchase;
  final String notes;

  const ToiletDetails({
    Key? key,
    required this.businessName,
    required this.address,
    required this.location,
    required this.cleanliness,
    required this.facilities,
    required this.requiresKey,
    required this.requiresPurchase,
    required this.notes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(businessName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                businessName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                address,
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: location,
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(businessName),
                      position: location,
                      infoWindow: InfoWindow(
                        title: businessName,
                        snippet: address,
                      ),
                    ),
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildRatingRow("Cleanliness:", cleanliness),
              const SizedBox(height: 8),
              _buildRatingRow("Facilities:", facilities),
              const SizedBox(height: 8),
              _buildCheckboxRow("Requires Key:", requiresKey),
              _buildCheckboxRow("Requires Purchase:", requiresPurchase),
              const SizedBox(height: 12),
              const Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(notes.isNotEmpty ? notes : "No notes provided"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, int rating) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(String label, bool value) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          color: value ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
