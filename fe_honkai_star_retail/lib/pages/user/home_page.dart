import 'package:fe_honkai_star_retail/pages/user/cart_page.dart';
import 'package:fe_honkai_star_retail/pages/user/detail_page.dart';
import 'package:fe_honkai_star_retail/pages/user/profile_page.dart';
import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:fe_honkai_star_retail/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  //List<CartModel> cartItems = [];
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final List<ResourceModel> resources = [
      ResourceModel(
        id: 1,
        name: "Stellar Jade",
        type: "Currency",
        image: "assets/images/Stellar_Jade.webp",
        stock: 100,
        price: 45000,
      ),

      ResourceModel(
        id: 2,
        name: "Light Cone",
        type: "Weapon",
        image: "assets/images/Light_Cone.webp",
        stock: 25,
        price: 200000,
      ),

      ResourceModel(
        id: 3,
        name: "Credits",
        type: "Material",
        image: "assets/images/Credit.webp",
        stock: 550,
        price: 10000,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Honkai Star Retail"),

        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
              ),

              if (cart.items.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,

                  child: Container(
                    padding: const EdgeInsets.all(5),

                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),

                    child: Text(
                      cart.items.length.toString(),

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search resource...",
                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                itemCount: resources.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.45,
                ),
                itemBuilder: (context, idx) {
                  final resource = resources[idx];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    elevation: 5,

                    child: Padding(
                      padding: const EdgeInsets.all(10),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),

                            child: Image.asset(
                              resource.image,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            resource.name,

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

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
      ),
    );
  }
}
