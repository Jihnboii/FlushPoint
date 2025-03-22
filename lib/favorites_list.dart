import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'main.dart';
import 'toilet_details.dart';

class FavoritesList extends StatelessWidget {
  final List<Map<String, dynamic>> favoritedToilets;

  const FavoritesList({Key? key, required this.favoritedToilets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorited Toilets')),
      body: favoritedToilets.isEmpty
          ? const Center(child: Text("No favorite toilets yet."))
          : ListView.builder(
        itemCount: favoritedToilets.length,
        itemBuilder: (context, index) {
          var toilet = favoritedToilets[index];

          return ListTile(
            title: Text(toilet['name']),
            subtitle: Text(toilet['address']),
            leading: const Icon(Icons.favorite, color: Colors.red),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ToiletDetails(
                      businessName: toilet['name'],
                      address: toilet['address'],
                      location: LatLng(toilet['location'].latitude, toilet['location'].longitude),
                      cleanliness: toilet['cleanliness'],
                      accessibility: toilet['accessibility'],
                      requiresKey: toilet['requiresKey'],
                      requiresPurchase: toilet['requiresPurchase'],
                      notes: toilet['notes'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
