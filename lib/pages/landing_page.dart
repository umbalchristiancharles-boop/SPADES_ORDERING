// ============================================================================
// LANDING PAGE WITH DASHBOARD AND MAP/AREA SELECTION
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/components.dart';
import '../services/services.dart';
import 'order_page.dart';
import 'inventory_page.dart';
import 'profile_page.dart';

class LandingPage extends StatefulWidget {
  final String? userId;

  const LandingPage({super.key, this.userId});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;
  String? _selectedArea;
  String? _userEmail;

  final List<String> _areas = [
    'North Zone',
    'South Zone',
    'East Zone',
    'West Zone',
    'Central Zone',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize inventory in Firestore if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FirestoreService>().initializeInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;
    _userEmail = currentUser?.email ?? 'user@example.com';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: Row(
          children: [
            // Sidebar Navigation
            Container(
              width: 250,
              decoration: const BoxDecoration(
                color: Color(0xFF16213E),
                border: Border(
                  right: BorderSide(color: Colors.orange, width: 1),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Logo
                  const Icon(
                    Icons.restaurant_menu,
                    size: 60,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chicken Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'SYSTEM',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Navigation Items
                  _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                  _buildNavItem(1, Icons.shopping_cart, 'Orders'),
                  _buildNavItem(2, Icons.inventory, 'Inventory'),
                  _buildNavItem(3, Icons.person, 'Profile'),
                  const Spacer(),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: StyledButton(
                      text: 'Logout',
                      icon: Icons.logout,
                      color: Colors.red,
                      onPressed: () async {
                        await context.read<AuthService>().logout();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: _getPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.withAlpha((0.2 * 255).toInt()) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.orange, width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.orange : Colors.white70,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.orange : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const OrderPage();
      case 2:
        return const InventoryPage();
      case 3:
        return ProfilePage(userId: widget.userId);
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final firestoreService = context.read<FirestoreService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  // Firestore Test Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final firestoreService = context.read<FirestoreService>();
                      await firestoreService.testFirestoreWrite();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.cloud_upload, size: 18),
                    label: const Text('Test Firestore'),
                  ),
                  const SizedBox(width: 16),
                  // User Email Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _userEmail ?? 'user@example.com',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Stats Cards with Real-time Data from Firestore
          Row(
            children: [
              // Active Orders Card
              Expanded(
                child: StreamBuilder<int>(
                  stream: firestoreService.getActiveOrdersCountStream(),
                  builder: (context, snapshot) {
                    final activeOrders = snapshot.data ?? 0;
                    return GlowCard(
                      glowColor: Colors.green,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.green, size: 40),
                          const SizedBox(height: 16),
                          Text(
                            '$activeOrders',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Active Orders',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Items in Stock Card
              Expanded(
                child: StreamBuilder<int>(
                  stream: firestoreService.getTotalStockStream(),
                  builder: (context, snapshot) {
                    final totalStock = snapshot.data ?? 0;
                    return GlowCard(
                      glowColor: Colors.blue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.inventory_2, color: Colors.blue, size: 40),
                          const SizedBox(height: 16),
                          Text(
                            '$totalStock',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Items in Stock',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Today's Revenue Card
              Expanded(
                child: StreamBuilder<double>(
                  stream: firestoreService.getTodayRevenueStream(),
                  builder: (context, snapshot) {
                    final revenue = snapshot.data ?? 0.0;
                    return GlowCard(
                      glowColor: Colors.purple,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.attach_money, color: Colors.purple, size: 40),
                          const SizedBox(height: 16),
                          Text(
                            '\$${revenue.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Today\'s Revenue',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Map/Area Selection Section
          const Text(
            'Select Delivery Area',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Zone Map',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Click on an area to select for delivery',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),

                // Simple Area Representation (Grid)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _areas.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedArea == _areas[index];
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedArea = _areas[index]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSelected
                                  ? [Colors.orange, Colors.orangeAccent]
                                  : [const Color(0xFF0F3460), const Color(0xFF1A1A2E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.orange.withAlpha((0.3 * 255).toInt()),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.orange.withAlpha((0.5 * 255).toInt()),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: isSelected ? Colors.white : Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _areas[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isSelected)
                                const Text(
                                  'Selected',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                if (_selectedArea != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Text(
                          '$_selectedArea selected for delivery',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

