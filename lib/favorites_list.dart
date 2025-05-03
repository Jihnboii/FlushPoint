import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'firestore_service.dart';
import 'toilet_details.dart';

class FavoritesList extends StatelessWidget {
  const FavoritesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.getUserFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.purple.shade300,
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 72,
                  color: Colors.purple.shade200,
                ),
                const SizedBox(height: 16),
                Text(
                  "No favorite toilets yet",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add toilets to your favorites to see them here",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        List<Map<String, dynamic>> favoritedToilets = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favoritedToilets.length,
          itemBuilder: (context, index) {
            var toilet = favoritedToilets[index];
            
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              toilet['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.favorite,
                            color: Colors.red.shade400,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.purple.shade300,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              toilet['address'],
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRatingIndicator(
                            context, 
                            "Cleanliness",
                            toilet['cleanliness'],
                            Colors.green,
                          ),
                          _buildRatingIndicator(
                            context,
                            "Access",
                            toilet['accessibility'],
                            Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildFeatureChip(
                            context,
                            "Key ${toilet['requiresKey'] ? "Required" : "Not Required"}",
                            toilet['requiresKey'] ? Icons.key : Icons.key_off,
                            toilet['requiresKey'] ? Colors.orange.shade700 : Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          _buildFeatureChip(
                            context,
                            "Purchase ${toilet['requiresPurchase'] ? "Required" : "Not Required"}",
                            toilet['requiresPurchase'] ? Icons.shopping_bag : Icons.money_off,
                            toilet['requiresPurchase'] ? Colors.orange.shade700 : Colors.green.shade700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildRatingIndicator(BuildContext context, String label, int rating, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating ? Colors.amber.shade600 : Colors.grey.shade400,
              size: 18,
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildFeatureChip(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
