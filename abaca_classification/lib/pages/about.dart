import 'dart:async';
import 'package:flutter/material.dart';
import 'package:abaca_classification/theme/styles.dart';

class ImageSlider extends StatefulWidget {
  final Function() onTap;
  final List<String> imagePaths;

  const ImageSlider({
    Key? key,
    required this.onTap,
    required this.imagePaths,
  }) : super(key: key);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 1500), (Timer timer) {
      setState(() {
        _currentImageIndex =
            (_currentImageIndex + 1) % widget.imagePaths.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          widget.imagePaths[_currentImageIndex],
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class AbacaFiberGradesScreen extends StatefulWidget {
  const AbacaFiberGradesScreen({super.key});

  @override
  _AbacaFiberGradesScreenState createState() => _AbacaFiberGradesScreenState();
}

class _AbacaFiberGradesScreenState extends State<AbacaFiberGradesScreen> {
  final PageController _pageController = PageController();

  void _navigateToSlide(int slideNumber) {
    _pageController.animateToPage(
      slideNumber,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 45,
        leading: Container(
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
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swiped from top to bottom (scroll down)
            int currentPage = _pageController.page!.toInt();
            if (currentPage < 8) {
              _pageController.animateToPage(
                currentPage + 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          } else if (details.primaryVelocity! < 0) {
            // Swiped from bottom to top (scroll up)
            int currentPage = _pageController.page!.toInt();
            if (currentPage > 0) {
              _pageController.animateToPage(
                currentPage - 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        },
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          children: [
            _buildSlide1(),
            _buildSlide2(),
            _buildSlide3(),
            _buildSlide4(),
            _buildSlide5(),
            _buildSlide6(),
            _buildSlide7(),
            _buildSlide8(),
            _buildSlide9(),
            _buildSlide10(),
            _buildSlide11(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Contents:',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: gradient2Color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ImageSlider(
                        onTap: () => _navigateToSlide(1),
                        imagePaths: const [
                          'assets/images/content1.png',
                          'assets/images/abacalogo.png',
                        ],
                      ),
                      ImageSlider(
                        onTap: () => _navigateToSlide(10),
                        imagePaths: const [
                          'assets/images/content10.png',
                          'assets/images/ken.png',
                          'assets/images/wa.png',
                          'assets/images/ton.png',
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ImageSlider(
                        onTap: () => _navigateToSlide(2),
                        imagePaths: const [
                          'assets/images/content2.png',
                          'assets/images/EF1.png',
                        ],
                      ),
                      ImageSlider(
                        onTap: () => _navigateToSlide(3),
                        imagePaths: const [
                          'assets/images/content3.png',
                          'assets/images/S21.png',
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ImageSlider(
                        onTap: () => _navigateToSlide(4),
                        imagePaths: const [
                          'assets/images/content4.png',
                          'assets/images/S31.png',
                        ],
                      ),
                      ImageSlider(
                        onTap: () => _navigateToSlide(5),
                        imagePaths: const [
                          'assets/images/content5.png',
                          'assets/images/I1.png',
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ImageSlider(
                        onTap: () => _navigateToSlide(6),
                        imagePaths: const [
                          'assets/images/content6.png',
                          'assets/images/G1.png',
                        ],
                      ),
                      ImageSlider(
                        onTap: () => _navigateToSlide(7),
                        imagePaths: const [
                          'assets/images/content7.png',
                          'assets/images/H1.png',
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ImageSlider(
                        onTap: () => _navigateToSlide(8),
                        imagePaths: const [
                          'assets/images/content8.png',
                          'assets/images/JK1.png',
                        ],
                      ),
                      ImageSlider(
                        onTap: () => _navigateToSlide(9),
                        imagePaths: const [
                          'assets/images/content9.png',
                          'assets/images/M11.png',
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        _downButton(1),
      ],
    );
  }

  Widget _buildSlide2() {
    return Column(
      children: [
        _upButton(1),
        const Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Classification of Hand-stripped Abacá Fiber Grades',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: gradient2Color,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Abaca',
                    style: TextStyle(
                      fontWeight: fontMD,
                      fontSize: textMD,
                      color: gradient2Color,
                    ),
                  ),
                  Text('- plant scientifically known as Musa Textilis nee'),
                  SizedBox(height: 8),
                  Text(
                    'Abaca Fiber',
                    style: TextStyle(
                      fontWeight: fontMD,
                      fontSize: textMD,
                      color: gradient2Color,
                    ),
                  ),
                  Text('- fiber extracted from the Abaca Plant'),
                  SizedBox(height: 8),
                  Text(
                    'Hand-Stripped Abaca Fiber ',
                    style: TextStyle(
                      fontWeight: fontMD,
                      fontSize: textMD,
                      color: gradient2Color,
                    ),
                  ),
                  Text(
                      '- fiber extracted through the use of manually operated stripping apparatus (stripping knife).'),
                  SizedBox(height: 8),
                  Text(
                    'Grade ',
                    style: TextStyle(
                      fontWeight: fontMD,
                      fontSize: textMD,
                      color: gradient2Color,
                    ),
                  ),
                  Text(
                      '- refers to the fiber quality as designated by an alphanumeric code generally described as normal, residual and wide strips fiber.'),
                  SizedBox(height: 16),
                  Text(
                    'Abaca fiber grades shall be distinguished according to factors such as:',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: fontMD,
                      fontSize: textSM,
                      color: gradient2Color,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'a) Where it was extracted from (Inner leaf sheath, outer leaf sheath, etc)',
                    style: TextStyle(fontWeight: fontMD),
                  ),
                  Text('b) Fiber strand size',
                      style: TextStyle(fontWeight: fontMD)),
                  Text('c) Color', style: TextStyle(fontWeight: fontMD)),
                  Text('d) Stripping', style: TextStyle(fontWeight: fontMD)),
                  Text('d) Texture', style: TextStyle(fontWeight: fontMD)),
                ],
              ),
            ),
          ),
        ),
        _downButton(1),
      ],
    );
  }

  Widget _buildSlide3() {
    return Column(
      children: [
        _upButton(1),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      '8 Normal Grades of Hand-stripped Abaca Fiber',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: fontXL,
                          color: gradient2Color),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFiberGrade(
                    gradeName: 'Mid current (EF)',
                    imagePath: 'assets/images/EF.jpg',
                    extractedFrom: 'Inner Leaf sheath',
                    strandSize: '0.20 -- 0.50 mm',
                    color:
                        'Light ivory to a hue of very light brown to very light ochre. Frequently intermixed with ivory white.',
                    stripping: 'Excellent',
                    texture: 'Soft',
                  ),
                ],
              ),
            ),
          ),
        ),
        _downButton(2),
      ],
    );
  }

  Widget _buildSlide4() {
    return Column(
      children: [
        _upButton(2),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFiberGrade(
                    gradeName: 'Streaky Two (S2)',
                    imagePath: 'assets/images/S2.jpg',
                    extractedFrom: 'Next to the outer leaf sheath',
                    strandSize: '0.20 -- 0.50 mm',
                    color:
                        'Ivory white, slightly tinged with very light brown to red or purple streak',
                    stripping: 'Excellent',
                    texture: 'Soft',
                  ),
                ],
              ),
            ),
          ),
        ),
        _downButton(3),
      ],
    );
  }

  Widget _buildSlide5() {
    return Column(
      children: [
        _upButton(3),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFiberGrade(
                    gradeName: 'Streaky Three (S3)',
                    imagePath: 'assets/images/S3.jpg',
                    extractedFrom: 'Outer leafsheath exposed to the sun',
                    strandSize: '0.20 -- 0.50 mm',
                    color:
                        'Predominant color -- light to dark red or purple or a shade of dull to dark brown',
                    stripping: 'Excellent',
                    texture: 'Soft',
                  ),
                ],
              ),
            ),
          ),
        ),
        _downButton(4),
      ],
    );
  }

  Widget _buildSlide6() {
    return Column(
      children: [
        _upButton(4),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFiberGrade(
                    gradeName: 'Current (I)',
                    imagePath: 'assets/images/I.jpg',
                    extractedFrom: 'Inner and middle leaf sheath',
                    strandSize: '0.51 -- 0.99 mm',
                    color: 'Very light brown to light brown',
                    stripping: 'Good',
                    texture: 'Medium Soft',
                  ),
                ],
              ),
            ),
          ),
        ),
        _downButton(5),
      ],
    );
  }

  Widget _buildSlide7() {
    return Column(
      children: [
        _upButton(5),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFiberGrade(
                    gradeName: 'Soft Seconds (G)',
                    imagePath: 'assets/images/G.jpg',
                    extractedFrom:
                        'Next to the outer leafsheath or similar leafsheath source where S2 is obtained',
                    strandSize: '0.51 -- 0.99 mm',
                    color: 'Dingy white, light green and dull brown',
                    stripping: 'Good',
                    texture: 'Medium Soft',
                  ),
                ],
              ),
            ),
          ),
        ),
        _downButton(6),
      ],
    );
  }

  Widget _buildSlide8() {
    return Column(
      children: [
        _upButton(6),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFiberGrade(
                    gradeName: 'Soft Brown (H)',
                    imagePath: 'assets/images/H.jpg',
                    extractedFrom: 'Outer leaf sheath',
                    strandSize: '0.51 -- 0.99 mm',
                    color: 'Dark brown',
                    stripping: 'Good',
                    texture: '-',
                  ),
                ],
              ),
            ),
          ),
        ),
        _downButton(7),
      ],
    );
  }

  Widget _buildSlide9() {
    return Column(
      children: [
        _upButton(7),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFiberGrade(
                    gradeName: 'Seconds (JK)',
                    imagePath: 'assets/images/JK.jpg',
                    extractedFrom:
                        'Inner, middle and next to outer leaf sheath',
                    strandSize: '0.51 -- 0.99 mm',
                    color:
                        'Dull brown to dingy light brown or dingly light yellow, frequently streaked with light green',
                    stripping: 'Fair',
                    texture: '-',
                  ),
                ],
              ),
            ),
          ),
        ),
        _downButton(8),
      ],
    );
  }

  Widget _buildSlide10() {
    return Column(
      children: [
        _upButton(7),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFiberGrade(
                    gradeName: 'Medium Brown (M1)',
                    imagePath: 'assets/images/M1.jpg',
                    extractedFrom: 'Outer leaf sheath',
                    strandSize: '0.51 -- 0.99 mm',
                    color: 'Dark brown to almost black',
                    stripping: 'Fair',
                    texture: '-',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        _downButton(9),
      ],
    );
  }

  Widget _buildSlide11() {
    return Column(
      children: [
        _upButton(8),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'About us',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: gradient2Color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'The research team behind Abaca Grade Classifier, empowering abaca farmers with accurate and efficient abaca fiber grades classification.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageWithDescription(
                          'assets/images/10.png',
                          'c3zar',
                        ),
                      ),
                      SizedBox(width: 10), // Add some space between columns
                      Expanded(
                        child: _buildImageWithDescription(
                          'assets/images/11.png',
                          'Ryukkn',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height:
                          20), // Add some space between image row and the next row
                  Center(
                    child: _buildImageWithDescription(
                      'assets/images/12.png',
                      'Cocordz',
                    ),
                  ),
                  SizedBox(height: 20),
                  const Text(
                    'For more info, visit philfida.da.gov or read PNS/BAFS 180:2016.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Special thanks to:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('PhilFIDA Region V'),
                  const Text('Ching Bee Trading Corporation, Albay Branch'),
                ],
              ),
            ),
          ),
        ),
        _backToStartButton(1),
      ],
    );
  }

  Widget _buildImageWithDescription(String imagePath, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(70),
            child: Image.asset(
              imagePath,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 10), // Add some space between image and description
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: gradient2Color,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.all(8.0),
            constraints:
                BoxConstraints(minWidth: 120), // Set maximum width to 50
            child: Text(
              textAlign: TextAlign.center,
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // Text color is set to white
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _upButton(int currentIndex) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_upward,
        color: gradient2Color,
      ),
      onPressed: currentIndex > 0
          ? () {
              _pageController.animateToPage(
                currentIndex - 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          : null,
    );
  }

  Widget _backToStartButton(int currentIndex) {
    return IconButton(
      icon: const Icon(
        Icons.keyboard_double_arrow_up_sharp,
        color: gradient2Color,
      ),
      onPressed: currentIndex > 0
          ? () {
              _pageController.animateToPage(
                currentIndex - 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          : null,
    );
  }

  Widget _downButton(int currentIndex) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_downward,
        color: gradient2Color,
      ),
      onPressed: currentIndex < 13
          ? () {
              _pageController.animateToPage(
                currentIndex + 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          : null,
    );
  }

  Widget _buildFiberGrade({
    required String gradeName,
    required String imagePath,
    required String extractedFrom,
    required String strandSize,
    required String color,
    required String stripping,
    required String texture,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              gradeName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: gradient2Color,
                fontSize: textMD,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Extracted from: ',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: extractedFrom,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Strand Size: ',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: strandSize,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Color: ',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: color,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Stripping: ',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: stripping,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Texture: ',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: texture,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
