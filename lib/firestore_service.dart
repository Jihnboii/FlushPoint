import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new toilet to the global list
  Future<void> addToilet(Map<String, dynamic> toilet) async {
    await _db.collection('toilets').add(toilet);
  }

  // Get all toilets from Firestore
  Stream<List<Map<String, dynamic>>> getToilets() {
    return _db.collection('toilets').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList());
  }

  // Add or remove a toilet from the user's favorites
  Future<void> toggleFavorite(String toiletId, Map<String, dynamic> toiletData) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return; // No user is logged in

    DocumentReference favoriteRef = _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(toiletId);

    DocumentSnapshot snapshot = await favoriteRef.get();

    if (snapshot.exists) {
      // If the toilet is already in favorites, remove it
      await favoriteRef.delete();
    } else {
      // Otherwise, add it to favorites
      await favoriteRef.set(toiletData);
    }
  }

  // Get the current user's favorite toilets
  Stream<List<Map<String, dynamic>>> getUserFavorites() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty(); // No user logged in

    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id; // Store document ID for reference
      return data;
    }).toList());
  }
}
