import 'dart:math';

import 'package:flutter/material.dart';

class FloatingBubble extends StatefulWidget {
  final String message;
  final dynamic timestamp;
  final VoidCallback onRemove;

  const FloatingBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.onRemove,
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _scaleController;
  late Animation<Offset> _floatingAnimation;
  late Animation<double> _scaleAnimation;

  double _initialX = 0;
  double _initialY = 0;
  Color _bubbleColor = Colors.pink.shade100;

  @override
  void initState() {
    super.initState();

    // Random initial position
    final random = Random();
    _initialX = random.nextDouble() * 300 + 50;
    _initialY = random.nextDouble() * 400 + 100;

    // Random bubble color
    List<Color> colors = [
      Colors.pink.shade100,
      Colors.purple.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.yellow.shade100,
    ];
    _bubbleColor = colors[random.nextInt(colors.length)];

    // Floating animation
    _floatingController = AnimationController(
      duration: Duration(seconds: 3 + random.nextInt(4)),
      vsync: this,
    );

    _floatingAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: Offset(
            (random.nextDouble() - 0.5) * 100,
            (random.nextDouble() - 0.5) * 150,
          ),
        ).animate(
          CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
        );

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _scaleController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _initialX,
      top: _initialY,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatingAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: _floatingAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: () {
                  // Add ripple effect on tap
                  setState(() {
                    _scaleController.forward().then((_) {
                      _scaleController.reverse();
                    });
                  });
                },
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                    minWidth: 100,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _bubbleColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
