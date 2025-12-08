import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseStatusWidget extends StatelessWidget {
  const FirebaseStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkFirebaseStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final status = snapshot.data ?? {};
        final isInitialized = status['initialized'] ?? false;
        final error = status['error'];
        final appsCount = status['appsCount'] ?? 0;

        if (isInitialized) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Firebase is configured!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Apps: $appsCount'),
                Text('Auth available: ${status['authAvailable'] ?? false}'),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Firebase not configured',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Apps count: $appsCount'),
              if (error != null) Text('Error: $error'),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _checkFirebaseStatus() async {
    try {
      final appsCount = Firebase.apps.length;
      bool authAvailable = false;

      if (appsCount > 0) {
        try {
          final auth = FirebaseAuth.instance;
          authAvailable = true;
        } catch (e) {
          // Auth not available
        }
      }

      return {
        'initialized': appsCount > 0,
        'appsCount': appsCount,
        'authAvailable': authAvailable,
      };
    } catch (e) {
      return {
        'initialized': false,
        'appsCount': 0,
        'error': e.toString(),
      };
    }
  }
}

