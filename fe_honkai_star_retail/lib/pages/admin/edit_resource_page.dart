import 'dart:convert';
import 'dart:io';
import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:fe_honkai_star_retail/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  // Variabel untuk menampung berkas gambar baru dari galeri HP
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Konfigurasi jaringan searah dengan adb reverse localhost
  final String baseUrl = "http://localhost:3000/api";
  final String adminToken = "n8x7wfqtsrvxnvsm8dcz";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.resource.name);
    typeController = TextEditingController(text: widget.resource.type);
    stockController = TextEditingController(text: widget.resource.stock.toString());
    priceController = TextEditingController(text: widget.resource.price.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    stockController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // Fungsi pembantu untuk mempermudah pemanggilan SnackBar informasi
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Fungsi mengambil gambar dari penyimpanan internal HP Admin
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi Utama Eksekusi PUT Request Update Data ke MySQL
  Future<void> updateResource() async {
    setState(() => isUpdating = true);
    String finalImageName = widget.resource.image; // Secara default gunakan nama gambar lama

    final String nameToSend = nameController.text.trim();
    final String typeToSend = typeController.text.trim();
    final int stockToSend = int.tryParse(stockController.text) ?? 0;
    final int priceToSend = int.tryParse(priceController.text) ?? 0;
    final String imageToSend = (_selectedImage != null) ? finalImageName : widget.resource.image;
    try {
      // JIKA ADMIN MEMILIH GAMBAR BARU, UPLOAD GAMBAR TERLEBIH DAHULU
      if (_selectedImage != null) {
        final imageUploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/upload-image'),
        );

        imageUploadRequest.headers.addAll({
          "Authorization": "Bearer $adminToken",
        });

        imageUploadRequest.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );

        final streamedResponse = await imageUploadRequest.send();
        final imageResponse = await http.Response.fromStream(streamedResponse);

        if (imageResponse.statusCode == 200) {
          final Map<String, dynamic> uploadResult = json.decode(imageResponse.body);
          finalImageName = uploadResult['filename'];
        } else {
          _showSnackBar("Gagal mengunggah foto baru ke server", Colors.red);
          setState(() => isUpdating = false);
          return;
        }
      }

      // KIRIM REQUEST PUT UNTUK UPDATE DATA TEKS DAN IMAGE PATH KE DATABASE
      final response = await http.put(
        Uri.parse('$baseUrl/resources/${widget.resource.id}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $adminToken",
        },
        body: jsonEncode({
          "name": nameToSend,
          "type": typeToSend,
          "description": widget.resource.description,
          "stock": stockToSend,
          "price": priceToSend,
          "image": imageToSend, 
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Data resource berhasil diperbarui!", Colors.green);
        if (mounted) {
          Navigator.pop(context, true); // Kirim sinyal true agar dashboard otomatis refresh
        }
      } else {
        final Map<String, dynamic> errData = json.decode(response.body);
        debugPrint("Response Body: ${response.body}");
        _showSnackBar(errData['message'] ?? "Gagal memperbarui resource", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Kesalahan koneksi ke server.", Colors.red);
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Resource"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KOMPONEN PREVIEW & PEMILIHAN GAMBAR
                const Text(
                  "Resource Image",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.cyan, width: 1.5),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                          : widget.resource.image.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    "http://localhost:3000/images/${widget.resource.image}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.image, size: 50)),
                                  ),
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 40, color: Colors.cyan),
                                      SizedBox(height: 8),
                                      Text("Tap to change image", style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // VALIDASI & INPUT DATA TEXTFIELD
                CustomTextfield(
                  controller: nameController,
                  labelText: "Resource Name",
                  icon: Icons.shopping_bag,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Nama resource tidak boleh kosong";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextfield(
                  controller: typeController,
                  labelText: "Resource Type",
                  icon: Icons.category,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Tipe resource tidak boleh kosong";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextfield(
                  controller: stockController,
                  labelText: "Stock Amount",
                  icon: Icons.inventory,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Jumlah stok harus diisi";
                    if (int.tryParse(value.trim()) == null) return "Stok harus berupa angka valid";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextfield(
                  controller: priceController,
                  labelText: "Price (Rp)",
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Harga barang harus diisi";
                    if (int.tryParse(value.trim()) == null) return "Harga harus berupa angka valid";
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // TOMBOL SUBMIT PUT UPDATE
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isUpdating
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              updateResource();
                            }
                          },
                    child: isUpdating
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Update Resource",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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