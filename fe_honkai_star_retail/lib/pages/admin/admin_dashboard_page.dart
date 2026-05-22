import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:fe_honkai_star_retail/pages/admin/add_resource_page.dart';
import 'package:fe_honkai_star_retail/pages/admin/edit_resource_page.dart';
import 'package:fe_honkai_star_retail/widgets/resource_card.dart';
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
      image: "assets/images/Stellar_Jade.webp",
      stock: 120,
      price: 50000,
    ),

    ResourceModel(
      id: 2,
      name: "Light Cone",
      type: "Weapon",
      image: "assets/images/Light_Cone.webp",
      stock: 30,
      price: 150000,
    ),

    ResourceModel(
      id: 3,
      name: "Credit",
      type: "Material",
      image: "assets/images/Credit.webp",
      stock: 550,
      price: 10000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddResourcePage()),
          );
        },

        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        itemCount: resources.length,
        itemBuilder: (context, idx) {
          final resource = resources[idx];

          return ResourceCard(
            resource: resource,

            onEdit: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => EditResourcePage(resource: resource),
                ),
              );
            },

            onDelete: () {
              showDialog(
                context: context,

                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete Resource"),

                    content: Text("Delete ${resource.name} ?"),

                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        child: const Text("Cancel"),
                      ),

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
          );
        },
      ),
    );
  }
}
