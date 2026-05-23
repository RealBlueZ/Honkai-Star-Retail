import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fe_honkai_star_retail/providers/cart_provider.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            /// ORDER SUMMARY
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,

                itemBuilder: (context, idx) {
                  final item = cart.items[idx];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),

                          child: Image.asset(
                            item.resource.image,
                            width: 70,
                            height: 70,
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
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                "${item.quantity} x Rp ${item.resource.price}",

                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          "Rp ${item.resource.price * item.quantity}",

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// PAYMENT BOX
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),

                borderRadius: BorderRadius.circular(25),
              ),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Total Payment",

                        style: TextStyle(fontSize: 18, color: Colors.grey),
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

                  const SizedBox(height: 25),

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
                        showDialog(
                          context: context,

                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),

                              title: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),

                                  SizedBox(width: 10),

                                  Text("Payment Success"),
                                ],
                              ),

                              content: const Text(
                                "Thank you for purchasing resources!",
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () {
                                    cart.clearCart();

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },

                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },

                      child: const Text(
                        "Pay Now",

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
          ],
        ),
      ),
    );
  }
}
