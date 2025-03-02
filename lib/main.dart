import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For Google Maps

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
  // Map controller
  late GoogleMapController _mapController;
  final LatLng _initialCameraPosition = const LatLng(37.7749, -122.4194); // San Francisco coords

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
                    // Handle location pin click
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
                    // Handle + button click
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
            ),
          ),

          // List of toilets (placeholders for now)
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder for 5 toilets
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Toilet ${index + 1}'),
                  subtitle: Text('Business Name\nAddress: 123 Location St'),
                  leading: const Icon(Icons.wc),
                  onTap: () {
                    // Handle toilet selection
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
          // Handle bottom navigation bar tap
        },
      ),
    );
  }
}
