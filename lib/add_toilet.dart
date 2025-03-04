import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddToilet extends StatelessWidget {
  const AddToilet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Toilet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Address or Coordinates',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              child: const GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.7749, -122.4194), // San Francisco coords
                  zoom: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Cleanliness:'),
                const SizedBox(width: 8),
                _buildRatingStars(),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Facilities:'),
                const SizedBox(width: 8),
                _buildRatingStars(),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Requires Key:'),
                const SizedBox(width: 8),
                Checkbox(value: false, onChanged: (bool? value) {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Requires Purchase:'),
                const SizedBox(width: 8),
                Checkbox(value: false, onChanged: (bool? value) {}),
              ],
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return const Icon(
          Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }
}