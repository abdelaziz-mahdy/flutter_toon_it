// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/process_step.dart';
import '../services/cartoonize_service.dart';

class SliderConfigs {
  int defaultValue;
  int minValue;
  int maxValue;
  SliderConfigs({
    required this.defaultValue,
    required this.minValue,
    required this.maxValue,
  });

  int get divisions => (maxValue - minValue).toInt();
}

class CartoonizeController extends ChangeNotifier {
  final CartoonizeService _cartoonizeService = CartoonizeService();
  final ImagePicker _picker = ImagePicker();

  Uint8List? originalImage;
  Uint8List? cartoonImage;
  List<ProcessStep> processSteps = [];
  bool isProcessing = false;

  // Configuration values for sliders
  SliderConfigs blurSliderConfigs =
      SliderConfigs(defaultValue: 0, minValue: 0, maxValue: 100);
  int blurSigma = 0;
  int thresholdValue = 9;

  // To enforce 100ms gap between requests
  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);

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
    final now = DateTime.now();
    if (now.difference(_lastRequestTime).inMilliseconds < 100) {
      // Ignore the request
      return;
    }
    _lastRequestTime = now;

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

  /// Updates the blur sigma and re-applies cartoonization.
  Future<void> updateBlurSigma(BuildContext context, double value) async {
    blurSigma = value.toInt();
    if (blurSigma % 2 == 0 && blurSigma > 0) {
      blurSigma += 1;
    }
    blurSigma = blurSigma < 0 ? 0 : blurSigma;
    notifyListeners();

    if (originalImage != null) {
      await applyCartoonize(context, originalImage!);
    }
  }

  /// Updates the threshold value and re-applies cartoonization.
  Future<void> updateThresholdValue(BuildContext context, double value) async {
    thresholdValue = value.toInt();
    if (thresholdValue % 2 == 0) {
      thresholdValue += 1;
    }
    thresholdValue = thresholdValue <= 1 ? 3 : thresholdValue;
    notifyListeners();

    if (originalImage != null) {
      await applyCartoonize(context, originalImage!);
    }
  }
}
