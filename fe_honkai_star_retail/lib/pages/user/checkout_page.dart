import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fe_honkai_star_retail/providers/cart_provider.dart';

// Import AuthProvider atau state manajemen token kamu di sini jika ada
// import 'package:fe_honkai_star_retail/providers/auth_provider.dart';
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;

  // Fungsi untuk mengeksekusi pengiriman transaksi ke database backend
  Future<void> _processPayment(CartProvider cart) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String token = "n8x7wfqtsrvxnvsm8dcz";

      final response = await http.post(
        Uri.parse("http://localhost:3000/api/checkout"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "total_price": cart.totalPrice,
          "items": cart.items
              .map(
                (item) => {
                  "resource_id": item.resource.id,
                  "quantity": item.quantity,
                },
              )
              .toList(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text(
                    "Payment Success",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              content: const Text(
                "Thank you for purchasing resources!",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    cart.clearCart();
                    Navigator.pop(dialogContext);
                    Navigator.pop(context, true);
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.cyan)),
                ),
              ],
            );
          },
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorSnackBar(
          errorData['message'] ?? "Transaksi gagal diproses oleh server.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar("Gagal terhubung ke server. Pastikan koneksi aktif.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
                          child: Image.network(
                            "http://localhost:3000/images/${item.resource.image}",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white,
                                  ),
                                ),
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
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Rp ${item.resource.price} x ${item.quantity}",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Rp ${item.resource.price * item.quantity}",
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Payment",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        "Rp ${cart.totalPrice}",
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => _processPayment(cart),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
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
