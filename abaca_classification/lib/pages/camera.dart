import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:abaca_classification/theme/styles.dart';

class MyCamera extends StatefulWidget {
  const MyCamera({Key? key}) : super(key: key);

  @override
  State<MyCamera> createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  bool _continuousCapture = false;
  Timer? _timer;
  var _recognition = [];
  File? _image;
  String _filename = '';

  bool isActive = false;

  int activeIndex = -1;

  void handleClick(int index) {
    setState(() {
      activeIndex = index;
    });
  }

  List<String> abacaGrades = [];

  @override
  void initState() {
    super.initState();
    loadAbacaGrades();
    loadModel();
    _initCamera();
  }

  Future<void> loadAbacaGrades() async {
    String content = await rootBundle.loadString('assets/model/label.txt');
    List<String> grades = content.split('\n');
    setState(() {
      abacaGrades = grades;
    });
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

  closerModel() async {
    await Tflite.close();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
    _timer?.cancel();
    closerModel();
  }

  Future loadModel() async {
    await Tflite.loadModel(
        model: "assets/model/model.tflite",
        labels: "assets/model/label.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  // Future<void> _takePicture(BuildContext context) async {
  //   if (_controller == null || !_controller!.value.isInitialized) {
  //     print('Error: select a camera first.');
  //     return;
  //   }
  //   if (_controller!.value.isTakingPicture) {
  //     return;
  //   }
  //   try {
  //     final XFile? image = await _controller!.takePicture();

  //     final documentsDirectory = await getApplicationDocumentsDirectory();
  //     final takenDirectory = Directory('${documentsDirectory.path}/taken');
  //     if (!await takenDirectory.exists()) {
  //       await takenDirectory.create(recursive: true);
  //     }

  //     final imagePath =
  //         '${takenDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
  //     await File(image!.path).copy(imagePath);

  //     var prediction = await _classifyImage(File(imagePath));

  //     setState(() {
  //       _recognition = prediction;
  //       _image = File(imagePath);
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('$_recognition'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> _takePicture(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }
    if (_controller!.value.isTakingPicture) {
      return;
    }
    try {
      final XFile? image = await _controller!.takePicture();

      final documentsDirectory = await getApplicationDocumentsDirectory();
      final takenDirectory = Directory('${documentsDirectory.path}/taken');
      if (!await takenDirectory.exists()) {
        await takenDirectory.create(recursive: true);
      }

      final imagePath =
          '${takenDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      await File(image!.path).copy(imagePath);

      var prediction = await _classifyImage(File(imagePath));

      setState(() {
        _recognition = prediction;
        _image = File(imagePath);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_recognition'),
          duration: const Duration(seconds: 0),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  Future _classifyImage(File file) async {
    List<int> IMAGE_SIZE = [224, 224];
    var image = img.decodeImage(file.readAsBytesSync());

    image = img.flipVertical(image!);

    var reduced = img.copyResize(image,
        width: IMAGE_SIZE[0],
        height: IMAGE_SIZE[1],
        interpolation: img.Interpolation.nearest);

    final jpg = img.encodeJpg(reduced);
    File preprocessed = file.copySync("${file.path}(labeld).jpg");
    preprocessed.writeAsBytesSync(jpg);

    var recognitions = await Tflite.runModelOnImage(
        path: preprocessed.path, // required
        numResults: 1, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

    List<String> labels = [];
    for (var recognition in recognitions!) {
      if (recognition != null && recognition['label'] != null) {
        labels.add(recognition['label']);
      }
    }
    print(labels);
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
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
                      left: 10,
                      top: 160,
                      bottom: 240,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          abacaGrades.length,
                          (index) => SizedBox(
                            width: 45.0,
                            height: 45.0,
                            child: ElevatedButton(
                              onPressed: () => handleClick(index),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(200.0),
                                ),
                                padding: const EdgeInsets.all(
                                    0), // Remove default padding
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: activeIndex == index
                                        ? [gradient1Color, gradient2Color]
                                        : [Colors.white, Colors.white],
                                    begin: Alignment.topCenter,
                                    end: Alignment.center,
                                  ),
                                  borderRadius: BorderRadius.circular(80.0),
                                ),
                                child: Container(
                                  constraints: const BoxConstraints(
                                      minWidth: 20.0, minHeight: 20.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    abacaGrades[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: activeIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _continuousCapture = !_continuousCapture;
                              });
                              if (_continuousCapture) {
                                _timer = Timer.periodic(
                                    const Duration(seconds: 2), (timer) {
                                  _takePicture(context);
                                });
                              } else {
                                _timer?.cancel();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _continuousCapture
                                  ? Colors.red
                                  : Colors.yellow,
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                            ),
                            child: const SizedBox(
                              width: 50,
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
          Positioned(
            top: 55,
            left: 10,
            child: SizedBox(
              width: 45.0,
              height: 45.0,
              child: ElevatedButton(
                onPressed: () {
                  print('Button back pressed');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200.0),
                  ),
                  padding: const EdgeInsets.all(0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [gradient1Color, gradient2Color],
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                    ),
                    borderRadius: BorderRadius.circular(80.0),
                  ),
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 20.0, minHeight: 20.0),
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 55,
            right: 10,
            child: SizedBox(
              width: 45.0,
              height: 45.0,
              child: ElevatedButton(
                onPressed: () {
                  print('Button back pressed');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200.0),
                  ),
                  padding: const EdgeInsets.all(0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [gradient1Color, gradient2Color],
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                    ),
                    borderRadius: BorderRadius.circular(80.0),
                  ),
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 20.0, minHeight: 20.0),
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: const Icon(
                        Icons.circle_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 55,
            right: 70,
            child: SizedBox(
              width: 45.0,
              height: 45.0,
              child: ElevatedButton(
                onPressed: () {
                  print('Button back pressed');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200.0),
                  ),
                  padding: const EdgeInsets.all(0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [gradient1Color, gradient2Color],
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                    ),
                    borderRadius: BorderRadius.circular(80.0),
                  ),
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 20.0, minHeight: 20.0),
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: const Icon(
                        Icons.print,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
