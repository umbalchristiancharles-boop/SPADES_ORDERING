// ============================================================================
// ORDER MODULE PAGE
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/components.dart';
import '../models/chicken_item_model.dart';
import '../services/services.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final List<ChickenItemModel> _menuItems = ChickenItemModel.getMenuItems();
  final Map<int, int> _cart = {};
  final List<Map<String, dynamic>> _orders = [];
  bool _isSubmitting = false;

  void _addToCart(int index) {
    setState(() {
      _cart[index] = (_cart[index] ?? 0) + 1;
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cart[index]! > 1) {
        _cart[index] = _cart[index]! - 1;
      } else {
        _cart.remove(index);
      }
    });
  }

  double get _totalPrice {
    double total = 0;
    _cart.forEach((index, quantity) {
      total += _menuItems[index].price * quantity;
    });
    return total;
  }

  // Show success dialog after order placement
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withAlpha((0.5 * 255).toInt()),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha((0.2 * 255).toInt()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 64,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your order has been placed successfully.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'You can track it in the Dashboard.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 24),
                StyledButton(
                  text: 'OK',
                  color: Colors.green,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    if (_cart.isEmpty) return;
    if (_isSubmitting) return; // prevent double submissions
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.uid ?? 'unknown';
    final firestore = context.read<FirestoreService>();

    // Map items by name so Firestore stores readable keys
    final itemsForSave = Map<String, int>.fromEntries(
      _cart.entries.map((e) => MapEntry(_menuItems[e.key].name, e.value)),
    );

    // Ensure user is logged in before saving
    if (authService.currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to place an order.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      _isSubmitting = true;
      // Debug log prior to saving
      // ignore: avoid_print
      print('OrderPage: saving order for user $userId items=$itemsForSave total=$_totalPrice');

      final orderId = await firestore.createOrder(
        userId: userId,
        items: itemsForSave,
        total: _totalPrice,
      );

      // Log saved id
      // ignore: avoid_print
      print('OrderPage: order saved id=$orderId');

      if (!mounted) return;

      // Show successful confirmation dialog
      _showSuccessDialog();

      setState(() {
        _orders.add({
          'id': orderId,
          'items': Map.from(_cart),
          'total': _totalPrice,
          'date': DateTime.now(),
          'status': 'Pending',
        });
        _cart.clear();
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order saved (id: $orderId)'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Module',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          const Text(
            'Menu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return GlowCard(
                glowColor: Colors.orange,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 40, color: Colors.orange),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _cart[index] != null
                              ? () => _removeFromCart(index)
                              : null,
                          icon: const Icon(Icons.remove_circle),
                          color: Colors.orange,
                        ),
                        Text(
                          '${_cart[index] ?? 0}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () => _addToCart(index),
                          icon: const Icon(Icons.add_circle),
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Cart Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GlowCard(
                  glowColor: Colors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Cart',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_cart.isEmpty)
                        const Text(
                          'Cart is empty',
                          style: TextStyle(color: Colors.white70),
                        )
                      else
                        ..._cart.entries.map((entry) {
                          final item = _menuItems[entry.key];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.name} x${entry.value}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  '\$${(item.price * entry.value).toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                          );
                        }),
                      if (_cart.isNotEmpty) ...[
                        const Divider(color: Colors.white24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '\$${_totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: StyledButton(
                            text: _isSubmitting ? 'Placing...' : 'Place Order',
                            icon: Icons.shopping_cart_checkout,
                            onPressed: _isSubmitting ? null : () => _placeOrder(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Orders List
              Expanded(
                child: GlowCard(
                  glowColor: Colors.blue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Orders',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_orders.isEmpty)
                        const Text(
                          'No orders yet',
                          style: TextStyle(color: Colors.white70),
                        )
                      else
                        ..._orders.reversed.take(5).map((order) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.05 * 255).toInt()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${_orders.indexOf(order) + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withAlpha((0.2 * 255).toInt()),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        order['status'] as String,
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${(order['total'] as double).toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

