import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class MyCamera extends StatefulWidget {
  const MyCamera({Key? key}) : super(key: key);

  @override
  State<MyCamera> createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

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
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize().then((_) {

      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
   
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_controller != null)
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
               
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: CameraPreview(_controller!),
                    ),
                  );
                } else {
                 
                  return const CircularProgressIndicator();
                }
              },
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                    
                    },
                    color: Colors.white,
                    iconSize: 48.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
