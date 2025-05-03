import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ToiletDetails extends StatelessWidget {
  final String businessName;
  final String address;
  final LatLng location;
  final int cleanliness;
  final int accessibility;
  final bool requiresKey;
  final bool requiresPurchase;
  final String notes;

  const ToiletDetails({
    Key? key,
    required this.businessName,
    required this.address,
    required this.location,
    required this.cleanliness,
    required this.accessibility,
    required this.requiresKey,
    required this.requiresPurchase,
    required this.notes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(businessName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map container with location
            _buildMapSection(context),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business name and address
                  _buildHeaderSection(context),
                  
                  const SizedBox(height: 24),
                  
                  // Ratings section
                  _buildSectionTitle(context, "Ratings"),
                  const SizedBox(height: 12),
                  _buildRatingsSection(context),
                  
                  const SizedBox(height: 24),
                  
                  // Features section
                  _buildSectionTitle(context, "Features"),
                  const SizedBox(height: 12),
                  _buildFeaturesSection(context),
                  
                  const SizedBox(height: 24),
                  
                  // Notes section
                  _buildSectionTitle(context, "Notes"),
                  const SizedBox(height: 12),
                  _buildNotesSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.purple.shade400,
        label: const Text("Back to Map"),
        icon: const Icon(Icons.map),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: 15,
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
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          businessName,
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.purple.shade400,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                address,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 40,
          color: Colors.purple.shade300,
        ),
      ],
    );
  }
  
  Widget _buildRatingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildRatingRow("Cleanliness", cleanliness),
          const SizedBox(height: 16),
          _buildRatingRow("Accessibility", accessibility),
        ],
      ),
    );
  }
  
  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildFeatureRow("Key Required", requiresKey),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          _buildFeatureRow("Purchase Required", requiresPurchase),
        ],
      ),
    );
  }
  
  Widget _buildNotesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: notes.isNotEmpty
          ? Text(
              notes,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            )
          : Text(
              "No additional notes provided.",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
    );
  }

  Widget _buildRatingRow(String label, int rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.purple.shade700,
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating ? Colors.amber.shade600 : Colors.grey.shade400,
              size: 20,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.purple.shade700,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: value ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value ? Icons.check_circle : Icons.cancel,
                color: value ? Colors.red.shade400 : Colors.green.shade400,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                value ? "Yes" : "No",
                style: TextStyle(
                  color: value ? Colors.red.shade700 : Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
