import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
    });

  const String apiUrl = "http://10.0.2.2:3000/api/auth/register";

  try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201 && responseData['success'] == true) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Register berhasil!"),
            backgroundColor: Colors.green,
          ),
        );

        // Pindah ke halaman Login setelah berhasil
        Navigator.pushNamed(context, '/login');
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Gagal melakukan registrasi."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      // Server Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak dapat terhubung ke server: $error"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Username wajib diisi";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email wajib diisi";
                  }

                  if (!value.contains("@")) {
                    return "Email tidak valid";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,

                decoration: InputDecoration(
                  labelText: "Password",

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },

                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password wajib diisi";
                  }

                  if (value.length < 8) {
                    return "Password minimal 8 karakter";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Register berhasil")),
                      );

                      Navigator.pushNamed(context, '/login');
                    }
                  },

                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
