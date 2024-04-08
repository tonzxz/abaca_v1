import 'package:flutter/material.dart';

class AbacaFiberGradesScreen extends StatefulWidget {
  const AbacaFiberGradesScreen({super.key});

  @override
  _AbacaFiberGradesScreenState createState() => _AbacaFiberGradesScreenState();
}

class _AbacaFiberGradesScreenState extends State<AbacaFiberGradesScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
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
        ],
      ),
    );
  }

  Widget _buildSlide1() {
    return Column(
      children: [
        const Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Center(
                    child: Text(
                      'NORMAL HAND-STRIPPED ABACA FIBER GRADES',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'WHAT YOU NEED TO KNOW:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                      '- Abaca -- plant scientifically known as Musa Textilis nee'),
                  Text('- Abaca Fiber -- fiber extracted from the Abaca Plant'),
                  Text(
                      '- Hand-Stripped Abaca Fiber -- fiber extracted through the use of manually operated stripping apparatus (stripping knife).'),
                  Text(
                      '- Grade -- refers to the fiber quality as designated by an alphanumeric code generally described as normal, residual and wide strips fiber.'),
                  SizedBox(height: 16),
                  Text(
                    'Abaca fiber grades shall be distinguished according to factors such as:',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                      'a) Where it was extracted from (Inner leaf sheath, outer leaf sheath, etc)'),
                  Text('b) Fiber strand size'),
                  Text('c) Color'),
                  Text('d) Stripping'),
                  Text('d) Texture'),
                ],
              ),
            ),
          ),
        ),
        _buildDownButton(0),
      ],
    );
  }

  Widget _buildSlide2() {
    return Column(
      children: [
        _buildUpButton(1),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      '8 Normal Grades of Hand-stripped Abaca Fiber',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
        _buildDownButton(1),
      ],
    );
  }

  Widget _buildSlide3() {
    return Column(
      children: [
        _buildUpButton(2),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
        _buildDownButton(2),
      ],
    );
  }

  Widget _buildSlide4() {
    return Column(
      children: [
        _buildUpButton(3),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
        _buildDownButton(3),
      ],
    );
  }

  Widget _buildSlide5() {
    return Column(
      children: [
        _buildUpButton(4),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
        _buildDownButton(4),
      ],
    );
  }

  Widget _buildSlide6() {
    return Column(
      children: [
        _buildUpButton(5),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
        _buildDownButton(5),
      ],
    );
  }

  Widget _buildSlide7() {
    return Column(
      children: [
        _buildUpButton(6),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
        _buildDownButton(6),
      ],
    );
  }

  Widget _buildSlide8() {
    return Column(
      children: [
        _buildUpButton(7),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
        _buildDownButton(7),
      ],
    );
  }

  Widget _buildSlide9() {
    return Column(
      children: [
        _buildUpButton(8),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
        _buildDownButton(8),
      ],
    );
  }

  Widget _buildUpButton(int currentIndex) {
    return IconButton(
      icon: Icon(Icons.arrow_upward),
      onPressed: currentIndex > 0
          ? () {
              _pageController.animateToPage(
                currentIndex - 1,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          : null,
    );
  }

  Widget _buildDownButton(int currentIndex) {
    return IconButton(
      icon: Icon(Icons.arrow_downward),
      onPressed: currentIndex < 8
          ? () {
              _pageController.animateToPage(
                currentIndex + 1,
                duration: Duration(milliseconds: 300),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            gradeName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Image.asset(
            imagePath,
            width: 400,
            height: 400,
          ),
        ),
        const SizedBox(height: 8),
        Text('Extracted from: $extractedFrom'),
        Text('Strand Size: $strandSize'),
        Text('Color: $color'),
        Text('Stripping: $stripping'),
        Text('Texture: $texture'),
      ],
    );
  }
}
