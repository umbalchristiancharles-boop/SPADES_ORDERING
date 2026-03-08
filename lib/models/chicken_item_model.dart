// ============================================================================
// CHICKEN ITEM MODEL
// ============================================================================

import 'package:flutter/material.dart';

class ChickenItemModel {
  final String name;
  final double price;
  final IconData icon;
  final int stock;
  final String unit;

  ChickenItemModel({
    required this.name,
    required this.price,
    required this.icon,
    this.stock = 0,
    this.unit = 'pcs',
  });

  static List<ChickenItemModel> getMenuItems() {
    return [
      ChickenItemModel(name: 'Whole Chicken', price: 15.99, icon: Icons.bakery_dining, stock: 50),
      ChickenItemModel(name: 'Chicken Wings (6pc)', price: 8.99, icon: Icons.fastfood, stock: 120),
      ChickenItemModel(name: 'Chicken Legs (4pc)', price: 7.99, icon: Icons.dinner_dining, stock: 80),
      ChickenItemModel(name: 'Chicken Breast', price: 12.99, icon: Icons.set_meal, stock: 45),
      ChickenItemModel(name: 'Chicken Thighs (4pc)', price: 9.99, icon: Icons.restaurant, stock: 60),
      ChickenItemModel(name: 'Chicken Combo', price: 18.99, icon: Icons.lunch_dining, stock: 25),
    ];
  }

  static List<ChickenItemModel> getInventoryItems() {
    return [
      ChickenItemModel(name: 'Whole Chicken', price: 15.99, icon: Icons.bakery_dining, stock: 50, unit: 'pcs'),
      ChickenItemModel(name: 'Chicken Wings', price: 8.99, icon: Icons.fastfood, stock: 120, unit: 'pcs'),
      ChickenItemModel(name: 'Chicken Legs', price: 7.99, icon: Icons.dinner_dining, stock: 80, unit: 'pcs'),
      ChickenItemModel(name: 'Chicken Breast', price: 12.99, icon: Icons.set_meal, stock: 45, unit: 'pcs'),
      ChickenItemModel(name: 'Chicken Thighs', price: 9.99, icon: Icons.restaurant, stock: 60, unit: 'pcs'),
      ChickenItemModel(name: 'Chicken Combo Pack', price: 18.99, icon: Icons.lunch_dining, stock: 25, unit: 'sets'),
    ];
  }
}

