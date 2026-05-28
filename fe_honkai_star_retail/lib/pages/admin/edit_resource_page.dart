import 'dart:convert';

import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:fe_honkai_star_retail/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditResourcePage extends StatefulWidget {
  final ResourceModel resource;

  const EditResourcePage({super.key, required this.resource});

  @override
  State<EditResourcePage> createState() => _EditResourcePageState();
}
class _EditResourcePageState extends State<EditResourcePage> {
  final _formKey = GlobalKey<FormState>();
  bool isUpdating = false;

  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController stockController;
  late TextEditingController priceController;
  late TextEditingController imageController;

  final String baseUrl = "http://10.0.2.2:3000/api";
  final String adminToken = "n8x7wfqtsrvxnvsm8dcz";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.resource.name);
    typeController = TextEditingController(text: widget.resource.type);
    stockController = TextEditingController(text: widget.resource.stock.toString());
    priceController = TextEditingController(text: widget.resource.price.toString());
    imageController = TextEditingController(text: widget.resource.image);
  }

  Future<void> updateResource() async {
    setState(() => isUpdating = true);
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/resources/${widget.resource.id}'), // Masukkan param ID barang
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameController.text,
          'type': typeController.text,
          'description': widget.resource.description,
          'stock': int.parse(stockController.text),
          'price': int.parse(priceController.text),
          'image': imageController.text,
        }),
      );

      if (response.statusCode == 200) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resource updated successfully!")),
        );
        Navigator.pop(context, true); // Sukses, kembalikan sinyal true untuk refresh dashboard
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? "Failed to update resource");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Resource")),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextfield(
                  controller: nameController,
                  labelText: "Resource Name",
                  icon: Icons.inventory,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Resource name is required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                CustomTextfield(
                  controller: typeController,
                  labelText: "Resource Type",
                  icon: Icons.category,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Resource type is required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                CustomTextfield(
                  controller: stockController,
                  labelText: "Stock",
                  icon: Icons.storage,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Stock must be filled";
                    }

                    if (int.tryParse(value) == null) {
                      return "Stock must be numbers";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                CustomTextfield(
                  controller: priceController,
                  labelText: "Price",
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Price must be filled";
                    }

                    if (int.tryParse(value) == null) {
                      return "Price must be numbers";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                CustomTextfield(
                  controller: imageController,
                  labelText: "Image Path",
                  icon: Icons.image,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Image is required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,

                  child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isUpdating ? null : () {
                      if (_formKey.currentState!.validate()) {
                        updateResource(); // Eksekusi PUT Request
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: isUpdating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Update Resource", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
            )],
            ),
          ),
        ),
      ),
    );
  }
}
