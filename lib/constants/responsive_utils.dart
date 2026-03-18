import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1200 && !Responsive.isMobile(context);
  
  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return const EdgeInsets.all(12);
    if (width < 1200) return const EdgeInsets.all(20);
    return const EdgeInsets.all(32);
  }
  
  static int gridCount(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobile;
    if (width < 1200) return tablet;
    return desktop;
  }
  
  static double kPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12;
    if (width < 1200) return 20;
    return 32;
  }

  static double fontScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 0.9;
    if (width < 1200) return 0.95;
    return 1.0;
  }
}
