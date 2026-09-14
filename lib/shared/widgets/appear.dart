import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';

class Appear extends StatefulWidget {
  const Appear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 14,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  factory Appear.stagger({
    Key? key,
    required Widget child,
    required int index,
    int stepMs = 50,
    double offset = 14,
  }) {
    return Appear(
      key: key,
      delay: Duration(milliseconds: index * stepMs),
      offset: offset,
      child: child,
    );
  }

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.normal);
    _fade = CurvedAnimation(parent: _controller, curve: AppMotion.curve);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offset / 80),
      end: Offset.zero,
    ).animate(_fade);
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
