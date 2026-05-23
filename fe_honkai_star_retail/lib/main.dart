import 'package:fe_honkai_star_retail/pages/admin/admin_dashboard_page.dart';
import 'package:fe_honkai_star_retail/pages/auth/login_page.dart';
import 'package:fe_honkai_star_retail/pages/auth/register_page.dart';
import 'package:fe_honkai_star_retail/pages/user/home_page.dart';
import 'package:fe_honkai_star_retail/providers/cart_provider.dart';
import 'package:fe_honkai_star_retail/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Honkai Star Retail',

      theme: AppTheme.darkTheme,

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/admin': (context) => const AdminDashboardPage(),
      },
    );
  }
}
