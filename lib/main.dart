import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'toilet_details.dart';
import 'add_toilet.dart';
import 'favorites_list.dart';
import 'profile_page.dart';

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

  List<Map<String, dynamic>> _toilets = [];

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    Position position = await getCurrentLocation();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
  }

  void _addToilet(Map<String, dynamic> newToilet) {
    setState(() {
      _toilets.add(newToilet);
      _setMarkers();
    });
  }

  void _setMarkers() {
    setState(() {
      _markers.clear();
      for (var toilet in _toilets) {
        _markers.add(
          Marker(
            markerId: MarkerId(toilet['name']),
            position: toilet['location'],
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
                        builder: (context) => AddToilet(onToiletAdded: _addToilet),
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
                return ListTile(
                  title: Text(toilet['name']),
                  subtitle: Text(toilet['address']),
                  leading: const Icon(Icons.wc),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ToiletDetails(
                          businessName: toilet['name'],
                          address: toilet['address'],
                          location: toilet['location'],
                          cleanliness: toilet['cleanliness'],
                          facilities: toilet['facilities'],
                          requiresKey: toilet['requiresKey'],
                          requiresPurchase: toilet['requiresPurchase'],
                          notes: toilet['notes'],
                        ),
                      ),
                    );

                  },
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
                builder: (context) => const FavoritesList(),
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
