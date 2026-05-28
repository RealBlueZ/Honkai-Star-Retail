import 'package:fe_honkai_star_retail/services/google_sign_in.dart';
import 'package:flutter/material.dart';

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

                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushNamed(context, '/home');
                          }
                        },

                        child: const Text("Login"),
                      ),
                    ),

                    //TEST BUTTON TO ADMIN PAGE
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/admin');
                        },

                        child: const Text("Login as Admin"),
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
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final user = await _googleSignIn.signIn();

                          if (!mounted) return;

                          if (user == null) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Google sign-in canceled'),
                              ),
                            );
                            return;
                          }

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Welcome ${user.displayName ?? 'User'}',
                              ),
                            ),
                          );

                          navigator.pushNamed('/home');
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
