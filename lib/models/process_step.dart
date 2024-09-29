import 'dart:typed_data';

class ProcessStep {
  final String stepName;
  final Uint8List inputImage;
  final Uint8List outputImage;

  ProcessStep({
    required this.stepName,
    required this.inputImage,
    required this.outputImage,
  });
}
