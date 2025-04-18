import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:open_file/open_file.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:abaca_classification/theme/styles.dart';
import 'package:abaca_classification/pages/choices.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MyCamera extends StatefulWidget {
  const MyCamera({Key? key}) : super(key: key);

  @override
  State<MyCamera> createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> {
  // List<String> abacaGrades = [];
  List<String> abacaGradesLeft = ['EF', 'G', 'H', 'I'];
  List<String> abacaGradesRight = ['JK', 'M1', 'S2', 'S3'];

  int activeIndex = -1;
  bool isActive = false;
  bool resultMatches = true;
  bool shouldStartMatching = false; // Add this variable

  bool _continuousCapture = false;
  CameraController? _controller;
  String _filename = '';
  List<int>? _image;
  Future<void>? _initializeControllerFuture;
  String? _recognition;
  Timer? _timer;
  String? _lastPrediction;
  final PredictionCache predictionCache = PredictionCache(3);

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
    _timer?.cancel();
    closerModel();
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    _initCamera();
  }

  void handleClick(int index) {
    setState(() {
      activeIndex = index;
    });
  }

  closerModel() async {
    await Tflite.close();
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

  // per day
  String dropdownValue = 'Today';

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  // '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year}'

  // end per day

Future<String> getImageUrl(String imageRef) async {
  // Replace 'your_bucket' with the name of your Firebase Storage bucket
  final ref = FirebaseStorage.instance.ref().child(imageRef);
  return await ref.getDownloadURL();
}

Future<String> uploadImage(File imageFile, String prediction) async {
  String imageUrl = '';

  try {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('Grades/$prediction/${DateTime.now().microsecondsSinceEpoch}.jpg'); // Change 'image1.jpg' to the desired name of the image

    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    imageUrl = await taskSnapshot.ref.getDownloadURL();
  } catch (e) {
    print(e.toString());
  }
  return imageUrl;
}
  void _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.veryHigh,
    );

    _initializeControllerFuture = _controller!.initialize().then((_)  async{
      if (!mounted) return;
      // await _controller!.setExposureMode(ExposureMode.locked);
      // await _controller!.setExposureOffset(await _controller!.getMinExposureOffset());
      // await _controller!.setExposureOffset( ( await _controller!.getMinExposureOffset() + await _controller!.getMaxExposureOffset())/8);
      setState(() {});
      _controller!.setFlashMode(FlashMode.off);
    });
  }

  // pdf print
  Future<void> _createPDF() async {
    //Create a new PDF document
    PdfDocument document = PdfDocument();

    //Add a new page and draw text
    document.pages.add().graphics.drawString(
        'Classified Abaca Grades', PdfStandardFont(PdfFontFamily.helvetica, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: const Rect.fromLTWH(0, 0, 500, 50));

    //Create a new PDF document

//Create a PdfGrid class
    PdfGrid grid = PdfGrid();

//Add the columns to the grid
    grid.columns.add(count: 3);

//Add header to the grid
    grid.headers.add(1);

//Add the rows to the grid
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Employee ID';
    header.cells[1].value = 'Employee Name';
    header.cells[2].value = 'Salary';

//Add rows to grid
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = 'E01';
    row.cells[1].value = 'Clay';
    row.cells[2].value = '\$10,000';

    row = grid.rows.add();
    row.cells[0].value = 'E02';
    row.cells[1].value = 'Simon';
    row.cells[2].value = '\$12,000';

//Set the grid style
    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
        backgroundBrush: PdfBrushes.blue,
        textBrush: PdfBrushes.white,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 25));

//Draw the grid
    grid.draw(
        page: document.pages.add(), bounds: const Rect.fromLTWH(0, 0, 0, 0));

    //Save the document
    List<int> bytes = await document.save();

    //Dispose the document
    document.dispose();

    //Get external storage directory
    final directory = await getApplicationSupportDirectory();

//Get directory path
    final path = directory.path;

//Create an empty file to write PDF data
    File file = File('$path/Output.pdf');

//Write PDF data
    await file.writeAsBytes(bytes, flush: true);

