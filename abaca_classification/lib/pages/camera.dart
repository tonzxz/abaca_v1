import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:abaca_classification/theme/styles.dart';

class MyCamera extends StatefulWidget {
  const MyCamera({Key? key}) : super(key: key);

  @override
  State<MyCamera> createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  final List<String> buttonLabels = [
    'ef',
    's2',
    's3',
    'i',
    'g',
    'h',
    'jk',
    'm1',
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller!.setFlashMode(FlashMode.off);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }
    if (_controller!.value.isTakingPicture) {
      return;
    }
    try {
      final image = await _controller!.takePicture();

      final documentsDirectory = await getApplicationDocumentsDirectory();
      final takenDirectory = Directory('${documentsDirectory.path}/taken');
      if (!await takenDirectory.exists()) {
        await takenDirectory.create(recursive: true);
      }

      final imagePath =
          '${takenDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      await image.saveTo(imagePath);

      // Navigate to the DisplayPictureScreen with the imagePath
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(imagePath: imagePath),
          ),
        );
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Center(
          child: Stack(
            children: [
              if (_controller != null)
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          child: CameraPreview(_controller!),
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: buttonLabels
                      .map(
                        (label) => ElevatedButton(
                          onPressed: () {
                            // Add your button onPressed logic here
                            print('Button $label pressed');
                          },
                          child: Text(label),
                        ),
                      )
                      .toList(),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: ClipOval(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _takePicture(context); // Pass context here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor, // Button color
                      padding: const EdgeInsets.all(16), // Example padding
                    ),
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 55, 10, 20),
        child: Center(
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }
}
