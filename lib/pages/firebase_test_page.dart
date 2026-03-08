// ============================================================================
// FIREBASE TEST PAGE - For testing Auth and Firestore functionality
// ============================================================================
// This page can be used to test:
// 1. Email/Password Registration
// 2. Email/Password Login
// 3. Firestore User Profile Save/Read
// 4. Firestore Order Creation
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/services.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'test123456');
  final _nameController = TextEditingController(text: 'Test User');
  
  String _testResults = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addResult(String result) {
    setState(() {
      _testResults += '\n$result';
    });
  }

  void _clearResults() {
    setState(() {
      _testResults = '';
    });
  }

  // Test 1: Check Firebase Connection
  Future<void> testFirebaseConnection() async {
    _addResult('🔄 Testing Firebase Connection...');
    try {
      // Try to get current user (should be null if not logged in)
      final user = FirebaseAuth.instance.currentUser;
      _addResult('✅ Firebase Connection: OK (User: ${user?.email ?? "not logged in"})');
    } catch (e) {
      _addResult('❌ Firebase Connection Failed: $e');
    }
  }

  // Test 2: Test Registration
  Future<void> testRegistration() async {
    _addResult('🔄 Testing Registration...');
    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      await authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      _addResult('✅ Registration: SUCCESS');
    } catch (e) {
      _addResult('❌ Registration Failed: $e');
    }
    
    setState(() => _isLoading = false);
  }

  // Test 3: Test Login
  Future<void> testLogin() async {
    _addResult('🔄 Testing Login...');
    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      await authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      _addResult('✅ Login: SUCCESS');
    } catch (e) {
      _addResult('❌ Login Failed: $e');
    }
    
    setState(() => _isLoading = false);
  }

  // Test 4: Test Logout
  Future<void> testLogout() async {
    _addResult('🔄 Testing Logout...');
    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      await authService.logout();
      _addResult('✅ Logout: SUCCESS');
    } catch (e) {
      _addResult('❌ Logout Failed: $e');
    }
    
    setState(() => _isLoading = false);
  }

  // Test 5: Test Firestore User Profile Save
  Future<void> testFirestoreUserProfileSave() async {
    _addResult('🔄 Testing Firestore User Profile Save...');
    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      final user = authService.currentUser;
      if (user == null) {
        _addResult('❌ No user logged in. Please login first.');
        setState(() => _isLoading = false);
        return;
      }
      
      await firestoreService.saveUserProfile(user.uid, {
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'phone': '1234567890',
        'address': 'Test Address',
        'testTimestamp': DateTime.now().toIso8601String(),
      });
      
      _addResult('✅ User Profile Saved to Firestore');
    } catch (e) {
      _addResult('❌ Firestore Save Failed: $e');
    }
    
    setState(() => _isLoading = false);
  }

  // Test 6: Test Firestore User Profile Read
  Future<void> testFirestoreUserProfileRead() async {
    _addResult('🔄 Testing Firestore User Profile Read...');
    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      final user = authService.currentUser;
      if (user == null) {
        _addResult('❌ No user logged in. Please login first.');
        setState(() => _isLoading = false);
        return;
      }
      
      final profile = await firestoreService.getUserProfile(user.uid);
      
      if (profile != null) {
        _addResult('✅ User Profile Read: ${profile['name']} - ${profile['email']}');
      } else {
        _addResult('⚠️ User Profile not found');
      }
    } catch (e) {
      _addResult('❌ Firestore Read Failed: $e');
    }
    
    setState(() => _isLoading = false);
  }

  // Test 7: Test Firestore Order Creation
  Future<void> testFirestoreOrderCreate() async {
    _addResult('🔄 Testing Firestore Order Create...');
    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      final user = authService.currentUser;
      if (user == null) {
        _addResult('❌ No user logged in. Please login first.');
        setState(() => _isLoading = false);
        return;
      }
      
      final orderId = await firestoreService.createOrder(
        userId: user.uid,
        items: {'1': 2, '3': 1}, // Item IDs to quantities
        total: 29.97,
        deliveryArea: 'Test Area',
      );
      
      _addResult('✅ Order Created: $orderId');
    } catch (e) {
      _addResult('❌ Order Creation Failed: $e');
    }
    
    setState(() => _isLoading = false);
  }

  // Test 8: Run All Tests
  Future<void> runAllTests() async {
    _clearResults();
    await testFirebaseConnection();
    await testRegistration();
    await testFirestoreUserProfileSave();
    await testFirestoreUserProfileRead();
    await testFirestoreOrderCreate();
    await testLogout();
    _addResult('\n✅ ALL TESTS COMPLETED');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test Page'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Credentials Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Credentials',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Individual Test Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : testFirebaseConnection,
                  icon: const Icon(Icons.cloud),
                  label: const Text('Test Connection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : testRegistration,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Test Register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : testLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('Test Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : testLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Test Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Firestore Test Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : testFirestoreUserProfileSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Test Save Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : testFirestoreUserProfileRead,
                  icon: const Icon(Icons.download),
                  label: const Text('Test Read Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : testFirestoreOrderCreate,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Test Create Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Run All Tests Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : runAllTests,
              icon: const Icon(Icons.play_arrow),
              label: const Text('RUN ALL TESTS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            
            const SizedBox(height: 16),
            
            // Results Display
            Card(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Test Results:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: _clearResults,
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white54),
                    SelectableText(
                      _testResults.isEmpty ? 'No tests run yet...' : _testResults,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _testResults.contains('❌') 
                            ? Colors.red 
                            : _testResults.contains('✅')
                                ? Colors.green
                                : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions Card
            Card(
              color: Colors.amber.shade900,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ PREREQUISITES',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Before running tests, make sure:\n'
                      '1. Enable Email/Password in Firebase Console → Authentication → Sign-in method\n'
                      '2. Set Firestore Rules to allow read/write:\n'
                      '   allow read, write: if true;',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

