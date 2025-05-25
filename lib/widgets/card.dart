import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  final Color backgroundColor;
  final double borderRadius;
  final Widget child;
  final VoidCallback onTap;

  const ReusableCard({
    Key? key,
    this.backgroundColor = Colors.white,
    this.borderRadius = 12.0,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(color: backgroundColor, child: child),
      ),
    );
  }
}
