import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:abaca_classification/theme/styles.dart';
import 'package:abaca_classification/pages/choices.dart';

class MyCamera extends StatefulWidget {
  const MyCamera({Key? key}) : super(key: key);

  @override
  State<MyCamera> createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool shouldStartMatching = false; // Add this variable
  bool _continuousCapture = false;
  Timer? _timer;
  String? _recognition;
  File? _image;
  String _filename = '';

  bool isActive = false;

  int activeIndex = -1;

  void handleClick(int index) {
    setState(() {
      activeIndex = index;
    });
  }

  // List<String> abacaGrades = [];
  List<String> abacaGrades = ['EF', 'G', 'H', 'I', 'JK', 'M1', 'S2', 'S3'];
  bool resultMatches = true;

  @override
  void initState() {
    super.initState();
    loadModel();
    // loadAbacaGrades();
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

      final imagePath = '${takenDirectory.path}/captured.png';
      await File(image!.path).copy(imagePath);

      // var averageColor = await getAverageColor(File(imagePath));
      // bool isCloseToBlack = averageColor.computeLuminance() < 0.2;
      bool isCloseToBlack = false;
      var prediction = await _classifyImage(File(imagePath));
      setState(() {
        if (!isCloseToBlack) {
          _recognition = prediction;
        } else {
          _recognition = null;
        }
        _image = File(imagePath);
      });
      // print('Raw: $_recognition');
      // print(
      //     'Recognition: ${_recognition.where((recog) => abacaGrades.contains(recog)).join(', ')}');
      // print('Abaca Grades: $abacaGrades');

      // bool resultMatches =
      //     _recognition.any((recog) => abacaGrades.contains(recog));

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('$_recognition'.replaceAll(RegExp(r'\[|\]'), '')),
      //     duration: const Duration(seconds: 1),
      //   ),
      // );
    } catch (e) {
      print(e);
    }
  }

  Future<Color> getAverageColor(File imageFile) async {
    // Load the image using the image package
    var image = img.decodeImage(await imageFile.readAsBytes());

    // Calculate the average color
    int totalRed = 0;
    int totalGreen = 0;
    int totalBlue = 0;

    for (int y = 0; y < image!.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        totalRed += img.getRed(pixel);
        totalGreen += img.getGreen(pixel);
        totalBlue += img.getBlue(pixel);
      }
    }

    int totalPixels = image.width * image.height;
    int avgRed = totalRed ~/ totalPixels;
    int avgGreen = totalGreen ~/ totalPixels;
    int avgBlue = totalBlue ~/ totalPixels;

    // Return the average color
    return Color.fromRGBO(avgRed, avgGreen, avgBlue, 1.0);
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

    List<String> getLabels(List<dynamic> recognitions) {
      List<String> labels = [];
      for (var recognition in recognitions) {
        if (recognition != null && recognition['label'] != null) {
          labels.add(recognition['label']);
        }
      }
      return labels;
    }

    var recognitions = await Tflite.runModelOnImage(
      path: preprocessed.path, // required
      numResults: 1, // defaults to 5
      threshold: 0.2, // defaults to 0.1
      asynch: true, // defaults to true
    );

    List<String> labels = [];
    bool resultMatches = true; // Initialize resultMatches here
    if (recognitions != null && recognitions.isNotEmpty) {
      labels.add(recognitions[0]['label']);
    }
    // for (var recognition in recognitions!) {
    //   if (recognition != null && recognition['label'] != null) {
    //     labels.add(recognition['label']);
    //   }
    // }

    // // Check if all elements in abacaGrades are present in labels and vice versa
    // resultMatches = abacaGrades.toSet().containsAll(labels.toSet()) &&
    //     labels.toSet().containsAll(abacaGrades.toSet());

    // print(labels.join(', '));
    return labels.isNotEmpty ? labels[0] : null;
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
                  Colors.black,
                  Colors.black,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 85, 0, 0),
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

                       Stack(
  children: [
    
                                          Positioned(
                                            left: 10,
                                            top: 180,
                                            bottom: 200,
                                            child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [gradient2Color, gradient2Color],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              width: 45.0,
                                              height: 360.0,
                                          
                                            ),
                                          ],
                                        ),
                                      ),

                                          ),
                                      
                                        Positioned(
                                                          left: 10,
                                                          top:180,
                                                          bottom:200,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                                    padding: const EdgeInsets.all(0),
                                                                  elevation: shouldStartMatching
                                        ? abacaGrades[index] == _recognition
                                            ? 1 
                                            : 0 
                                        : 0, 
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                  
                                    colors: shouldStartMatching
                                        ? abacaGrades[index] == _recognition
                                            ? [gradient1Color , gradient1Color ]
                                            : [gradient2Color, gradient2Color ]
                                        : [gradient2Color, gradient2Color],
                                    begin: Alignment.topCenter,
                                    end: Alignment.center,
                                  ),
                                  borderRadius: BorderRadius.circular(80.0),
                                ),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 20.0,
                                    minHeight: 20.0,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    abacaGrades[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.0, 
                                      color: shouldStartMatching
                                          ? abacaGrades[index] == _recognition
                                              ? gradient2Color
                                              : Colors.white.withOpacity(.5) 
                                          : Colors.white.withOpacity(.5), 
                                    ),
                                  ),

                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
  ],
),
                    

                    // end list 


                    // duplicate list 
 



                    // end duplicate list 
                    
                    // Align(
                    //   alignment: Alignment.bottomCenter,
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(bottom: 15),
                    //     child: Container(
                    //       decoration: const BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         color: Colors.white,
                    //       ),
                    //       padding: const EdgeInsets.all(4),
                    //       child: ElevatedButton(
                    //         onPressed: () async {
                    //           setState(() {
                    //             _continuousCapture = !_continuousCapture;
                    //             shouldStartMatching =
                    //                 _continuousCapture; // Update shouldStartMatching
                    //           });
                    //           if (_continuousCapture) {
                    //             _timer = Timer.periodic(
                    //                 const Duration(seconds: 1), (timer) {
                    //               if (shouldStartMatching) {
                    //                 // Only take picture and start matching if shouldStartMatching is true
                    //                 _takePicture(context);
                    //               }
                    //             });
                    //           } else {
                    //             _timer?.cancel();
                    //           }
                    //         },
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: _continuousCapture
                    //               ? Colors.red
                    //               : Colors.yellow,
                    //           padding: EdgeInsets.zero,
                    //           shape: const CircleBorder(),
                    //         ),
                    //         child: const SizedBox(
                    //           width: 50,
                    //           height: 50,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 95,
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
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: SvgPicture.string(
                        '''
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M15 4.5L7.5 12L15 19.5" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>


        ''',
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MyChoices(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          
// summary 

          Positioned(
            top: 95,
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
                      icon: SvgPicture.string(
                        '''
       <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M16 28C9.5 28 4 22.5 4 16C4 11.8564 6.23502 8.11926 9.53935 5.95416C11.308 4.79528 13.383 4.0868 15.5856 4.00746L16 4L16 9C12.134 9 9 12.134 9 16C9 19.866 12.134 23 16 23C19.7855 23 22.8691 19.9952 22.9959 16.2407L23 16H28C28 22.4 22.6679 27.8305 16.2993 27.9961L16 28Z" fill="white"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M20.0003 10.2549L20 4.68374C21.6054 5.22635 23.1054 6.1651 24.5 7.5C25.786 8.731 26.6883 10.1197 27.2068 11.6662L27.312 12L21.7447 11.9992C21.2708 11.32 20.6795 10.7288 20.0003 10.2549Z" fill="white"/>
</svg>

        ''',
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),


// end summary 

// picture


  Positioned(
            bottom: 55,
            left: 160,
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
                                shouldStartMatching =
                                    _continuousCapture; // Update shouldStartMatching
                              });
                              if (_continuousCapture) {
                                _timer = Timer.periodic(
                                    const Duration(seconds: 1), (timer) {
                                  if (shouldStartMatching) {
                                    // Only take picture and start matching if shouldStartMatching is true
                                    _takePicture(context);
                                  }
                                });
                              } else {
                                _timer?.cancel();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _continuousCapture
                                  ? Colors.red
                                  : gradient2Color,
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


// end picture
 

 // print

          Positioned(
            top: 95,
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
                      icon: SvgPicture.string(
                        '''
      <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M26 8C27.0544 8 27.9182 8.81588 27.9945 9.85074L28 10V22C28 23.0544 27.1841 23.9182 26.1493 23.9945L26 24H25V19C25 17.9456 24.1841 17.0818 23.1493 17.0055L23 17H9C7.94564 17 7.08183 17.8159 7.00549 18.8507L7 19V24H6C4.94564 24 4.08183 23.1841 4.00549 22.1493L4 22V10C4 8.94564 4.81588 8.08183 5.85074 8.00549L6 8H26Z" fill="white"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M11 19H21C22.1046 19 23 19.8954 23 21V25C23 26.1046 22.1046 27 21 27H11C9.89543 27 9 26.1046 9 25V21C9 19.8954 9.89543 19 11 19Z" fill="white"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M11 4H21C22.1046 4 23 4.89543 23 6V7H9V6C9 4.89543 9.89543 4 11 4Z" fill="white"/>
</svg>


        ''',
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),

// end print 


        ],
      ),
    );
  }
}
