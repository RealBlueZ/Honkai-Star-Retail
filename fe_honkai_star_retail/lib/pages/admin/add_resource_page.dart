import 'package:fe_honkai_star_retail/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class AddResourcePage extends StatefulWidget {
  const AddResourcePage({super.key});

  @override
  State<AddResourcePage> createState() => _AddResourcePageState();
}

class _AddResourcePageState extends State<AddResourcePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Resource added successfully!"),
                          ),
                        );

                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Add Resource",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
