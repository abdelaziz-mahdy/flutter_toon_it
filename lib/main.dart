// lib/main.dart

import 'dart:typed_data';

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
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    // Original Image with AnimatedSwitcher
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: controller.originalImage != null
                          ? Container(
                              key: const ValueKey('originalImage'),
                              height: 200,
                              width: MediaQuery.sizeOf(context).width / 4 - 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.memory(
                                controller.originalImage!,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              key: const ValueKey('noImage'),
                              height: 200,
                              width: MediaQuery.sizeOf(context).width / 4 - 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text("No image selected"),
                              ),
                            ),
                    ),
                    // Cartoonized Image or Loading Indicator with AnimatedSwitcher
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: controller.isProcessing
                          ? Container(
                              key: const ValueKey('loading'),
                              height: 200,
                              width: MediaQuery.sizeOf(context).width / 4 - 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : controller.cartoonImage != null
                              ? Container(
                                  key: const ValueKey('cartoonImage'),
                                  height: 200,
                                  width:
                                      MediaQuery.sizeOf(context).width / 4 - 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.memory(
                                    controller.cartoonImage!,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  key: const ValueKey('noCartoonImage'),
                                  height: 200,
                                  width:
                                      MediaQuery.sizeOf(context).width / 4 - 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text(
                                        "Cartoonized image will appear here"),
                                  ),
                                ),
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
    final blurConfig = controller.blurSliderConfigs;
    final thresholdConfig = controller.thresholdSliderConfigs;

    return Column(
      children: [
        // Blur Sigma Slider
        Row(
          children: [
            const Text("Blur Sigma:"),
            Expanded(
              child: Slider(
                value: controller.blurSigma.toDouble(),
                min: blurConfig.minValue.toDouble(),
                max: blurConfig.maxValue.toDouble(),
                divisions: blurConfig.divisions,
                label: controller.blurSigma.toString(),
                onChanged: (value) async {
                  await controller.updateBlurSigma(context, value);
                },
              ),
            ),
            Text(controller.blurSigma.toString()),
          ],
        ),
        // Threshold Block Size Slider
        Row(
          children: [
            const Text("Threshold Block Size:"),
            Expanded(
              child: Slider(
                value: controller.thresholdValue.toDouble(),
                min: thresholdConfig.minValue.toDouble(),
                max: thresholdConfig.maxValue.toDouble(),
                divisions: thresholdConfig.divisions,
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
      height: 120,
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
                      fit: BoxFit.cover,
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

  void _showStepDialog(BuildContext context, ProcessStep step) {
    showDialog(
      context: context,
      builder: (context) {
        // Get the screen width to determine layout orientation
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isWideScreen = screenWidth > 600;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: screenWidth * 0.8, // Set width to 80% of screen width
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.stepName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // If the screen is wide, show images side-by-side
                  isWideScreen
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageWithLabel(step.inputImage, "Input Image",
                                screenWidth * 0.3),
                            const Icon(Icons.arrow_forward, size: 40),
                            _buildImageWithLabel(step.outputImage,
                                "Output Image", screenWidth * 0.3),
                          ],
                        )
                      // If the screen is narrow, show images stacked vertically
                      : Column(
                          children: [
                            _buildImageWithLabel(step.inputImage, "Input Image",
                                screenWidth * 0.7),
                            const SizedBox(height: 10),
                            const Icon(Icons.arrow_downward, size: 40),
                            const SizedBox(height: 10),
                            _buildImageWithLabel(step.outputImage,
                                "Output Image", screenWidth * 0.7),
                          ],
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Helper function to build the image and label widget
  Widget _buildImageWithLabel(Uint8List image, String label, double imageSize) {
    return Column(
      children: [
        Image.memory(
          image,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
