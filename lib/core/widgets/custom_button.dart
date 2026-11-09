import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF6750A4),
    this.textColor = Colors.white,
    this.height = 54.0,
    this.width,
    this.fontSize = 16.0,
    this.fontWeight,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
  });

  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double? width;
  final double fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width ?? 0, height),
        fixedSize: width != null ? Size(width!, height) : null,
        padding: padding,
        backgroundColor: backgroundColor,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
