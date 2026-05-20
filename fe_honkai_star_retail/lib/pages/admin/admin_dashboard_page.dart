import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<ResourceModel> resources = [
    ResourceModel(
      id: 1,
      name: "Stellar Jade",
      type: "Currency",
      image: "assets/images/stellar_jade.webp",
      stock: 120,
      price: 50000,
    ),

    ResourceModel(
      id: 2,
      name: "Light Cone",
      type: "Weapon",
      image: "assets/images/light_cone.webp",
      stock: 30,
      price: 150000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},

        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        itemCount: resources.length,
        itemBuilder: (context, idx) {
          final resource = resources[idx];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),

                child: Image.asset(
                  resource.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),

              title: Text(resource.name),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(resource.type),

                  Text("Stock: ${resource.stock}"),

                  Text("Rp ${resource.price}"),
                ],
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, color: Colors.cyan),
                  ),

                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Delete Resource"),

                            content: Text("Delete ${resource.name}?"),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    resources.removeAt(idx);
                                  });

                                  Navigator.pop(context);
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
