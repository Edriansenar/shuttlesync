import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The tiny bold label above the text field
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        
        // The actual text field
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF), 
              fontSize: 15,
              letterSpacing: obscureText ? 2.0 : 0.0, // Spaces out dots for passwords
            ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            
            // Only show prefix icon if one was provided
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: const Color(0xFF6B7280), size: 20) 
                : null,
                
            // Suffix icon is useful for the "eye" button on passwords
            suffixIcon: suffixIcon,
            
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}