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
  List<ResourceModel> filteredResources = []; // Untuk menampung hasil pencarian
  bool isLoading = true;
  String errorMessage = '';
  final String baseUrl = "http://localhost:3000/api";

  // Controller untuk mendeteksi ketikan di Search Bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Menghilangkan duplikasi 'final' agar variabel 'response' di tingkat fungsi terisi
      final response = await http.get(Uri.parse('$baseUrl/resources'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'];
        setState(() {
          resources = dataList
              .map((json) => ResourceModel.fromJson(json))
              .toList();
          filteredResources =
              resources; // Set awal hasil filter sama dengan semua produk
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat produk (Status: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal terhubung ke server backend.';
        isLoading = false;
      });
    }
  }

  // Fungsi Filter untuk Search Bar (Validasi & Filter Lokal)
  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredResources = resources;
      } else {
        filteredResources = resources
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // Kumpulan halaman utama berdasarkan BottomNavigationBar
    final List<Widget> pages = [
      // HALAMAN UTAMA (HOME)
      isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
          : errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: fetchProducts,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  // SEARCH BAR (Sudah Berfungsi Aktif)
                  TextField(
                    controller: _searchController,
                    onChanged: _filterProducts,
                    decoration: InputDecoration(
                      hintText: "Search items (e.g. Stellar Jade)...",
                      prefixIcon: const Icon(Icons.search, color: Colors.cyan),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterProducts('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // DAFTAR PRODUK (GRID VIEW)
                  Expanded(
                    child: filteredResources.isEmpty
                        ? const Center(
                            child: Text(
                              "Product not found.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                ),
                            itemCount: filteredResources.length,
                            itemBuilder: (context, idx) {
                              final resource = filteredResources[idx];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(15),
                                            ),
                                        child: Image.network(
                                          "http://localhost:3000/images/${resource.image}",
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey,
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            resource.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Rp ${resource.price}",
                                            style: const TextStyle(
                                              color: Colors.cyan,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Stock: ${resource.stock}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.cyan,
                                                foregroundColor: Colors.black,
                                              ),
                                              onPressed: () async {
                                                // Menunggu sinyal balik true dari DetailPage jika terjadi checkout
                                                final shouldRefresh =
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailPage(
                                                              resource:
                                                                  resource,
                                                            ),
                                                      ),
                                                    );
                                                if (shouldRefresh == true) {
                                                  fetchProducts(); // Sinkronisasi otomatis jumlah stok baru
                                                }
                                              },
                                              child: const Text("Detail"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      // PAGES LAINNYA (Dinamis terhubung ke DB)
      const PurchasePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Honkai Star Retail"),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () async {
                  // Menunggu ketika user kembali dari CartPage
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );

                  if(result == true){
                  fetchProducts(); // Refresh data produk sepulang dari halaman cart/checkout
                  }
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
      body: IndexedStack(
        index: selectedIndex, 
        children: pages,
      ),
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
