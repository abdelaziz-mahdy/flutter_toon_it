// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_toon_it/controllers/cartoonize_controller.dart';
import 'package:provider/provider.dart';

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
