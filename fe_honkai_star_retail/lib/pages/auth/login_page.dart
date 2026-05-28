import 'dart:convert';

import 'package:fe_honkai_star_retail/services/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GoogleSignInService _googleSignIn = GoogleSignInService();

  bool obscurePassword = true;
  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    const String apiUrl = "http://localhost:3000/api/auth/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('bearer_token', responseData['token']);
        await prefs.setString('user_role', responseData['user']['role']);

        if (!mounted) return;

        String role = responseData['user']['role'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Login Berhasil!"),
            backgroundColor: Colors.green,
          ),
        );

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? "Email atau password salah.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 100,
                      color: Colors.purple,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Honkai Star Retail",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Galactic Resource Marketplace",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 40),

                    TextFormField(
                      controller: emailController,

                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                      ),

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
                        prefixIcon: const Icon(Icons.lock),

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },

                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
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
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            loginUser();
                          }
                        },

                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Login"),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },

                      child: const Text(
                        "Belum punya akun? Register",
                        style: TextStyle(color: Color(0xFF9400D3)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  await _googleSignIn.signOut();

                                  final googleUser = await _googleSignIn
                                      .signIn();

                                  if (googleUser == null) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Google sign-in canceled',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  const String nativeGoogleUrl =
                                      "http://localhost:3000/api/auth/google-native";

                                  final response = await http.post(
                                    Uri.parse(nativeGoogleUrl),
                                    headers: {
                                      "Content-Type": "application/json",
                                    },
                                    body: jsonEncode({
                                      "name":
                                          googleUser.displayName ??
                                          "Google User",
                                      "email": googleUser.email,
                                    }),
                                  );

                                  final Map<String, dynamic> responseData =
                                      jsonDecode(response.body);

                                  if (!mounted) return;

                                  if (response.statusCode == 200 &&
                                      responseData['success'] == true) {
                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                      'bearer_token',
                                      responseData['token'],
                                    );
                                    await prefs.setString(
                                      'user_role',
                                      responseData['user']['role'],
                                    );
                                    String role = responseData['user']['role'];

                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Welcome ${googleUser.displayName ?? 'User'}',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    if (role == 'admin') {
                                      navigator.pushReplacementNamed('/admin');
                                    } else {
                                      navigator.pushReplacementNamed('/home');
                                    }
                                  } else {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          responseData['message'] ??
                                              "Gagal otentikasi Google.",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text("Error Google Auth: $e"),
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
                              },

                        icon: Image.asset(
                          "assets/images/google_logo.webp",
                          height: 20,
                          width: 20,
                        ),

                        label: const Text(
                          "Login with Google",
                          style: TextStyle(color: Colors.black),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.grey),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
