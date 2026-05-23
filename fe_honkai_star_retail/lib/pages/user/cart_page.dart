import 'package:fe_honkai_star_retail/pages/user/checkout_page.dart';
import 'package:fe_honkai_star_retail/widgets/empty_cart.dart';
import 'package:fe_honkai_star_retail/widgets/quantity_selector.dart';
import 'package:fe_honkai_star_retail/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping Cart")),

      body: Provider.of<CartProvider>(context).items.isEmpty
          ? const EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: Provider.of<CartProvider>(context).items.length,
                    itemBuilder: (context, idx) {
                      final item = Provider.of<CartProvider>(
                        context,
                      ).items[idx];

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
                                          Provider.of<CartProvider>(
                                            context,
                                            listen: false,
                                          ).increaseQuantity(idx);
                                        });
                                      },
                                      onRemove: () {
                                        setState(() {
                                          if (item.quantity > 1) {
                                            Provider.of<CartProvider>(
                                              context,
                                              listen: false,
                                            ).decreaseQuantity(idx);
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
                                    Provider.of<CartProvider>(
                                      context,
                                      listen: false,
                                    ).removeItem(idx);
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

                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),

                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),

                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.black.withAlpha(30),
                      ),
                    ],
                  ),

                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "Total Price",

                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              "Rp ${cart.totalPrice}",

                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              foregroundColor: Colors.black,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CheckoutPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Checkout Now",
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
              ],
            ),
    );
  }
}
