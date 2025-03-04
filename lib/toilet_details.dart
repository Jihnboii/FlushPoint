import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ToiletDetails extends StatelessWidget {
  final String businessName;
  final String address;
  final LatLng location;

  const ToiletDetails({
    Key? key,
    required this.businessName,
    required this.address,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(businessName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              businessName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(address),
            SizedBox(height: 8),
            Container(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: location,
                  zoom: 14,
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Cleanliness:'),
                SizedBox(width: 8),
                _buildRatingStars(),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Facilities:'),
                SizedBox(width: 8),
                _buildRatingStars(),
              ],
            ),
            SizedBox(height: 8),
            TextField(
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
        return Icon(
          Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }
}