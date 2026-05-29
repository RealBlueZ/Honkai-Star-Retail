import 'dart:convert';
import 'dart:io';
import 'package:fe_honkai_star_retail/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  // Untuk keperluan produksi, token harus diambil dinamis dari halaman Login 
  // dan disimpan menggunakan SharedPreferences. 
  // Token di bawah ini di-hardcode sementara hanya untuk kebutuhan demonstrasi pengujian fitur Admin.
  
  final String baseUrl = "http://localhost:3000/api";
  final String adminToken = "n8x7wfqtsrvxnvsm8dcz";
  File? _selectedImage; // Variabel menampung file gambar dari galeri
final ImagePicker _picker = ImagePicker();

void _showSnackBar(String message, Color color) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}

Future<void> _pickImage() async {
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  
  if (pickedFile != null) {
    setState(() {
      _selectedImage = File(pickedFile.path);
    });
  }
}

Future<String?> _uploadImageToServer() async {
  if (_selectedImage == null) return null;

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/api/upload-image'),
    );

    request.headers['Authorization'] = 'Bearer n8x7wfqtsrvxnvsm8dcz';

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      ),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['filename'];
    } else {
      _showSnackBar("Upload gagal: ${response.body}", Colors.red);
      return null;
    }
  } catch (e) {
    _showSnackBar("Error upload gambar: $e", Colors.red);
    return null;
  }
}

  Future<void> addResource() async {

    if (_selectedImage == null) {
    _showSnackBar("Please select an image first", Colors.red);
    return;
  }
    setState(() => isSubmitting = true);

    try {
      String? serverFilename = await _uploadImageToServer();
      if (serverFilename == null) {
      _showSnackBar("Failed to upload image to server storage", Colors.red);
      return;
    }

      final response = await http.post(
        Uri.parse('$baseUrl/resources'),
        headers: {
          'Authorization': 'Bearer $adminToken', // Kirim Token Admin
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameController.text.trim(),
          'type': typeController.text.trim(),
          'description': "No description provided",
          'stock': int.tryParse(stockController.text.trim()) ?? 0,
          'price': int.tryParse(priceController.text.trim()) ?? 0,
          'image_url': serverFilename,
        }),
      );

      if (response.statusCode == 201) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resource added successfully!"),
          backgroundColor: Colors.green,
          ),
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
                Row(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedImage != null ? Colors.blue : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image_search, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.photo_library, size: 20),
                            label: const Text("Pilih Foto Barang"),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedImage != null 
                                ? "Gambar terpilih: ${_selectedImage!.path.split('/').last}" 
                                : "Belum ada foto yang dipilih",
                            style: TextStyle(
                              fontSize: 12, 
                              color: _selectedImage != null ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: _selectedImage != null ? FontWeight.bold : FontWeight.normal
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () {
                            // Validasi teks (Nama, Tipe, Stok, Harga)
                            if (_formKey.currentState!.validate()) {
                              // Validasi tambahan: Pastikan file gambar fisik sudah dipilih di HP
                              if (_selectedImage == null) {
                                _showSnackBar("Silakan pilih foto barang terlebih dahulu!", Colors.orange);
                                return;
                              }
                              
                              // Jika semua lolos, jalankan upload & insert ke MySQL
                              addResource(); 
                            }
                          },
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Add Resource", 
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
