import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'firestore_service.dart';
import 'toilet_details.dart';

class FavoritesList extends StatelessWidget {
  const FavoritesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorited Toilets')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getUserFavorites(), // ✅ Fetch from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No favorite toilets yet."));
          }

          List<Map<String, dynamic>> favoritedToilets = snapshot.data!;

          return ListView.builder(
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
          );
        },
      ),
    );
  }
}
