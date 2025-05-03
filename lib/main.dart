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
import 'splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlushPoint',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple.shade300),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.purple.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.purple.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade400,
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.purple.shade700,
            side: BorderSide(color: Colors.purple.shade300),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.purple.shade700,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.purple.shade400),
          ),
          focusColor: Colors.purple.shade400,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.purple.shade400;
            }
            return Colors.grey.shade400;
          }),
        ),
      ),
      home: const SplashPage(title: 'FlushPoint™'),
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
  
  // Keep track of the current page index
  int _currentPageIndex = 0;

  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _toilets = [];
  List<Map<String, dynamic>> _favoriteToilets = []; // Store favorite toilets

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _setCurrentLocation();

    // Fetch toilets from Firestore
    _firestoreService.getToilets().listen((toilets) {
      setState(() {
        _toilets = toilets;
        _setMarkers();
      });
    });

    // Fetch user's favorite toilets
    _firestoreService.getUserFavorites().listen((favorites) {
      setState(() {
        _favoriteToilets = favorites;
      });
    });
  }

  Future<void> _setCurrentLocation() async {
    Position position = await getCurrentLocation();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    if (_mapController != null && _currentPosition != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  void _toggleFavorite(String toiletId, Map<String, dynamic> toiletData) {
    _firestoreService.toggleFavorite(toiletId, toiletData);
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

  // Build different pages based on bottom navigation selection
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildHomePage();
      case 1:
        return const FavoritesList();
      case 2:
        return const ProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Column(
      children: <Widget>[
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.my_location,
                      color: Colors.purple.shade400,
                    ),
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
                      decoration: InputDecoration(
                        hintText: 'Search for toilets...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddToilet(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Google Maps view
        Container(
          height: 280,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialCameraPosition,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (_currentPosition != null) {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLng(_currentPosition!),
                  );
                }
              },
              markers: Set<Marker>.of(_markers),
            ),
          ),
        ),

        // Section Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Text(
                'Nearby Toilets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 2,
                width: 40,
                color: Colors.purple.shade300,
              ),
            ],
          ),
        ),

        // List of toilets
        Expanded(
          child: _toilets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.purple.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No toilets found nearby",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.purple.shade800,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _toilets.length,
                  itemBuilder: (context, index) {
                    var toilet = _toilets[index];
                    String toiletId = toilet['id'];
                    LatLng toiletLocation = LatLng(toilet['location'].latitude, toilet['location'].longitude);
                    bool isFavorited = _favoriteToilets.any((fav) => fav['id'] == toiletId);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _mapController.animateCamera(CameraUpdate.newLatLng(toiletLocation));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.purple.shade100,
                                radius: 24,
                                child: Icon(
                                  Icons.wc,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      toilet['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.purple.shade400,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            toilet['address'],
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: List.generate(5, (starIndex) {
                                        return Icon(
                                          starIndex < toilet['cleanliness'] ? Icons.star : Icons.star_border,
                                          color: Colors.amber.shade600,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isFavorited ? Icons.favorite : Icons.favorite_border,
                                      color: Colors.red.shade400,
                                    ),
                                    onPressed: () => _toggleFavorite(toiletId, toilet),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.info_outline,
                                      color: Colors.purple.shade400,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ToiletDetails(
                                            businessName: toilet['name'],
                                            address: toilet['address'],
                                            location: toiletLocation,
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _currentPageIndex == 0 ? [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              setState(() {
                _currentPageIndex = 1; // Switch to favorites page
              });
            },
          ),
        ] : null,
      ),
      body: _buildPage(_currentPageIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        selectedItemColor: Colors.purple.shade600,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
    );
  }
}
