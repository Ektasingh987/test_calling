import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CallControlButton extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final bool isActive;
  final bool isDanger;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double size;

  const CallControlButton({
    super.key,
    required this.icon,
    this.activeIcon,
    this.isActive = false,
    this.isDanger = false,
    required this.label,
    required this.onTap,
    this.color,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDanger
        ? AppTheme.callRed
        : isActive
            ? AppTheme.callMuted
            : (color ?? AppTheme.surface.withValues(alpha: 0.8));

    final iconColor = isDanger ? Colors.white : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              (isActive && activeIcon != null) ? activeIcon! : icon,
              color: iconColor,
              size: size * 0.44,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

