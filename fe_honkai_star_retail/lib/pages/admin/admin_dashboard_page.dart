import 'dart:convert';

import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:fe_honkai_star_retail/pages/admin/add_resource_page.dart';
import 'package:fe_honkai_star_retail/pages/admin/edit_resource_page.dart';
import 'package:fe_honkai_star_retail/widgets/resource_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<ResourceModel> resources = [];
  bool isLoading = true;

  // Untuk keperluan produksi, token harus diambil dinamis dari halaman Login 
  // dan disimpan menggunakan SharedPreferences. 
  // Token di bawah ini di-hardcode sementara hanya untuk kebutuhan demonstrasi pengujian fitur Admin.
  final String baseUrl = "http://localhost:3000/api";
  final String adminToken = "n8x7wfqtsrvxnvsm8dcz";

  @override
  void initState() {
    super.initState();
    fetchResources();
  }

  // GET DATA
  Future<void> fetchResources() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/resources'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];
        
        setState(() {
          resources = data.map((json) => ResourceModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load resources");
      }
    } catch (e) {
      if(!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }
  
  // DELETE DATA
  Future<void> deleteResource(int id, int index) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/resources/$id'),
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          resources.removeAt(index);
        });
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resource deleted successfully from DB!")),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? "Failed to delete");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddResourcePage()),
          );
          if (result == true) fetchResources();
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : resources.isEmpty
              ? const Center(child: Text("No items available."))
              : ListView.builder(
                  itemCount: resources.length,
                  itemBuilder: (context, idx) {
                    final resource = resources[idx];

                    return ResourceCard(
                      resource: resource,
                      onEdit: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditResourcePage(resource: resource),
                          ),
                        );
                        if (result == true) fetchResources();
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
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    deleteResource(resource.id, idx); // Eksekusi fungsi DELETE API
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