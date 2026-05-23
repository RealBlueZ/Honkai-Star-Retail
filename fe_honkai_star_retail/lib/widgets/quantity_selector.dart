import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),

        border: Border.all(color: Colors.cyan, width: 1.5),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle, color: Colors.red),
          ),

          Text(
            quantity.toString(),

            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
