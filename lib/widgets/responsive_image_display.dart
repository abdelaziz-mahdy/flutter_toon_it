// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_toon_it/controllers/cartoonize_controller.dart';
import 'package:flutter_toon_it/widgets/animated_switcher_widget.dart';

/// Widget to display original and cartoonized images responsively
class ResponsiveImageDisplay extends StatelessWidget {
  final CartoonizeController controller;

  const ResponsiveImageDisplay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    if (isWideScreen) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Original Image
          Expanded(
            child: AnimatedSwitcherWidget(
              keyValue: 'originalImage',
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
              keyValue: 'cartoonImage',
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
                            child: Text("Cartoonized image will appear here"),
                          ),
                        ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          // Original Image
          AnimatedSwitcherWidget(
            keyValue: 'originalImage',
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
            keyValue: 'cartoonImage',
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
}
