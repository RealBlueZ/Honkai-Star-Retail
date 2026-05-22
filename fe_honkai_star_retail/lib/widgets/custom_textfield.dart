import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      validator: validator,
    );
  }
}
