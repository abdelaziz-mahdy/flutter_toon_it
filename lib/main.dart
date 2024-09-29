// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/cartoonize_controller.dart';
import 'models/process_step.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
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
                Wrap(
                  children: [
                    SizedBox(
                      height: 200,
                      child: controller.originalImage != null
                          ? Image.memory(controller.originalImage!, height: 200)
                          : const Text("No image selected"),
                    ),
                    const SizedBox(height: 20, width: 20),
                    if (controller.isProcessing)
                      const CircularProgressIndicator(),
                    SizedBox(
                      height: 200,
                      child: controller.cartoonImage != null
                          ? Image.memory(
                              controller.cartoonImage!,
                              height: 200,
                            )
                          : const Text("Cartoonized image will appear here"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSliders(context, controller),
                const SizedBox(height: 20),
                _buildProcessStepsView(context, controller),
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

  /// Widget to display the sliders for configuration
  Widget _buildSliders(BuildContext context, CartoonizeController controller) {
    double blurMin = 0;
    double blurMax = 100;
    double thresholdMin = 2;
    double thresholdMax = 52;

    return Column(
      children: [
        Row(
          children: [
            const Text("Blur Sigma:"),
            Expanded(
              child: Slider(
                value: controller.blurSigma.toDouble(),
                min: blurMin,
                max: blurMax,
                divisions: (blurMax - blurMin).toInt(),
                label: controller.blurSigma.toString(),
                onChanged: (value) async {
                  await controller.updateBlurSigma(context, value);
                },
              ),
            ),
            Text(controller.blurSigma.toString()),
          ],
        ),
        Row(
          children: [
            const Text("Threshold Block Size:"),
            Expanded(
              child: Slider(
                value: controller.thresholdValue.toDouble(),
                min: thresholdMin,
                max: thresholdMax,
                divisions: (thresholdMax - thresholdMin).toInt(),
                label: controller.thresholdValue.toString(),
                onChanged: (value) async {
                  await controller.updateThresholdValue(context, value);
                },
              ),
            ),
            Text(controller.thresholdValue.toString()),
          ],
        ),
      ],
    );
  }

  /// Widget to display process steps (left-to-right)
  Widget _buildProcessStepsView(
      BuildContext context, CartoonizeController controller) {
    if (controller.processSteps.isEmpty) {
      return const Text("Processing steps will appear here.");
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.processSteps.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  _showStepDialog(context, controller.processSteps[index]);
                },
                child: Column(
                  children: [
                    Image.memory(
                      controller.processSteps[index].outputImage,
                      width: 80,
                      height: 80,
                    ),
                    Text(controller.processSteps[index].stepName),
                  ],
                ),
              ),
              if (index < controller.processSteps.length - 1)
                const Icon(Icons.arrow_forward, size: 30),
            ],
          );
        },
      ),
    );
  }

  /// Function to show a dialog with step input/output details
  void _showStepDialog(BuildContext context, ProcessStep step) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(step.stepName),
          content: Wrap(
            children: [
              Column(
                children: [
                  Image.memory(step.inputImage, height: 100),
                  const Text("Input Image"),
                ],
              ),
              const SizedBox(height: 10, width: 10),
              Column(
                children: [
                  Image.memory(step.outputImage, height: 100),
                  const Text("Output Image"),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
