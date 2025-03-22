import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addToilet(Map<String, dynamic> toilet) async {
    await _db.collection('toilets').add(toilet);
  }

  Stream<List<Map<String, dynamic>>> getToilets() {
    return _db.collection('toilets').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList());
  }
}
