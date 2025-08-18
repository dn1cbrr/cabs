import 'package:flutter/material.dart';
import 'dart:async';

class VisualChairWidget extends StatefulWidget {
  final String seatId;
  final bool isAvailable;
  final String? userId;
  final Function(bool)? onStatusChanged;
  final bool showUserInfo;

  const VisualChairWidget({
    super.key,
    required this.seatId,
    required this.isAvailable,
    this.userId,
    this.onStatusChanged,
    this.showUserInfo = false,
  });

  @override
  State<VisualChairWidget> createState() => _VisualChairWidgetState();
}

class _VisualChairWidgetState extends State<VisualChairWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late bool _isAvailable;
  Timer? _pulseTimer;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.isAvailable;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: _isAvailable ? Colors.green : Colors.red,
      end: _isAvailable ? Colors.green : Colors.red,
    ).animate(_animationController);

    if (!_isAvailable) {
      _startPulseAnimation();
    }
  }

  @override
  void didUpdateWidget(VisualChairWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAvailable != widget.isAvailable) {
      setState(() {
        _isAvailable = widget.isAvailable;
      });
      
      _colorAnimation = ColorTween(
        begin: _colorAnimation.value,
        end: _isAvailable ? Colors.green : Colors.red,
      ).animate(_animationController);
      
      _animationController.forward(from: 0.0);
      
      if (_isAvailable) {
        _pulseTimer?.cancel();
      } else {
        _startPulseAnimation();
      }
    }
  }

  void _startPulseAnimation() {
    _pulseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _animationController.forward(from: 0.0);
      }
    });
  }

  void _toggleStatus() {
    setState(() {
      _isAvailable = !_isAvailable;
      _colorAnimation = ColorTween(
        begin: _colorAnimation.value,
        end: _isAvailable ? Colors.green : Colors.red,
      ).animate(_animationController);
      _animationController.forward(from: 0.0);
    });
    
    widget.onStatusChanged?.call(_isAvailable);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onStatusChanged != null ? _toggleStatus : null,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (_colorAnimation.value ?? Colors.grey).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.chair,
                  size: 40,
                  color: Colors.white,
                ),
                if (widget.showUserInfo && widget.userId != null)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.userId!.substring(0, 4),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isAvailable ? Colors.green[800] : Colors.red[800],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
