import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

void main() {
  runApp(const CartoonizeApp());
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
      theme:
          ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      darkTheme:
          ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cartoonize Image'),
          actions: [
            IconButton(
              icon: Icon(_themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode),
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

class CartoonizeHomePage extends StatefulWidget {
  const CartoonizeHomePage({super.key});

  @override
  _CartoonizeHomePageState createState() => _CartoonizeHomePageState();
}

class _CartoonizeHomePageState extends State<CartoonizeHomePage> {
  Uint8List? _originalImage;
  Uint8List? _cartoonImage;
  List<ProcessStep> _processSteps = [];

  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  // Configuration values for sliders
  int _blurSigma = 0;
  int _thresholdValue = 9;

  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _originalImage = bytes;
        _cartoonImage = null; // Reset the cartoonized image
        _processSteps = [];
      });
      await applyCartoonize(bytes);
    }
  }

  // Function to apply the cartoonization process
  Future<void> applyCartoonize(Uint8List imageBytes) async {
    setState(() {
      _isProcessing = true;
      _processSteps = [];
    });

    try {
      // Decode the image to Mat format
      final img = await cv.imdecodeAsync(imageBytes, cv.IMREAD_COLOR);

      // Step 1: Convert to Grayscale
      final gray = await cv.cvtColorAsync(img, cv.COLOR_BGR2GRAY);
      await _addStepToProcess(gray, "Grayscale", img);

      // Step 2: Apply Gaussian Blur (only if blur sigma > 0)
      final cv.Mat blurredGrayScaled;
      if (_blurSigma > 0) {
        blurredGrayScaled = await cv.medianBlurAsync(gray, _blurSigma);
        await _addStepToProcess(blurredGrayScaled, "Blurred", gray);
      } else {
        blurredGrayScaled = img;
      }

      // Step 3: Edge Detection using Adaptive Threshold (validated blockSize)

      final edges = await cv.adaptiveThresholdAsync(blurredGrayScaled, 255,
          cv.ADAPTIVE_THRESH_MEAN_C, cv.THRESH_BINARY, _thresholdValue, 9);
      await _addStepToProcess(edges, "Edges", gray);

      // Step 4: Use bitwise AND to merge edges and original image
      final cartoonized = await cv.bitwiseANDAsync(img, img, mask: edges);
      final cartoonImageEncoded =
          (await cv.imencodeAsync(".png", cartoonized)).$2;

      setState(() {
        _cartoonImage = cartoonImageEncoded;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
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
    }
  }

  // Helper function to add steps to the processSteps list
  Future<void> _addStepToProcess(
      cv.Mat mat, String stepName, cv.Mat input) async {
    final (success, outputBytes) = await cv.imencodeAsync(".png", mat);
    final (successInput, inputBytes) = await cv.imencodeAsync(".png", input);
    if (success && successInput) {
      setState(() {
        _processSteps.add(ProcessStep(
          stepName: stepName,
          inputImage: inputBytes,
          outputImage: outputBytes,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: SizedBox(
          height: 610,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Wrap(
                children: [
                  _originalImage != null
                      ? Image.memory(_originalImage!, height: 200)
                      : const Text("No image selected"),
                  const SizedBox(
                    height: 20,
                    width: 20,
                  ),
                  if (_isProcessing) const CircularProgressIndicator(),
                  _cartoonImage != null
                      ? Image.memory(_cartoonImage!, height: 200)
                      : const Text("Cartoonized image will appear here"),
                ],
              ),
              const SizedBox(height: 20),
              _buildSliders(),
              const SizedBox(height: 20),
              _buildProcessStepsView(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text("Pick Image"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display the sliders for configuration
  Widget _buildSliders() {
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
                value: _blurSigma.toDouble(),
                min: blurMin,
                max: blurMax,
                divisions: (blurMax - blurMin).toInt(),
                label: _blurSigma.toString(),
                onChanged: (value) async {
                  setState(() {
                    int blur = value.toInt();
                    if (blur % 2 == 0) {
                      if (blur < blurMax) {
                        blur += 1;
                      } else {
                        blur -= 1;
                      }
                    }
                    if (blur <= 0) {
                      blur = 0;
                    }

                    _blurSigma = blur.toInt();
                  });
                  if (_originalImage != null) {
                    await applyCartoonize(_originalImage!);
                  }
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text("Threshold Block Size:"),
            Expanded(
              child: Slider(
                value: _thresholdValue.toDouble(),
                min: thresholdMin,
                max: thresholdMax,
                divisions: (thresholdMax - thresholdMin).toInt(),
                label: _thresholdValue.toString(),
                onChanged: (value) async {
                  setState(() {
                    // Step 3: Edge Detection using Adaptive Threshold (validated blockSize)
                    int blockSize = value.toInt();
                    if (blockSize % 2 == 0) {
                      if (blockSize < thresholdMax) {
                        blockSize += 1; // Ensure blockSize is odd
                      } else {
                        blockSize -= 1;
                      }
                    }

                    if (blockSize <= 1) {
                      blockSize = 3; // Ensure blockSize > 1
                    }

                    _thresholdValue = blockSize.toInt();
                  });
                  if (_originalImage != null) {
                    await applyCartoonize(_originalImage!);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget to display process steps (left-to-right)
  Widget _buildProcessStepsView() {
    if (_processSteps.isEmpty) {
      return const Text("Processing steps will appear here.");
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _processSteps.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  _showStepDialog(_processSteps[index]);
                },
                child: Column(
                  children: [
                    Image.memory(_processSteps[index].outputImage,
                        width: 80, height: 80),
                    Text(_processSteps[index].stepName),
                  ],
                ),
              ),
              if (index < _processSteps.length - 1)
                const Icon(Icons.arrow_forward, size: 30),
            ],
          );
        },
      ),
    );
  }

  // Function to show a dialog with step input/output details
  void _showStepDialog(ProcessStep step) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(step.stepName),
          content: Wrap(
            // mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  Image.memory(step.inputImage, height: 100),
                  const Text("Input Image"),
                ],
              ),
              const SizedBox(
                height: 10,
                width: 10,
              ),
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

// Class to hold details of each processing step
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
