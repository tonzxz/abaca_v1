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

  final List<String> abacaGrades = [
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              gradient1Color,
              gradient2Color,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
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
                  top: 160,
                  bottom: 240,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: abacaGrades
                        .map(
                          (label) => ElevatedButton(
                            onPressed: () {
                              print('Button $label pressed');
                            },
                            child: Text(label),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            Colors.white, // Yellow color for the circular shape
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ElevatedButton(
                        onPressed: () async {
                          await _takePicture(context); // Pass context here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.yellow, // Make button transparent
                          padding: EdgeInsets.zero, // Remove padding
                          shape: const CircleBorder(), // Make button circeular
                        ),
                        child: const SizedBox(
                          width: 50, // Width of the circular shape
                          height: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              gradient1Color,
              gradient2Color,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 55, 10, 20),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Example border radius
              child: Image.file(File(imagePath)),
            ),
          ),
        ),
      ),
    );
  }
}
