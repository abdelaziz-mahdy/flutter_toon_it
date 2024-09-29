// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_toon_it/widgets/process_steps_view.dart';
import 'package:flutter_toon_it/widgets/responsive_image_display.dart';
import 'package:flutter_toon_it/widgets/sliders_widget.dart';
import 'package:provider/provider.dart';
import 'controllers/cartoonize_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartoonizeController(),
      child: const CartoonizeApp(),
    ),
  );
}

class CartoonizeApp extends StatefulWidget {
  const CartoonizeApp({super.key});

  @override
  State<CartoonizeApp> createState() => _CartoonizeAppState();
}

class _CartoonizeAppState extends State<CartoonizeApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cartoonize App',
      themeMode: _themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cartoonize Image'),
          actions: [
            IconButton(
              icon: Icon(
                _themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              onPressed: () {
                setState(() {
                  _themeMode = _themeMode == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
                });
              },
            ),
          ],
        ),
        body: const CartoonizeHomePage(),
      ),
    );
  }
}

class CartoonizeHomePage extends StatelessWidget {
  const CartoonizeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartoonizeController>(
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                ResponsiveImageDisplay(controller: controller),
                const SizedBox(height: 20),
                const SlidersWidget(),
                const SizedBox(height: 20),
                const ProcessStepsView(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.pickImage(context),
                  child: const Text("Pick Image"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
