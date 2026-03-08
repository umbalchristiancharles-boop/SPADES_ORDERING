// ============================================================================
// FIRESTORE SERVICE - Database Operations Helper
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/chicken_item_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get ordersCollection => _firestore.collection('orders');
  CollectionReference get inventoryCollection => _firestore.collection('inventory');

  // ==================== USER OPERATIONS ====================

  // Create or update user profile
  Future<void> saveUserProfile(String userId, Map<String, dynamic> userData) async {
    await usersCollection.doc(userId).set(userData, SetOptions(merge: true));
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    DocumentSnapshot doc = await usersCollection.doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // ==================== ORDER OPERATIONS ====================

  // Create a new order
  Future<String> createOrder({
    required String userId,
    required Map<String, int> items,
    required double total,
    String? deliveryArea,
  }) async {
    final DocumentReference orderRef = ordersCollection.doc();
    try {
      // Debug log
      // ignore: avoid_print
      print('FirestoreService.createOrder: saving order ${orderRef.id} for user $userId, items: $items, total: $total');

      await orderRef.set({
        'id': orderRef.id,
        'userId': userId,
        'items': items,
        'total': total,
        'deliveryArea': deliveryArea,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ignore: avoid_print
      print('FirestoreService.createOrder: saved order ${orderRef.id}');
      return orderRef.id;
    } catch (e, st) {
      // ignore: avoid_print
      print('FirestoreService.createOrder: failed to save order: $e');
      // Attach more context and rethrow
      throw Exception('createOrder failed: $e');
    }
  }

  // Get orders for a user
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel(
          id: data['id'] ?? doc.id,
          items: Map<String, int>.from(data['items'] ?? {}).map(
            (key, value) => MapEntry(int.parse(key), value),
          ),
          total: (data['total'] as num?)?.toDouble() ?? 0.0,
          date: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: data['status'] ?? 'Pending',
          deliveryArea: data['deliveryArea'],
        );
      }).toList();
    });
  }

  // Get all orders (for admin)
  Stream<List<OrderModel>> getAllOrders() {
    return ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel(
          id: data['id'] ?? doc.id,
          items: Map<String, int>.from(data['items'] ?? {}).map(
            (key, value) => MapEntry(int.parse(key), value),
          ),
          total: (data['total'] as num?)?.toDouble() ?? 0.0,
          date: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: data['status'] ?? 'Pending',
          deliveryArea: data['deliveryArea'],
        );
      }).toList();
    });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await ordersCollection.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== INVENTORY OPERATIONS ====================

  // Get inventory items
  Stream<List<ChickenItemModel>> getInventory() {
    return inventoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChickenItemModel(
          name: data['name'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          icon: _getIconFromString(data['icon']),
          stock: data['stock'] ?? 0,
          unit: data['unit'] ?? 'pcs',
        );
      }).toList();
    });
  }

  // Update inventory item stock
  Future<void> updateStock(String itemName, int newStock) async {
    QuerySnapshot query = await inventoryCollection
        .where('name', isEqualTo: itemName)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'stock': newStock});
    }
  }

  // Initialize default inventory if empty
  Future<void> initializeInventory() async {
    QuerySnapshot snapshot = await inventoryCollection.get();
    
    if (snapshot.docs.isEmpty) {
      List<ChickenItemModel> defaultItems = [
        ChickenItemModel(
          name: 'Whole Chicken',
          price: 15.99,
          icon: Icons.bakery_dining,
          stock: 50,
          unit: 'pcs',
        ),
        ChickenItemModel(
          name: 'Chicken Wings',
          price: 8.99,
          icon: Icons.fastfood,
          stock: 120,
          unit: 'pcs',
        ),
        ChickenItemModel(
          name: 'Chicken Legs',
          price: 7.99,
          icon: Icons.dinner_dining,
          stock: 80,
          unit: 'pcs',
        ),
        ChickenItemModel(
          name: 'Chicken Breast',
          price: 12.99,
          icon: Icons.set_meal,
          stock: 45,
          unit: 'pcs',
        ),
        ChickenItemModel(
          name: 'Chicken Thighs',
          price: 9.99,
          icon: Icons.restaurant,
          stock: 60,
          unit: 'pcs',
        ),
        ChickenItemModel(
          name: 'Chicken Combo Pack',
          price: 18.99,
          icon: Icons.lunch_dining,
          stock: 25,
          unit: 'sets',
        ),
      ];

      for (var item in defaultItems) {
        await inventoryCollection.add({
          'name': item.name,
          'price': item.price,
          'icon': item.icon.codePoint.toString(),
          'stock': item.stock,
          'unit': item.unit,
        });
      }
    }
  }

  // Helper to convert icon codePoint back to IconData
  IconData _getIconFromString(String? iconString) {
    if (iconString == null) return Icons.fastfood;
    final codePoint = int.tryParse(iconString);
    if (codePoint == null) return Icons.fastfood;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  // ==================== DASHBOARD STATS OPERATIONS ====================

  // Get count of active orders (Pending or Processing status)
  Future<int> getActiveOrdersCount() async {
    try {
      final QuerySnapshot snapshot = await ordersCollection
          .where('status', whereIn: ['Pending', 'Processing', 'In Progress'])
          .get();
      return snapshot.docs.length;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting active orders count: $e');
      return 0;
    }
  }

  // Get total stock of all inventory items
  Future<int> getTotalStock() async {
    try {
      final QuerySnapshot snapshot = await inventoryCollection.get();
      int totalStock = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalStock += (data['stock'] as int?) ?? 0;
      }
      return totalStock;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting total stock: $e');
      return 0;
    }
  }

  // Get today's revenue from orders placed today
  Future<double> getTodayRevenue() async {
    try {
      // Get start of today
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final QuerySnapshot snapshot = await ordersCollection
          .where('createdAt', isGreaterThan: Timestamp.fromDate(startOfDay))
          .get();
      
      double totalRevenue = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRevenue += (data['total'] as num?)?.toDouble() ?? 0.0;
      }
      return totalRevenue;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting today revenue: $e');
      return 0.0;
    }
  }

  // Stream for active orders count (real-time)
  Stream<int> getActiveOrdersCountStream() {
    return ordersCollection
        .where('status', whereIn: ['Pending', 'Processing', 'In Progress'])
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Stream for total stock (real-time)
  Stream<int> getTotalStockStream() {
    return inventoryCollection.snapshots().map((snapshot) {
      int totalStock = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalStock += (data['stock'] as int?) ?? 0;
      }
      return totalStock;
    });
  }

  // Stream for today's revenue (real-time)
  Stream<double> getTodayRevenueStream() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    return ordersCollection
        .where('createdAt', isGreaterThan: Timestamp.fromDate(startOfDay))
        .snapshots()
        .map((snapshot) {
      double totalRevenue = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRevenue += (data['total'] as num?)?.toDouble() ?? 0.0;
      }
      return totalRevenue;
    });
  }

  // ==================== FIRESTORE TEST METHOD ====================

  // Test method to verify Firestore connection
  Future<bool> testFirestoreWrite() async {
    try {
      final testCollection = _firestore.collection('test');
      await testCollection.add({
        'message': 'Hello Firestore',
        'time': DateTime.now(),
      });
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Firestore test write failed: $e');
      return false;
    }
  }
}


