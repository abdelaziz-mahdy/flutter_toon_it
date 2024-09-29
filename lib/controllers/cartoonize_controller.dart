// lib/controllers/cartoonize_controller.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/process_step.dart';
import '../services/cartoonize_service.dart';

class SliderConfigs {
  final int defaultValue;
  final int minValue;
  final int maxValue;
  final int step;

  SliderConfigs({
    required this.defaultValue,
    required this.minValue,
    required this.maxValue,
    this.step = 1,
  });

  /// Calculates the number of divisions based on step.
  int get divisions => ((maxValue - minValue) / step).round();
}

class CartoonizeController extends ChangeNotifier {
  final CartoonizeService _cartoonizeService = CartoonizeService();
  final ImagePicker _picker = ImagePicker();

  Uint8List? originalImage;
  Uint8List? cartoonImage;
  List<ProcessStep> processSteps = [];
  bool isProcessing = false;

  // Slider Configurations
  final SliderConfigs blurSliderConfigs =
      SliderConfigs(defaultValue: 0, minValue: 0, maxValue: 100, step: 2);
  final SliderConfigs thresholdSliderConfigs =
      SliderConfigs(defaultValue: 9, minValue: 3, maxValue: 51, step: 2);

  int blurSigma = 0;
  int thresholdValue = 9;

  // Debounce Timer
  Timer? _debounceTimer;
  static const Duration debounceDuration = Duration(milliseconds: 200);

  /// Picks an image from the gallery and starts the cartoonization process.
  Future<void> pickImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      originalImage = await pickedFile.readAsBytes();
      cartoonImage = null; // Reset the cartoonized image
      processSteps = [];
      notifyListeners();
      await applyCartoonize(context, originalImage!);
    }
  }

  /// Applies the cartoonization process using the service.
  Future<void> applyCartoonize(
      BuildContext context, Uint8List imageBytes) async {
    isProcessing = true;
    processSteps = [];
    notifyListeners();

    try {
      final cartoonized = await _cartoonizeService.applyCartoonize(
        imageBytes: imageBytes,
        blurSigma: blurSigma,
        thresholdValue: thresholdValue,
        processSteps: processSteps,
      );
      cartoonImage = cartoonized;
    } catch (e) {
      // Handle errors by showing a dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  /// Updates the blur sigma and re-applies cartoonization with debounce.
  Future<void> updateBlurSigma(BuildContext context, double value) async {
    blurSigma = value.toInt();
    // Ensure blurSigma is odd if greater than 0
    if (blurSigma > 0 && blurSigma % 2 == 0) {
      blurSigma += 1;
      if (blurSigma > blurSliderConfigs.maxValue) {
        blurSigma -= 2; // Adjust if exceeds maxValue
      }
    }
    notifyListeners();
    _debounceApplyCartoonize(context);
  }

  /// Updates the threshold value and re-applies cartoonization with debounce.
  Future<void> updateThresholdValue(BuildContext context, double value) async {
    thresholdValue = value.toInt();
    // Ensure thresholdValue is odd and >=3
    if (thresholdValue % 2 == 0) {
      thresholdValue += 1;
      if (thresholdValue > thresholdSliderConfigs.maxValue) {
        thresholdValue -= 2; // Adjust if exceeds maxValue
      }
    }
    if (thresholdValue < thresholdSliderConfigs.minValue) {
      thresholdValue = thresholdSliderConfigs.minValue;
    }
    notifyListeners();
    _debounceApplyCartoonize(context);
  }

  /// Debounce function to handle rapid consecutive requests.
  void _debounceApplyCartoonize(BuildContext context) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      if (originalImage != null) {
        applyCartoonize(context, originalImage!);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
