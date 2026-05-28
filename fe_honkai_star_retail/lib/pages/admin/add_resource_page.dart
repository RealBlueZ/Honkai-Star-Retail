import 'dart:convert';

import 'package:fe_honkai_star_retail/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddResourcePage extends StatefulWidget {
  const AddResourcePage({super.key});

  @override
  State<AddResourcePage> createState() => _AddResourcePageState();
}

class _AddResourcePageState extends State<AddResourcePage> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  final String baseUrl = "http://10.0.2.2:3000/api";
  final String adminToken = "n8x7wfqtsrvxnvsm8dcz";
  
  Future<void> addResource() async {
    setState(() => isSubmitting = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resources'),
        headers: {
          'Authorization': 'Bearer $adminToken', // Kirim Token Admin
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameController.text,
          'type': typeController.text,
          'description': "No description provided", // Isi deskripsi bawaan soal
          'stock': int.parse(stockController.text),
          'price': int.parse(priceController.text),
          'image': imageController.text,
        }),
      );

      if (response.statusCode == 201) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resource added successfully!")),
        );
        Navigator.pop(context, true); // Kembali ke dashboard dengan membawa sinyal sukses (true)
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? "Failed to save resource");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Resource")),

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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Stock is required";
                    }

                    if (int.tryParse(value) == null) {
                      return "Stock must be numeric";
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
                      return "Price is required";
                    }

                    if (int.tryParse(value) == null) {
                      return "Price must be numeric";
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
                      return "Image path is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              addResource(); // Jalankan fungsi simpan API ke server Express
                            }
                          },
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Add Resource", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
