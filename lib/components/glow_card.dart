// ============================================================================
// GLOW CARD WIDGET - Reusable card with glow effect
// ============================================================================

import 'package:flutter/material.dart';

class GlowCard extends StatefulWidget {
  final Widget child;
  final double glowIntensity;
  final Color glowColor;
  final EdgeInsets padding;
  final double borderRadius;

  const GlowCard({
    super.key,
    required this.child,
    this.glowIntensity = 10.0,
    this.glowColor = Colors.orange,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 20,
  });

  @override
  State<GlowCard> createState() => _GlowCardState();
}

class _GlowCardState extends State<GlowCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.glowColor.withAlpha((0.4 * 255).toInt()),
                    blurRadius: widget.glowIntensity * 2,
                    spreadRadius: widget.glowIntensity / 2,
                  ),
                  BoxShadow(
                    color: widget.glowColor.withAlpha((0.2 * 255).toInt()),
                    blurRadius: widget.glowIntensity * 4,
                    spreadRadius: widget.glowIntensity,
                  ),
                ]
              : [
                  BoxShadow(
                    color: widget.glowColor.withAlpha((0.2 * 255).toInt()),
                    blurRadius: widget.glowIntensity,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
              ],
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _isHovered ? widget.glowColor : Colors.orange.withAlpha((0.3 * 255).toInt()),
              width: _isHovered ? 2 : 1,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

