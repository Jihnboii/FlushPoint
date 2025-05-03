import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isGuest = user == null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isGuest ? 'Guest User' : user?.displayName ?? 'User Name',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isGuest ? 'No email' : user?.email ?? 'user@example.com',
            style: TextStyle(color: Colors.purple.shade600),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.purple.shade400),
            title: const Text('Settings'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings not available yet')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.purple.shade400),
            title: const Text('About Us'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'FlushPoint',
                applicationVersion: '1.0.0',
                children: const [
                  Text('FlushPoint helps you find and share public restrooms.'),
                ],
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: Colors.purple.shade400),
            title: const Text('Feedback'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback form coming soon')),
              );
            },
          ),
          const Spacer(),
          if (!isGuest)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}
