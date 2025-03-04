import 'package:flutter/material.dart';
import 'package:flutter_setup/profile_page.dart';

import 'main.dart';

class FavoritesList extends StatelessWidget {
  const FavoritesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorited Toilets'),
      ),
      body: ListView.builder(
        itemCount: 5, // Placeholder for 5 favorited toilets
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Favorited Toilet ${index + 1}'),
            subtitle: Text('Business Name\nAddress: 123 Location St'),
            leading: const Icon(Icons.favorite),
            onTap: () {
              // Handle tap on favorited toilet
            },
          );
        },
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