import 'package:fe_honkai_star_retail/models/cart_model.dart';
import 'package:fe_honkai_star_retail/widgets/quantity_selector.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final List<CartModel> cartItems;
  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int getTotalPrice() {
    int total = 0;

    for (var item in widget.cartItems) {
      total += item.resource.price * item.quantity;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping Cart")),

      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text("Cart is empty", style: TextStyle(fontSize: 18)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, idx) {
                      final item = widget.cartItems[idx];

                      return Card(
                        margin: const EdgeInsets.all(10),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(12),

                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),

                                child: Image.asset(
                                  item.resource.image,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.resource.name,

                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text("Rp ${item.resource.price}"),

                                    const SizedBox(height: 10),

                                    QuantitySelector(
                                      quantity: item.quantity,
                                      onAdd: () {
                                        setState(() {
                                          item.quantity++;
                                        });
                                      },
                                      onRemove: () {
                                        setState(() {
                                          if (item.quantity > 1) {
                                            item.quantity--;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    widget.cartItems.removeAt(idx);
                                  });
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: const BoxDecoration(
                    color: Colors.white,

                    boxShadow: [
                      BoxShadow(blurRadius: 5, color: Colors.black12),
                    ],
                  ),

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Total Price",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Checkout Success!"),
                              ),
                            );

                            setState(() {
                              widget.cartItems.clear();
                            });
                          },
                          child: const Text(
                            "Checkout",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
