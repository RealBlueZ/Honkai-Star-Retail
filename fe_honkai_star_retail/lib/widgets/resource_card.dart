import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:flutter/material.dart';

class ResourceCard extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: Image.asset(
                resource.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    resource.name,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Type: ${resource.type}",
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Stock: ${resource.stock}",
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Price: ${resource.price}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit"),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton.icon(
                        onPressed: onDelete,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),

                        icon: const Icon(Icons.delete),
                        label: const Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
