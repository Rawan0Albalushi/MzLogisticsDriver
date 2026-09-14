import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

class BrandMark extends StatefulWidget {
  const BrandMark({
    super.key,
    this.size = 72,
    this.pulse = false,
  });

  final double size;
  final bool pulse;

  @override
  State<BrandMark> createState() => _BrandMarkState();
}

class _BrandMarkState extends State<BrandMark>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(widget.size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.local_shipping_rounded,
        color: AppColors.white,
        size: widget.size * 0.48,
      ),
    );

    final controller = _controller;
    if (controller == null) return mark;

    return ScaleTransition(
      scale: Tween<double>(begin: 0.96, end: 1.04).animate(
        CurvedAnimation(parent: controller, curve: AppMotion.curve),
      ),
      child: mark,
    );
  }
}
