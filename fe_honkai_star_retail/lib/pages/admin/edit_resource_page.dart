import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:fe_honkai_star_retail/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class EditResourcePage extends StatefulWidget {
  final ResourceModel resource;

  const EditResourcePage({super.key, required this.resource});

  @override
  State<EditResourcePage> createState() => _EditResourcePageState();
}

class _EditResourcePageState extends State<EditResourcePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController stockController;
  late TextEditingController priceController;
  late TextEditingController imageController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.resource.name);
    typeController = TextEditingController(text: widget.resource.type);
    stockController = TextEditingController(
      text: widget.resource.stock.toString(),
    );
    priceController = TextEditingController(
      text: widget.resource.price.toString(),
    );
    imageController = TextEditingController(text: widget.resource.image);
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

                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Resource updated successfully!"),
                          ),
                        );

                        Navigator.pop(context);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),

                      child: Text(
                        "Update Resource",
                        style: TextStyle(fontSize: 18),
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
