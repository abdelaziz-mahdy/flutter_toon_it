// lib/main.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_toon_it/controllers/cartoonize_controller.dart';
import 'package:flutter_toon_it/models/process_step.dart';
import 'package:flutter_toon_it/widgets/animated_switcher_widget.dart';
import 'package:provider/provider.dart';

/// Widget to display processing steps
class ProcessStepsView extends StatelessWidget {
  const ProcessStepsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CartoonizeController>(context);

    return SizedBox(
      height: 120,
      child: AnimatedSwitcherWidget(
        keyValue: "Steps",
        child: controller.processSteps.isEmpty
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                    child: Text("Processing steps will appear here.")))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.processSteps.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showStepDialog(
                              context, controller.processSteps[index]);
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
