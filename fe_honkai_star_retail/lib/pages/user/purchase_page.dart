import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTransactionHistory();
  }

  Future<void> _fetchTransactionHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String token = "n8x7wfqtsrvxnvsm8dcz"; 
      
      // Kita arahkan ke /api/transactions
      final response = await http.get(
        Uri.parse("http://localhost:3000/api/transactions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        setState(() {
          if (decodedBody is Map<String, dynamic>) {
            _transactions = decodedBody['data'] ?? [];
          } else if (decodedBody is List) {
            _transactions = decodedBody;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load history (Status: ${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Connection error. Please check your server.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTransactionHistory,
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : _transactions.isEmpty
                  ? const Center(
                      child: Text(
                        "No transaction history found.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        
                        String itemsSummary = "Purchased items";
                        if (tx['items'] != null && (tx['items'] as List).isNotEmpty) {
                          final firstItem = tx['items'][0];
                          final itemCount = (tx['items'] as List).length;
                          itemsSummary = itemCount > 1 
                              ? "${firstItem['name'] ?? 'Item'} & ${itemCount - 1} other items"
                              : "${firstItem['name'] ?? 'Item'} (x${firstItem['quantity']})";
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.shopping_bag, color: Colors.cyan),
                            title: Text(
                              itemsSummary,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Date: ${tx['createdAt']?.toString().substring(0, 10) ?? 'Recent'}",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            trailing: Text(
                              "Rp ${tx['total_price'] ?? tx['total']}",
                              style: const TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}