import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:fe_honkai_star_retail/pages/user/cart_page.dart';
import 'package:fe_honkai_star_retail/providers/cart_provider.dart';
import 'package:fe_honkai_star_retail/widgets/quantity_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final ResourceModel resource;

  const DetailPage({super.key, required this.resource});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    int totalPrice = widget.resource.price * quantity;

    return Scaffold(
      appBar: AppBar(title: Text(widget.resource.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  "http://localhost:3000/images/${widget.resource.image}",
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              Text(
                widget.resource.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.resource.type,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                "Available Stock: ${widget.resource.stock}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Divider(height: 30, thickness: 1),

              const Text(
                "Select Quantity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              QuantitySelector(
                quantity: quantity,

                onRemove: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },

                onAdd: () {
                  if (quantity < widget.resource.stock) {
                    setState(() {
                      quantity++;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Cannot exceed available stock!"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),

              const Divider(height: 40, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Price:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Rp $totalPrice",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                  onPressed: () async {
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).addToCart(widget.resource, quantity);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );

                    if (result == true) {
                      if (!mounted) return;
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "Buy Now",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).addToCart(widget.resource, quantity);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${widget.resource.name} added to cart"),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text("Add to Cart", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
