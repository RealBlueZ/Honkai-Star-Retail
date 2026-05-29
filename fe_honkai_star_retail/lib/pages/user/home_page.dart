import 'package:fe_honkai_star_retail/pages/user/cart_page.dart';
import 'package:fe_honkai_star_retail/pages/user/detail_page.dart';
import 'package:fe_honkai_star_retail/pages/user/profile_page.dart';
import 'package:fe_honkai_star_retail/pages/user/purchase_page.dart';
import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:fe_honkai_star_retail/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  List<ResourceModel> resources = [];
  bool isLoading = true;
  String errorMessage = '';
  final String baseUrl = "http://localhost:3000/api";

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    http.Response? response;
    try {
      response = await http.get(Uri.parse('$baseUrl/resources'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        final List<dynamic> responseData =
            decodedBody['data'] ?? decodedBody['resources'] ?? decodedBody;
        setState(() {
          resources = responseData
              .map((json) => ResourceModel.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat produk dari server';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal terhubung ke backend. Pastikan server aktif.';
        isLoading = false;
      });
    }
  }

  Widget _buildHomeContent() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : errorMessage.isNotEmpty
        ? Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          )
        : resources.isEmpty
        ? const Center(child: Text("Tidak ada produk tersedia"))
        : Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Available Resources",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: resources.length,
                    itemBuilder: (context, idx) {
                      final resource = resources[idx];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    "http://localhost:3000/images/${resource.image}",
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                resource.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                resource.type,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Text("Stock: ${resource.stock}"),
                              const Spacer(),
                              Text(
                                "Rp ${resource.price}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailPage(resource: resource),
                                      ),
                                    );
                                  },
                                  child: const Text("Detail"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final List<Widget> pages = [
      _buildHomeContent(),
      const PurchasePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Honkai Star Retail"), //
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                  fetchProducts();
                },
                icon: const Icon(Icons.shopping_cart),
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.items.length}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
