import 'dart:typed_data';
import 'package:flutter_toon_it/models/process_step.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

class CartoonizeService {
  /// Applies cartoonization to the provided image bytes.
  /// Returns a list of [ProcessStep] detailing each processing stage.
  Future<Uint8List> applyCartoonize({
    required Uint8List imageBytes,
    required int blurSigma,
    required int thresholdValue,
    required List<ProcessStep> processSteps,
  }) async {
    // Decode the image to Mat format
    final img = await cv.imdecodeAsync(imageBytes, cv.IMREAD_COLOR);

    // Step 1: Convert to Grayscale
    final gray = await cv.cvtColorAsync(img, cv.COLOR_BGR2GRAY);
    await _addStepToProcess(gray, "Grayscale", img, processSteps);

    // Step 2: Apply Median Blur (only if blur sigma > 0)
    cv.Mat blurredGrayScaled;
    if (blurSigma > 0) {
      blurredGrayScaled = await cv.medianBlurAsync(gray, blurSigma);
      await _addStepToProcess(blurredGrayScaled, "Blurred", gray, processSteps);
    } else {
      blurredGrayScaled = gray;
    }

    // Step 3: Edge Detection using Adaptive Threshold
    final edges = await cv.adaptiveThresholdAsync(
      blurredGrayScaled,
      255,
      cv.ADAPTIVE_THRESH_MEAN_C,
      cv.THRESH_BINARY,
      thresholdValue,
      9,
    );
    await _addStepToProcess(edges, "Edges", gray, processSteps);

    // Step 4: Use bitwise AND to merge edges and original image
    final cartoonized = await cv.bitwiseANDAsync(img, img, mask: edges);
    final cartoonImageEncoded =
        (await cv.imencodeAsync(".png", cartoonized)).$2;

    return cartoonImageEncoded;
  }

  /// Helper function to add steps to the processSteps list
  Future<void> _addStepToProcess(
    cv.Mat mat,
    String stepName,
    cv.Mat input,
    List<ProcessStep> processSteps,
  ) async {
    final (success, outputBytes) = await cv.imencodeAsync(".png", mat);
    final (successInput, inputBytes) = await cv.imencodeAsync(".png", input);
    if (success && successInput) {
      processSteps.add(ProcessStep(
        stepName: stepName,
        inputImage: inputBytes,
        outputImage: outputBytes,
      ));
    }
  }
}
