import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'toilet_details.dart';
import 'add_toilet.dart';
import 'favorites_list.dart';
import 'profile_page.dart';
import 'firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlushPoint',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FlushPoint'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController _mapController;
  final LatLng _initialCameraPosition = const LatLng(37.7749, -122.4194); // San Francisco
  LatLng? _currentPosition;
  final List<Marker> _markers = [];

  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _toilets = [];
  Set<String> _favoriteToilets = {}; // Stores IDs of favorited toilets

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _setCurrentLocation();

    // Fetch toilets from Firestore when the app starts
    _firestoreService.getToilets().listen((toilets) {
      setState(() {
        _toilets = toilets;
        _setMarkers();
      });
    });
  }

  Future<void> _setCurrentLocation() async {
    Position position = await getCurrentLocation();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
  }

  void _toggleFavorite(String toiletId) {
    setState(() {
      if (_favoriteToilets.contains(toiletId)) {
        _favoriteToilets.remove(toiletId);
      } else {
        _favoriteToilets.add(toiletId);
      }
    });
  }

  void _setMarkers() {
    setState(() {
      _markers.clear();
      for (var toilet in _toilets) {
        _markers.add(
          Marker(
            markerId: MarkerId(toilet['name']),
            position: LatLng(toilet['location'].latitude, toilet['location'].longitude),
            infoWindow: InfoWindow(
              title: toilet['name'],
              snippet: toilet['address'],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.location_pin),
                  onPressed: () {
                    if (_currentPosition != null) {
                      _mapController.animateCamera(
                        CameraUpdate.newLatLng(_currentPosition!),
                      );
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search for toilets...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddToilet(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Google Maps view
          Container(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialCameraPosition,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: Set<Marker>.of(_markers),
            ),
          ),

          // List of toilets
          Expanded(
            child: ListView.builder(
              itemCount: _toilets.length,
              itemBuilder: (context, index) {
                var toilet = _toilets[index];
                String toiletId = toilet['id'];
                LatLng toiletLocation = LatLng(toilet['location'].latitude, toilet['location'].longitude);
                bool isFavorited = _favoriteToilets.contains(toiletId);

                return ListTile(
                  title: Text(toilet['name']),
                  subtitle: Text(toilet['address']),
                  onTap: () {
                    // Move the map to center on the toilet's location
                    _mapController.animateCamera(CameraUpdate.newLatLng(toiletLocation));
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Prevents row from taking full width
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () => _toggleFavorite(toiletId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ToiletDetails(
                                businessName: toilet['name'],
                                address: toilet['address'],
                                location: toiletLocation,
                                cleanliness: toilet['cleanliness'],
                                accessibility: toilet['accessibility'], // Changed from facilities
                                requiresKey: toilet['requiresKey'],
                                requiresPurchase: toilet['requiresPurchase'],
                                notes: toilet['notes'],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Bottom menu
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(title: 'FlushPoint'),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesList(
                  favoritedToilets: _toilets.where((toilet) => _favoriteToilets.contains(toilet['id'])).toList(),
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
        },
      ),
    );
  }
}
