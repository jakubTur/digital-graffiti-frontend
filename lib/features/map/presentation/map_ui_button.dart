import 'package:flutter/material.dart';

class MapUiButton extends StatelessWidget {
  final Function() onTap;

  final IconData icon;

  final String heroTag;

  const MapUiButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          heroTag: heroTag,
          backgroundColor: Colors.deepPurple,
          onPressed: onTap,
          child: Icon(icon, color: Colors.white, size: 65),
        ),
      ),
    );
  }
}
