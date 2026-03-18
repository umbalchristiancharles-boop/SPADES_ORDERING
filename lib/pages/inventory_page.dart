import 'package:flutter/material.dart';
import '../components/components.dart';
import '../models/chicken_item_model.dart';
import '../constants/responsive_utils.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = ChickenItemModel.getInventoryItems();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Module',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.gridCount(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final item = inventory[index];
              final stockLevel = item.stock;
              final isLowStock = stockLevel < 30;

              return GlowCard(
                glowColor: isLowStock ? Colors.red : Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isLowStock
                                ? Colors.red.withAlpha((0.2 * 255).toInt())
                                : Colors.green.withAlpha((0.2 * 255).toInt()),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isLowStock ? Colors.red : Colors.green,
                            ),
                          ),
                          child: Text(
                            isLowStock ? 'Low Stock' : 'In Stock',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2,
                          color: isLowStock ? Colors.red : Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${item.stock} ${item.unit}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isLowStock ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Low Stock Alert
          GlowCard(
            glowColor: Colors.red,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Low Stock Alert',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...inventory
                    .where((item) => item.stock < 30)
                    .map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                '${item.stock} ${item.unit}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        )),
                if (inventory.every((item) => item.stock >= 30))
                  const Text(
                    'All items are well stocked!',
                    style: TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

