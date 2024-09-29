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

/// Widget to handle animated transitions
class AnimatedSwitcherWidget extends StatelessWidget {
  final Widget child;
  final String keyValue;

  const AnimatedSwitcherWidget({
    Key? key,
    required this.child,
    required this.keyValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Widget to display original and cartoonized images responsively
class ResponsiveImageDisplay extends StatelessWidget {
  final CartoonizeController controller;

  const ResponsiveImageDisplay({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return isWideScreen
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Original Image
              Expanded(
                child: AnimatedSwitcherWidget(
                  keyValue: controller.originalImage != null
                      ? 'originalImage'
                      : 'noImage',
                  child: controller.originalImage != null
                      ? Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              controller.originalImage!,
                              // height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text("No image selected"),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 20),
              // Cartoonized Image or Loading Indicator
              Expanded(
                child: AnimatedSwitcherWidget(
                  keyValue: controller.isProcessing
                      ? 'loading'
                      : controller.cartoonImage != null
                          ? 'cartoonImage'
                          : 'noCartoonImage',
                  child: controller.isProcessing
                      ? Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : controller.cartoonImage != null
                          ? Stack(
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      controller.cartoonImage!,
                                      // height: 200,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                // // Positioned Save Button
                                // Positioned(
                                //   bottom: 8,
                                //   right: 8,
                                //   child: ElevatedButton.icon(
                                //     onPressed: () {
                                //       controller.saveCartoonImage(context);
                                //     },
                                //     icon: const Icon(Icons.save),
                                //     label: const Text("Save"),
                                //     style: ElevatedButton.styleFrom(
                                //       // primary: Colors.blueAccent.withOpacity(0.8),
                                //       padding: const EdgeInsets.symmetric(
                                //           horizontal: 12, vertical: 8),
                                //       textStyle:
                                //           const TextStyle(fontSize: 12),
                                //     ),
                                //   ),
                                // ),
                              ],
                            )
                          : Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child:
                                    Text("Cartoonized image will appear here"),
                              ),
                            ),
                ),
              ),
            ],
          )
        : Column(
            children: [
              // Original Image
              AnimatedSwitcherWidget(
                keyValue: controller.originalImage != null
                    ? 'originalImage'
                    : 'noImage',
                child: controller.originalImage != null
                    ? Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            controller.originalImage!,
                            // height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text("No image selected"),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              // Cartoonized Image or Loading Indicator
              AnimatedSwitcherWidget(
                keyValue: controller.isProcessing
                    ? 'loading'
                    : controller.cartoonImage != null
                        ? 'cartoonImage'
                        : 'noCartoonImage',
                child: controller.isProcessing
                    ? Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : controller.cartoonImage != null
                        ? Stack(
                            children: [
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    controller.cartoonImage!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // // Positioned Save Button
                              // Positioned(
                              //   bottom: 8,
                              //   right: 8,
                              //   child: ElevatedButton.icon(
                              //     onPressed: () {
                              //       controller.saveCartoonImage(context);
                              //     },
                              //     icon: const Icon(Icons.save),
                              //     label: const Text("Save"),
                              //     style: ElevatedButton.styleFrom(
                              //       primary: Colors.blueAccent.withOpacity(0.8),
                              //       padding: const EdgeInsets.symmetric(
                              //           horizontal: 12, vertical: 8),
                              //       textStyle: const TextStyle(fontSize: 12),
                              //     ),
                              //   ),
                              // ),
                            ],
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text("Cartoonized image will appear here"),
                            ),
                          ),
              ),
            ],
          );
  }
}

/// Widget for Sliders
class SlidersWidget extends StatelessWidget {
  const SlidersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CartoonizeController>(context);
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
}

/// Widget to display processing steps
class ProcessStepsView extends StatelessWidget {
  const ProcessStepsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CartoonizeController>(context);

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        controller.processSteps[index].outputImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
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
        // Get the screen width to determine layout orientation
        final screenWidth = MediaQuery.of(context).size.width;
        final isWideScreen = screenWidth > 600;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width:
                screenWidth > 800 ? 600 : screenWidth * 0.8, // Responsive width
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
                  // Responsive Layout
                  isWideScreen
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageWithLabel(
                                step.inputImage, "Input Image", 200),
                            const Icon(Icons.arrow_forward, size: 40),
                            _buildImageWithLabel(
                                step.outputImage, "Output Image", 200),
                          ],
                        )
                      : Column(
                          children: [
                            _buildImageWithLabel(
                                step.inputImage, "Input Image", 200),
                            const SizedBox(height: 10),
                            const Icon(Icons.arrow_downward, size: 40),
                            const SizedBox(height: 10),
                            _buildImageWithLabel(
                                step.outputImage, "Output Image", 200),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            image,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
