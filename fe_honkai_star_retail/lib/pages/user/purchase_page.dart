import 'package:flutter/material.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Purchase History")),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.cyan),

              title: const Text("Stellar Jade"),

              subtitle: const Text("Purchased 2 items"),

              trailing: const Text("Rp 100000"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.cyan),

              title: const Text("Light Cone"),

              subtitle: const Text("Purchased 1 item"),

              trailing: const Text("Rp 150000"),
            ),
          ),
        ],
      ),
    );
  }
}
