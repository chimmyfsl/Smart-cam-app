import 'package:flutter/material.dart';
import 'package:smart_cam_app/services/firebase_service.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  bool _firestoreConnected = false;
  bool _storageConnected = false;
  bool _authConnected = false;

  Future<void> _testFirebaseConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Firebase connection...';
    });

    try {
      // Test Authentication
      final authResult = await FirebaseService.signInAnonymously();
      if (authResult != null) {
        setState(() {
          _authConnected = true;
          _statusMessage = 'Authentication: ✅ Connected\n';
        });
      } else {
        setState(() {
          _authConnected = false;
          _statusMessage = 'Authentication: ❌ Failed\n';
        });
      }

      // Test Firestore
      final firestoreResult = await FirebaseService.testFirestoreConnection();
      setState(() {
        _firestoreConnected = firestoreResult;
        _statusMessage += 'Firestore: ${firestoreResult ? '✅ Connected' : '❌ Failed'}\n';
      });

      // Test Storage
      final storageResult = await FirebaseService.testStorageConnection();
      setState(() {
        _storageConnected = storageResult;
        _statusMessage += 'Storage: ${storageResult ? '✅ Connected' : '❌ Failed'}\n';
      });

      if (_authConnected && _firestoreConnected && _storageConnected) {
        _statusMessage += '\n🎉 All Firebase services are working correctly!';
      } else {
        _statusMessage += '\n⚠️ Some Firebase services failed. Check your configuration.';
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error testing Firebase: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Firebase Connection Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testFirebaseConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Testing...'),
                      ],
                    )
                  : const Text('Test Firebase Connection'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Results:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _statusMessage.isEmpty ? 'No tests run yet' : _statusMessage,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '1. Make sure you have created a Firebase project\n'
              '2. Download google-services.json and place it in android/app/\n'
              '3. Download GoogleService-Info.plist and place it in ios/Runner/\n'
              '4. Run this test to verify your Firebase connection',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