//Open the PDF document in mobile
    OpenFile.open('$path/Output.pdf');
  }
  // end pdf print

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

      var prediction = await _classifyImage(File(imagePath));

      // check if not blurred
      if(prediction == 'B'){
        prediction = _lastPrediction;
      }

      if (prediction == 'NA') {
        prediction = null;
      }

    if(prediction != _lastPrediction && _continuousCapture){
      _lastPrediction = prediction;
      if ( _confidence > 0.8) {
          // Get date today
        try {   
          String today =
                '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year}-R'; // 4-4-2024
            DatabaseReference todayRef =
                FirebaseDatabase.instance.reference().child(today);
          var ref = await uploadImage(File(imagePath), prediction);
          await todayRef.child(prediction).push().set({
              "Grade" : prediction,
              "Confidence" : _confidence,
              "ImageRef": ref
            });

          final player = AudioPlayer();
          player.play(AssetSource('classify.mp3'));

        } catch (e) {
          print('Error saving to database: $e');
        }
      }
      }
      setState(() {
        _recognition = prediction;
      });

    } catch (e) {
      print(e);
    }
  }

  double _confidence = 0.0;


  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  Uint8List imageToByteListFloat32(
      img.Image image, int width, int height) {
    var convertedBytes = Float32List(1 * width * height * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < height; i++) {
      for (var j = 0; j < width; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel).toDouble();
        buffer[pixelIndex++] = img.getGreen(pixel).toDouble();
        buffer[pixelIndex++] = img.getBlue(pixel).toDouble();
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  double computeLaplacianVariance(img.Image image) {
    // Apply Laplacian filter to the image
    img.Image filteredImage =
        img.convolution(image, [0, 1, 0, 1, -4, 1, 0, 1, 0]);

    // Compute the variance of the filtered image
    double variance = computeVariance(filteredImage);

    return variance;
  }

  double computeVariance(img.Image image) {
    // Calculate the mean intensity
    double sum = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int intensity = img.getRed(pixel); // Assuming grayscale image
        sum += intensity;
      }
    }
    double mean = sum / (image.width * image.height);

    // Calculate the variance
    double variance = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int intensity = img.getRed(pixel); // Assuming grayscale image
        variance += (intensity - mean) * (intensity - mean);
      }
    }
    variance /= (image.width * image.height);

    return variance;
  }

  

  img.Image cropAndResizeCenter(img.Image image, int targetWidth, int targetHeight) {
    int height = image.height;
    int width = image.width;
    double zoom = 1.7;

    // Calculate starting and ending indices for cropping
    int startX = (width - width / zoom) ~/ 2;
    int startY = (height - width / zoom) ~/ 2;
    int endX = (startX + width / zoom).round();
    int endY = (startY + width / zoom).round();

    // Perform cropping
    img.Image croppedImage =
        img.copyCrop(image, startX, startY, endX - startX, endY - startY);

    // Resize to final dimensions
    return img.copyResize(croppedImage,
        width: targetWidth, height: targetHeight, interpolation: img.Interpolation.nearest);
  }

  
  

  Future _classifyImage(File file) async {
    List<int> IMAGE_SIZE = [224, 224];
    var image = img.decodeImage(file.readAsBytesSync());
    // image  = img.adjustColor(image!,saturation:1.5, gamma:1.2,amount:1);
    // print(image!.width);
    // print(image!.height);
    // image = img.flipVertical(image!);
    // image = img.copyRotate(image!,90);
    // var reduced = img.copyResize(image!,
    //     width: IMAGE_SIZE[0],
    //     height: IMAGE_SIZE[1],
    //     interpolation: img.Interpolation.linear);
    var reduced = cropAndResizeCenter(image!, IMAGE_SIZE[0], IMAGE_SIZE[1]);
    // final jpg = img.encodeJpg(reduced);
    // file = await file.writeAsBytes(jpg);
    // setState((){
    //   _image = jpg;
    // });
    //  _timer?.cancel();
    //  return null;

    // var recognitions = await Tflite.runModelOnImage(
    //   path: file.path, // required
    //   // imageMean: 0.0,
    //   // imageStd: 1.0,
    //   numResults: 1, // defaults to 5
    //   threshold: 0.2, // defaults to 0.1
    //   asynch: true, // defaults to true
    // );
    var recognitions = await Tflite.runModelOnBinary(
        binary: imageToByteListFloat32(reduced, IMAGE_SIZE[0], IMAGE_SIZE[1]),// required
        numResults: 6,    // defaults to 5
        threshold: 0.05,  // defaults to 0.1
        asynch: true      // defaults to true
    );

    img.Image grayscaleImage = img.grayscale(reduced);
    double laplacianVariance = computeLaplacianVariance(grayscaleImage);
    print({"Laplacian Variance": laplacianVariance});
    // detect if image contains sharp strands of abaca fiber
    if (laplacianVariance < 1800 ) {
      // Image contains abaca but strands are smeared to be clasified
        return 'B';
      }

      if (laplacianVariance < 2700  ) {
        // image does not contain enough strands to increase image sharpness
        return 'NA'; // Not Abaca
      }
  

    List<String> labels = [];
    if (recognitions != null && recognitions.isNotEmpty) {
      print(recognitions[0]);
      // if confidence level is more than 60%
      if (recognitions[0]['confidence'] > 0.5) {
        labels.add(recognitions[0]['label']);
      }else{
        return 'B';
      }
    }
    if (labels.isNotEmpty) {
      setState(() {
        _confidence = recognitions![0]['confidence'];
      });
    }

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
                                child:CameraPreview(_controller!),
                              ),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                _image != null
                ? Image.memory(Uint8List.fromList(_image!))
                : SizedBox(),
                    Positioned.fill(
                      child: Column(children: [
                          Flexible(
                            flex:3,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  height: 224,
                                ),
                              ),
                              Container(
                                width: 224, // Assuming cropping square
                                height: 224,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                  border: Border.all(
                                      color: ( _continuousCapture && _recognition != null) ? (_confidence > 0.8 ? Colors.green :Colors.orangeAccent) : Colors.white, width: 2.0),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                    height: 224),
                              ),
                            ],
                          ),
                          Flexible(
                            flex:4,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ]),
                    ),
                     (_recognition != null && _continuousCapture)? Stack(children: [
                      Positioned.fill(child: Column(children: [
                        Spacer(),
                        SizedBox(height: 224,),
                        SizedBox(height: 50,
                        child: Text(
                          _confidence > 0.8 ? 'Confidence: ${(_confidence * 100).toStringAsFixed(0)}%' : ' Stabilizing ( Mixed Grade / Non-Abaca )',
                          textAlign: TextAlign.center,
                          style:  TextStyle(
                            color: (_confidence > 0.8 ? Colors.green :Colors.orangeAccent),
                            fontWeight: fontMD,
                          ),
                        ),),
                        Spacer(),
                      ],))
                    ],): SizedBox(),
                    Stack(
                      children: [
                        Positioned(
                          left: 5,
                          top: 180,
                          bottom: 240,
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
                                  height: 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 5,
                          top: 180,
                          bottom: 240,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              abacaGradesLeft.length,
                              (index) => Flexible(
                                child: SizedBox(
                                  width: 45.0,
                                  height: 45.0,
                                  child: ElevatedButton(
                                    onPressed: () => handleClick(index),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(200.0),
                                      ),
                                      padding: const EdgeInsets.all(0),
                                      elevation: shouldStartMatching
                                          ? abacaGradesLeft[index] ==
                                                  _recognition
                                              && _confidence > 0.8 ? 1
                                              : 0
                                          : 0,
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: shouldStartMatching
                                              ? abacaGradesLeft[index] ==
                                                      _recognition
                                                  && _confidence > 0.8 ? [
                                                      gradient1Color,
                                                      gradient1Color
                                                    ]
                                                  : [
                                                      gradient2Color,
                                                      gradient2Color
                                                    ]
                                              : [
                                                  gradient2Color,
                                                  gradient2Color
                                                ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.center,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(80.0),
                                      ),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 20.0,
                                          minHeight: 20.0,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          abacaGradesLeft[index],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: shouldStartMatching
                                                ? abacaGradesLeft[index] ==
                                                        _recognition
                                                     && _confidence > 0.8? gradient2Color
                                                    : Colors.white
                                                        .withOpacity(.5)
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
                        ),
                        Positioned(
                          right: 5,
                          top: 180,
                          bottom: 240,
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
                                  height: 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 5,
                          top: 180,
                          bottom: 240,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              abacaGradesRight.length,
                              (index) => Flexible(
                                child: SizedBox(
                                  width: 45.0,
                                  height: 45.0,
                                  child: ElevatedButton(
                                    onPressed: () => handleClick(index),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(200.0),
                                      ),
                                      padding: const EdgeInsets.all(0),
                                      elevation: shouldStartMatching
                                          ? abacaGradesRight[index] ==
                                                  _recognition
                                               && _confidence > 0.8? 1
                                              : 0
                                          : 0,
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: shouldStartMatching
                                              ? abacaGradesRight[index] ==
                                                      _recognition
                                                   && _confidence > 0.8? [
                                                      gradient1Color,
                                                      gradient1Color
                                                    ]
                                                  : [
                                                      gradient2Color,
                                                      gradient2Color
                                                    ]
                                              : [
                                                  gradient2Color,
                                                  gradient2Color
                                                ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.center,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(80.0),
                                      ),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 20.0,
                                          minHeight: 20.0,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          abacaGradesRight[index],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: shouldStartMatching
                                                ? abacaGradesRight[index] ==
                                                        _recognition
                                                    && _confidence > 0.8 ? gradient2Color
                                                    : Colors.white
                                                        .withOpacity(.5)
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
                  print("Modal bukas");
                  // modal
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      List<String> abacaGrades = [
                        'EF',
                        'G',
                        'H',
                        'I',
                        'JK',
                        'M1',
                        'S2',
                        'S3'
                      ];

                      List<TableRow> generateTableRows(
                          Map<dynamic, dynamic> data, String dropdownValue) {
                        List<TableRow> rows = [];

                        // Add header row
                        rows.add(
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Grades',
                                  style: TextStyle(
                                    color: gradient2Color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Classified',
                                  style: TextStyle(
                                    color: gradient2Color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        DateTime now = DateTime.now();

                        if (dropdownValue == 'Today') {
                          String todayDate =
                              '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year}-R';
                          var dailyData = data[todayDate];
                          dailyData.forEach((key, value) {
                            rows.add(
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      key,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      '${value.length}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                        } else if (dropdownValue == 'This Week') {
                          DateTime startOfWeek =
                              now.subtract(Duration(days: now.weekday - 1));
                          DateTime endOfWeek =
                              startOfWeek.add(const Duration(days: 6));
                          List<String> weeklyDates = [];
                          for (var i = 0; i < 7; i++) {
                            var date = startOfWeek.add(Duration(days: i));
                            weeklyDates
                                .add('${date.month}-${date.day}-${date.year}-R');
                          }

                          Map<String, int> weeklyTotals = {};
                          weeklyDates.forEach((date) {
                            if (data.containsKey(date)) {
                              data[date].forEach((key, value) {
                                weeklyTotals[key] =
                                    (weeklyTotals[key] ?? 0) + (value.length as int);
                              });
                            }
                          });

                          weeklyTotals.forEach((key, value) {
                            rows.add(
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      key,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      '$value',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                        } else if (dropdownValue == 'This Month') {
                          DateTime startOfMonth =
                              DateTime(now.year, now.month, 1);
                          DateTime endOfMonth =
                              DateTime(now.year, now.month + 1, 0);
                          List<String> monthlyDates = [];
                          for (var i = startOfMonth.day;
                              i <= endOfMonth.day;
                              i++) {
                            monthlyDates.add('${now.month}-$i-${now.year}-R');
                          }

                          Map<String, int> monthlyTotals = {};
                          monthlyDates.forEach((date) {
                            if (data.containsKey(date)) {
                              data[date].forEach((key, value) {
                                monthlyTotals[key] =
                                    (monthlyTotals[key] ?? 0) + (value.length as int);
                              });
                            }
                          });

                          monthlyTotals.forEach((key, value) {
                            rows.add(
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      key,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      '$value',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                        }

                        return rows;
                      }

                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                          Center(
                            child: Dialog(
                              elevation: 0.0,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.9,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32.0),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 16, 0, 0),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.arrow_back_ios,
                                            color: gradient2Color,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ),

                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                      child: Center(
                                        child: Text(
                                          "Classified Abaca Fibers",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: gradient2Color,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Dropdown menu
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: DropdownButton<String>(
                                          value: dropdownValue,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              dropdownValue = newValue!;
                                              MyCamera();
                                              (context as Element).reassemble();
                                            });
                                          },
                                          underline: SizedBox(),
                                          items: <String>[
                                            'Today',
                                            'This Week',
                                            'This Month'
                                          ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 8, 16, 32),
                                      child: StreamBuilder<DatabaseEvent>(
                                        stream: _databaseReference.onValue,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<DatabaseEvent>
                                                snapshot) {
                                          if (snapshot.hasData) {
                                            Map<dynamic, dynamic> data =
                                                snapshot.data!.snapshot.value
                                                    as Map<dynamic, dynamic>;
                                            List<TableRow> rows =
                                                generateTableRows(
                                                    data, dropdownValue);

                                            String dateRange = '';
                                            if (dropdownValue == 'Today') {
                                              String todayDate =
                                                  '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year}';
                                              dateRange = todayDate;
                                            } else if (dropdownValue ==
                                                'This Week') {
                                              DateTime startOfWeek =
                                                  DateTime.now().subtract(
                                                      Duration(
                                                          days: DateTime.now()
                                                                  .weekday -
                                                              1));
                                              DateTime endOfWeek = startOfWeek
                                                  .add(const Duration(days: 6));
                                              dateRange =
                                                  '${startOfWeek.month}-${startOfWeek.day}-${startOfWeek.year} to ${endOfWeek.month}-${endOfWeek.day}-${endOfWeek.year}';
                                            } else if (dropdownValue ==
                                                'This Month') {
                                              DateTime startOfMonth = DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  1);
                                              DateTime endOfMonth = DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month + 1,
                                                  0);
                                              dateRange =
                                                  '${startOfMonth.month}-${startOfMonth.day}-${startOfMonth.year} to ${endOfMonth.month}-${endOfMonth.day}-${endOfMonth.year}';
                                            }

                                            return Table(
                                              border: TableBorder.all(
                                                  color: gradient2Color),
                                              children: [
                                                TableRow(children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Center(
                                                      child: Text(
                                                        dateRange,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          color: gradient2Color,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                                TableRow(children: [
                                                  Table(
                                                    border: TableBorder.all(
                                                        color: gradient2Color),
                                                    children: rows,
                                                  )
                                                ])
                                              ],
                                            );
                                          } else if (snapshot.hasError) {
                                            return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'),
                                            );
                                          } else {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    // pdf button download

                                    // Download PDF button
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          18, 0, 18, 24),
                                      child: StreamBuilder<DatabaseEvent>(
                                        stream: _databaseReference.onValue,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<DatabaseEvent>
                                                snapshot) {
                                          if (snapshot.hasData) {
                                            Map<dynamic, dynamic> data =
                                                snapshot.data!.snapshot.value
                                                    as Map<dynamic, dynamic>;

                                            return Center(
                                              child: FractionallySizedBox(
                                                widthFactor: 0.8,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    if (dropdownValue ==
                                                        'Today') {
                                                      // Create a new PDF document
                                                      PdfDocument document =
                                                          PdfDocument();

                                                      // Add a new page to the document
                                                      PdfPage page =
                                                          document.pages.add();

                                                      // Create a PdfGrid
                                                      PdfGrid grid = PdfGrid();

                                                      // Add the columns to the grid
                                                      grid.columns
                                                          .add(count: 2);

                                                      // Add header to the grid
                                                      grid.headers.add(1);

                                                      // Set the header values
                                                      PdfGridRow header =
                                                          grid.headers[0];
                                                      header.cells[0].value =
                                                          'Grades';
                                                      header.cells[1].value =
                                                          'Classified';

                                                      // Add data rows to the grid
                                                      String todayDate =
                                                          '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year}';
                                                      var dailyData =
                                                          data[todayDate];

                                                      dailyData.forEach(
                                                          (key, value) {
                                                        PdfGridRow row =
                                                            grid.rows.add();
                                                        row.cells[0].value =
                                                            key;
                                                        row.cells[1].value =
                                                            value.toString();
                                                      });

                                                      // Set the grid style
                                                      grid.style = PdfGridStyle(
                                                        cellPadding:
                                                            PdfPaddings(
                                                                left: 2,
                                                                right: 3,
                                                                top: 4,
                                                                bottom: 5),
                                                        backgroundBrush:
                                                            PdfBrushes.white,
                                                        textBrush:
                                                            PdfBrushes.black,
                                                        font: PdfStandardFont(
                                                            PdfFontFamily
                                                                .timesRoman,
                                                            16),
                                                      );

                                                      // Add the title at the top center
                                                      // Header
                                                      page.graphics.drawString(
                                                        'Classified Abaca Fiber',
                                                        PdfStandardFont(
                                                            PdfFontFamily
                                                                .timesRoman,
                                                            22),
                                                        bounds: Rect.fromLTWH(
                                                          0,
                                                          0, // Top of the page
                                                          page
                                                              .getClientSize()
                                                              .width,
                                                          60,
                                                        ),
                                                        format: PdfStringFormat(
                                                            alignment:
                                                                PdfTextAlignment
                                                                    .center),
                                                      );

                                                      // Body (centered)
                                                      double gridHeight =
                                                          0; // Will store the height of the grid after drawing
                                                      PdfLayoutResult?
                                                          gridResult =
                                                          grid.draw(
                                                        page: page,
                                                        bounds: Rect.fromLTWH(
                                                          0,
                                                          80, // Positioned below the header
                                                          page
                                                              .getClientSize()
                                                              .width, // Full page width
                                                          0,
                                                        ),
                                                      );
                                                      if (gridResult != null) {
                                                        gridHeight = gridResult
                                                            .bounds.height;
                                                      }

                                                      // Footer
                                                      page.graphics.drawString(
                                                        '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year}',
                                                        PdfStandardFont(
                                                            PdfFontFamily
                                                                .timesRoman,
                                                            16),
                                                        bounds: Rect.fromLTWH(
                                                          0,
                                                          80 +
                                                              gridHeight +
                                                              20, // Positioned below the body (grid) with some spacing
                                                          page
                                                              .getClientSize()
                                                              .width,
                                                          60,
                                                        ),
                                                        format: PdfStringFormat(
                                                            alignment:
                                                                PdfTextAlignment
                                                                    .right),
                                                      );

                                                      // Save the document
                                                      List<int> bytes =
                                                          await document.save();

                                                      // Dispose the document
                                                      document.dispose();

                                                      // Get external storage directory
                                                      final directory =
                                                          await getApplicationSupportDirectory();

                                                      // Get directory path
                                                      final path =
                                                          directory.path;

                                                      // Create an empty file to write PDF data
                                                      File file = File(
                                                          '$path/Output.pdf');

                                                      // Write PDF data to the file
                                                      await file.writeAsBytes(
                                                          bytes,
                                                          flush: true);

                                                      // Open the PDF document in mobile
                                                      OpenFile.open(
                                                          '$path/Output.pdf');
                                                    } else if (dropdownValue ==
                                                        'This Week') {
                                                      // Create a new PDF document
                                                      PdfDocument document =
                                                          PdfDocument();

                                                      // Add a new page to the document
                                                      PdfPage page =
                                                          document.pages.add();

                                                      // Create a PdfGrid
                                                      PdfGrid grid = PdfGrid();

                                                      // Add the columns to the grid
                                                      grid.columns
                                                          .add(count: 2);

                                                      // Add header to the grid
                                                      grid.headers.add(1);

                                                      // Set the header values
                                                      PdfGridRow header =
                                                          grid.headers[0];
                                                      header.cells[0].value =
                                                          'Grades';
                                                      header.cells[1].value =
                                                          'Classified';

                                                      // Add data rows to the grid
                                                      DateTime startOfWeek = DateTime
                                                              .now()
                                                          .subtract(Duration(
                                                              days: DateTime
                                                                          .now()
                                                                      .weekday -
                                                                  1));
                                                      DateTime endOfWeek =
                                                          startOfWeek.add(
                                                              const Duration(
                                                                  days: 6));
                                                      List<String> weeklyDates =
                                                          [];
                                                      for (var i = 0;
                                                          i < 7;
                                                          i++) {
                                                        var date = startOfWeek
                                                            .add(Duration(
                                                                days: i));
                                                        weeklyDates.add(
                                                            '${date.month}-${date.day}-${date.year}');
                                                      }

                                                      Map<String, int>
                                                          weeklyTotals = {};
                                                      weeklyDates
                                                          .forEach((date) {
                                                        if (data.containsKey(
                                                            date)) {
                                                          data[date].forEach(
                                                              (key, value) {
                                                            weeklyTotals[key] =
                                                                (weeklyTotals[
                                                                            key] ??
                                                                        0) +
                                                                    (value
                                                                        as int);
                                                          });
                                                        }
                                                      });

                                                      weeklyTotals.forEach(
                                                          (key, value) {
                                                        PdfGridRow row =
                                                            grid.rows.add();
                                                        row.cells[0].value =
                                                            key;
                                                        row.cells[1].value =
                                                            value.toString();
                                                      });

                                                      // Set the grid style
                                                      grid.style = PdfGridStyle(
                                                        cellPadding:
                                                            PdfPaddings(
                                                                left: 2,
                                                                right: 3,
                                                                top: 4,
                                                                bottom: 5),
                                                        backgroundBrush:
                                                            PdfBrushes.white,
                                                        textBrush:
                                                            PdfBrushes.black,
                                                        font: PdfStandardFont(
                                                            PdfFontFamily
                                                                .timesRoman,
                                                            16),
                                                      );

                                                      // Add the title at the top center
                                                      // Header
                                                      page.graphics.drawString(
                                                        'Classified Abaca Fiber',
                                                        PdfStandardFont(
                                                            PdfFontFamily
                                                                .timesRoman,
                                                            22),
                                                        bounds: Rect.fromLTWH(
                                                          0,
                                                          0, // Top of the page
                                                          page
                                                              .getClientSize()
                                                              .width,
                                                          60,
                                                        ),
                                                        format: PdfStringFormat(
                                                            alignment:
                                                                PdfTextAlignment
                                                                    .center),
                                                      );

                                                      // Body (centered)
                                                      double gridHeight =
                                                          0; // Will store the height of the grid after drawing
                                                      PdfLayoutResult?
                                                          gridResult =
                                                          grid.draw(
                                                        page: page,
                                                        bounds: Rect.fromLTWH(
                                                          0,
                                                          80, // Positioned below the header
                                                          page
                                                              .getClientSize()
                                                              .width, // Full page width
                                                          0,
                                                        ),
                                                      );
                                                      if (gridResult != null) {
                                                        gridHeight = gridResult
                                                            .bounds.height;
                                                      }

                                                      // Footer
                                                      page.graphics.drawString(
                                                        '${startOfWeek.month}-${startOfWeek.day}-${startOfWeek.year} to ${endOfWeek.month}-${endOfWeek.day}-${endOfWeek.year}',
                                                        PdfStandardFont(
                                                            PdfFontFamily
                                                                .timesRoman,
                                                            16),
                                                        bounds: Rect.fromLTWH(
                                                          0,
                                                          80 +
                                                              gridHeight +
                                                              20, // Positioned below the body (grid) with some spacing
                                                          page
                                                              .getClientSize()
                                                              .width,
                                                          60,
                                                        ),
                                                        format: PdfStringFormat(
                                                            alignment:
                                                                PdfTextAlignment
                                                                    .right),
                                                      );

                                                      // Save the document
                                                      List<int> bytes =
                                                          await document.save();

                                                      // Dispose the document
                                                      document.dispose();

                                                      // Get external storage directory
                                                      final directory =
                                                          await getApplicationSupportDirectory();

                                                      // Get directory path
                                                      final path =
                                                          directory.path;

                                                      // Create an empty file to write PDF data
                                                      File file = File(
                                                          '$path/Output.pdf');

                                                      // Write PDF data to the file
                                                      await file.writeAsBytes(
                                                          bytes,
                                                          flush: true);

                                                      // Open the PDF document in mobile
                                                      OpenFile.open(
                                                          '$path/Output.pdf');
                                                    } else if (dropdownValue ==
                                                        'This Month') {
                                                      // Create a new PDF document
                                                      PdfDocument document =
                                                          PdfDocument();

                                                      // Add a new page to the document
                                                      PdfPage page =
                                                          document.pages.add();

                                                      // Create a PdfGrid
                                                      PdfGrid grid = PdfGrid();

                                                      // Add the columns to the grid
                                                      grid.columns
                                                          .add(count: 2);

                                                      // Add header to the grid
                                                      grid.headers.add(1);

                                                      // Set the header values
                                                      PdfGridRow header =
                                                          grid.headers[0];
                                                      header.cells[0].value =
                                                          'Grades';
                                                      header.cells[1].value =
                                                          'Classified';

                                                      // Add data rows to the grid
                                                      DateTime startOfMonth =
                                                          DateTime(
                                                              DateTime.now()
                                                                  .year,
                                                              DateTime.now()
                                                                  .month,
                                                              1);
                                                      DateTime endOfMonth =
                                                          DateTime(
                                                              DateTime.now()
                                                                  .year,
                                                              DateTime.now()
                                                                      .month +
                                                                  1,
                                                              0);
                                                      List<String>
                                                          monthlyDates = [];
                                                      for (var i =
                                                              startOfMonth.day;
                                                          i <= endOfMonth.day;
                                                          i++) {
                                                        monthlyDates.add(
                                                            '${DateTime.now().month}-$i-${DateTime.now().year}');
                                                      }

                                                      Map<String, int>
                                                          monthlyTotals = {};
                                                      monthlyDates
                                                          .forEach((date) {
                                                        if (data.containsKey(
                                                            date)) {
                                                          data[date].forEach(
                                                              (key, value) {
                                                            monthlyTotals[key] =
                                                                (monthlyTotals[
                                                                            key] ??
                                                                        0) +
                                                                    (value
                                                                        as int);
                                                          });
                                                        }
                                                      });

                                                      monthlyTotals.forEach(
                                                          (key, value) {
                                                        PdfGridRow row =
                                                            grid.rows.add();
                                                        row.cells[0].value =
                                                            key;
                                                        row.cells[1].value =
                                                            value.toString();
                                                      });

                                                      // Set the grid style
                                                      grid.style = PdfGridStyle(
                                                        cellPadding:
                                                            PdfPaddings(
                                                                left: 2,
                                                                right: 3,
                                                                top: 4,
                                                                bottom: 5),
                                                        backgroundBrush:
                                                            PdfBrushes.white,
                                                        textBrush:
                                                            PdfBrushes.black,
                                                        font: PdfStandardFont(
                                                            PdfFontFamily
                                                                .timesRoman,
                                                            16),
                                                      );

                                                      // Add the title at the top center
                                                      // Header
                                                      page.graphics.drawString(
                                                        'Classified Abaca Fiber',
                                                        PdfStandardFont(
                                                            PdfFontFamily
                                                                .timesRoman,
                                                            22),
                                                        bounds: Rect.fromLTWH(
                                                          0,
                                                          0, // Top of the page
                                                          page
                                                              .getClientSize()
                                                              .width,
                                                          60,
                                                        ),
                                                        format: PdfStringFormat(
                                                            alignment:
                                                                PdfTextAlignment
                                                                    .center),
                                                      );

                                                      // Body (centered)
                                                      double gridHeight =
                                                          0; // Will store the height of the grid after drawing
                                                      PdfLayoutResult?
                                                          gridResult =
                                                          grid.draw(
                                                        page: page,
                                                        bounds: Rect.fromLTWH(
                                                          0,
                                                          80, // Positioned below the header
                                                          page
                                                              .getClientSize()
                                                              .width, // Full page width
                                                          0,
                                                        ),
                                                      );
                                                      if (gridResult != null) {
                                                        gridHeight = gridResult
                                                            .bounds.height;
                                                      }

                                                      // Footer
                                                      page.graphics.drawString(
                                                        '${DateTime.now().month} - ${DateTime.now().year}',
                                                        PdfStandardFont(
                                                            PdfFontFamily
                                                                .timesRoman,
                                                            16),
                                                        bounds: Rect.fromLTWH(
                                                          0,
                                                          80 +
                                                              gridHeight +
                                                              20, // Positioned below the body (grid) with some spacing
                                                          page
                                                              .getClientSize()
                                                              .width,
                                                          60,
                                                        ),
                                                        format: PdfStringFormat(
                                                            alignment:
                                                                PdfTextAlignment
                                                                    .right),
                                                      );

                                                      // Save the document
                                                      List<int> bytes =
                                                          await document.save();

                                                      // Dispose the document
                                                      document.dispose();

                                                      // Get external storage directory
                                                      final directory =
                                                          await getApplicationSupportDirectory();

                                                      // Get directory path
                                                      final path =
                                                          directory.path;

                                                      // Create an empty file to write PDF data
                                                      File file = File(
                                                          '$path/Output.pdf');

                                                      // Write PDF data to the file
                                                      await file.writeAsBytes(
                                                          bytes,
                                                          flush: true);

                                                      // Open the PDF document in mobile
                                                      OpenFile.open(
                                                          '$path/Output.pdf');
                                                    }
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                gradient2Color),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18.0),
                                                      ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Download PDF',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  // end modal
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        22.5), // half of the button height
                  ),
                  padding: const EdgeInsets.all(0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [gradient1Color, gradient2Color],
                      begin: Alignment.topCenter,
                      end: Alignment
                          .bottomCenter, // Adjusted the gradient to top-bottom
                    ),
                    borderRadius: BorderRadius.circular(
                        22.5), // half of the button height
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: SvgPicture.string(
                      '''
            <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M26 8C27.0544 8 27.9182 8.81588 27.9945 9.85074L28 10V22C28 23.0544 27.1841 23.9182 26.1493 23.9945L26 24H25V19C25 17.9456 24.1841 17.0818 23.1493 17.0055L23 17H9C7.94564 17 7.08183 17.8159 7.00549 18.8507L7 19V24H6C4.94564 24 4.08183 23.1841 4.00549 22.1493L4 22V10C4 8.94564 4.81588 8.08183 5.85074 8.00549L6 8H26Z" fill="white"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M11 19H21C22.1046 19 23 19.8954 23 21V25C23 26.1046 22.1046 27 21 27H11C9.89543 27 9 26.1046 9 25V21C9 19.8954 9.89543 19 11 19Z" fill="white"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M11 4H21C22.1046 4 23 4.89543 23 6V7H9V6C9 4.89543 9.89543 4 11 4Z" fill="white"/>
</svg>
            ''',
                    ),
                  ),
                ),
              ),
            ),
          ),

// end summary

// picture

          Positioned(
            left: (MediaQuery.of(context).size.width - 70) / 2,
            bottom: 70,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(4),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                     _recognition = null;
                     _lastPrediction = null;
                      // _confidenceHidden = true;
                    _continuousCapture = !_continuousCapture;
                    shouldStartMatching =
                        _continuousCapture; // Update shouldStartMatching
                  });
                  if (_continuousCapture) {
                    predictionCache.resetPredictions();
               
                    _timer = Timer.periodic(const Duration(milliseconds: 500),
                        (timer) {
                      if (shouldStartMatching) {
                        // Only take picture and start matching if shouldStartMatching is true

                        _takePicture(
                          context,
                        );
                      }
                    });
                  } else {
                    _timer?.cancel();
                    setState(() {
                      _recognition = null;
                      // _confidenceHidden = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _continuousCapture ? Colors.red : gradient2Color,
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

        ],
      ),
    );
  }
}

class PredictionCache {
  final int maxCache;
  List<String> lastPredictions = [];

  PredictionCache(this.maxCache);

  void addPrediction(String prediction) {
    lastPredictions.add(prediction);
    if (lastPredictions.length > maxCache) {
      lastPredictions.removeAt(0); // Remove the oldest prediction
    }
  }

  void resetPredictions() {
    lastPredictions = [];
  }

  String? getMajorityPrediction() {
    if (lastPredictions.isEmpty) {
      return null; // No predictions yet
    }

    // if(lastPredictions.length < 2){
    //   return null;
    // }

    // Count occurrences of each prediction
    Map<String, int> predictionCounts = {};
    lastPredictions.forEach((prediction) {
      predictionCounts[prediction] = (predictionCounts[prediction] ?? 0) + 1;
    });

    // Find the prediction with the highest count
    String? majorityPrediction;
    int maxCount = 0;
    predictionCounts.forEach((prediction, count) {
      if (count > maxCount) {
        majorityPrediction = prediction;
        maxCount = count;
      }
    });

    return majorityPrediction;
  }
}
