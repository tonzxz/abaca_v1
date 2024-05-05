import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:abaca_classification/theme/styles.dart';
import 'package:firebase_database/firebase_database.dart';

class PrintingPage extends StatefulWidget {
  const PrintingPage({Key? key}) : super(key: key);

  @override
  _PrintingPageState createState() => _PrintingPageState();
}

class _PrintingPageState extends State<PrintingPage> {
  String dropdownValue = 'Today';
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

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
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
      List<String> weeklyDates = [];
      for (var i = 0; i < 7; i++) {
        var date = startOfWeek.add(Duration(days: i));
        weeklyDates.add('${date.month}-${date.day}-${date.year}-R');
      }

      Map<String, int> weeklyTotals = {};
      weeklyDates.forEach((date) {
        if (data.containsKey(date)) {
          data[date].forEach((key, value) {
            weeklyTotals[key] = (weeklyTotals[key] ?? 0) + (value.length as int);
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
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
      List<String> monthlyDates = [];
      for (var i = startOfMonth.day; i <= endOfMonth.day; i++) {
        monthlyDates.add('${now.month}-$i-${now.year}');
      }

      Map<String, int> monthlyTotals = {};
      monthlyDates.forEach((date) {
        if (data.containsKey(date)) {
          data[date].forEach((key, value) {
            monthlyTotals[key] = (monthlyTotals[key] ?? 0) + (value.length as int);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 30,
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Center(
                child: Dialog(
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ), // Adjust the maximum height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32.0),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: Center(
                            child: Text(
                              "Classified Abaca Fibers",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: gradient2Color,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Dropdown menu
                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
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
                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
                          child: StreamBuilder<DatabaseEvent>(
                            stream: _databaseReference.onValue,
                            builder: (BuildContext context,
                                AsyncSnapshot<DatabaseEvent> snapshot) {
                              if (snapshot.hasData) {
                                Map<dynamic, dynamic> data = snapshot.data!
                                    .snapshot.value as Map<dynamic, dynamic>;
                                List<TableRow> rows =
                                    generateTableRows(data, dropdownValue);

                                String dateRange = '';
                                if (dropdownValue == 'Today') {
                                  String todayDate =
                                      '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year}';
                                  dateRange = todayDate;
                                } else if (dropdownValue == 'This Week') {
                                  DateTime startOfWeek = DateTime.now()
                                      .subtract(Duration(
                                          days: DateTime.now().weekday - 1));
                                  DateTime endOfWeek =
                                      startOfWeek.add(const Duration(days: 6));
                                  dateRange =
                                      '${startOfWeek.month}-${startOfWeek.day}-${startOfWeek.year} to ${endOfWeek.month}-${endOfWeek.day}-${endOfWeek.year}';
                                } else if (dropdownValue == 'This Month') {
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
                                  border:
                                      TableBorder.all(color: gradient2Color),
                                  children: [
                                    TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Center(
                                          child: Text(
                                            dateRange,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: gradient2Color,
                                              fontWeight: FontWeight.w600,
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
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                        // pdf button download

                        // Download PDF button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                          child: StreamBuilder<DatabaseEvent>(
                            stream: _databaseReference.onValue,
                            builder: (BuildContext context,
                                AsyncSnapshot<DatabaseEvent> snapshot) {
                              if (snapshot.hasData) {
                                Map<dynamic, dynamic> data = snapshot.data!
                                    .snapshot.value as Map<dynamic, dynamic>;

                                return Center(
                                  child: FractionallySizedBox(
                                    widthFactor: 0.8,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (dropdownValue == 'Today') {
                                          // Create a new PDF document
                                          PdfDocument document = PdfDocument();

                                          // Add a new page to the document
                                          PdfPage page = document.pages.add();

                                          // Create a PdfGrid
                                          PdfGrid grid = PdfGrid();

                                          // Add the columns to the grid
                                          grid.columns.add(count: 2);

                                          // Add header to the grid
                                          grid.headers.add(1);

                                          // Set the header values
                                          PdfGridRow header = grid.headers[0];
                                          header.cells[0].value = 'Grades';
                                          header.cells[1].value = 'Classified';

                                          // Add data rows to the grid
                                          String todayDate =
                                              '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year}';
                                          var dailyData = data[todayDate];

                                          dailyData.forEach((key, value) {
                                            PdfGridRow row = grid.rows.add();
                                            row.cells[0].value = key;
                                            row.cells[1].value =
                                                value.toString();
                                          });

                                          // Set the grid style
                                          grid.style = PdfGridStyle(
                                            cellPadding: PdfPaddings(
                                                left: 2,
                                                right: 3,
                                                top: 4,
                                                bottom: 5),
                                            backgroundBrush: PdfBrushes.white,
                                            textBrush: PdfBrushes.black,
                                            font: PdfStandardFont(
                                                PdfFontFamily.timesRoman, 16),
                                          );

                                          // Add the title at the top center
                                          // Header
                                          page.graphics.drawString(
                                            'Classified Abaca Fiber',
                                            PdfStandardFont(
                                                PdfFontFamily.timesRoman, 22),
                                            bounds: Rect.fromLTWH(
                                              0,
                                              0, // Top of the page
                                              page.getClientSize().width,
                                              60,
                                            ),
                                            format: PdfStringFormat(
                                                alignment:
                                                    PdfTextAlignment.center),
                                          );

                                          // Body (centered)
                                          double gridHeight =
                                              0; // Will store the height of the grid after drawing
                                          PdfLayoutResult? gridResult =
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
                                            gridHeight =
                                                gridResult.bounds.height;
                                          }

                                          // Footer
                                          page.graphics.drawString(
                                            '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year}',
                                            PdfStandardFont(
                                                PdfFontFamily.timesRoman, 16),
                                            bounds: Rect.fromLTWH(
                                              0,
                                              80 +
                                                  gridHeight +
                                                  20, // Positioned below the body (grid) with some spacing
                                              page.getClientSize().width,
                                              60,
                                            ),
                                            format: PdfStringFormat(
                                                alignment:
                                                    PdfTextAlignment.right),
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
                                          final path = directory.path;

                                          // Create an empty file to write PDF data
                                          File file = File('$path/Output.pdf');

                                          // Write PDF data to the file
                                          await file.writeAsBytes(bytes,
                                              flush: true);

                                          // Open the PDF document in mobile
                                          OpenFile.open('$path/Output.pdf');
                                        } else if (dropdownValue ==
                                            'This Week') {
                                          // Create a new PDF document
                                          PdfDocument document = PdfDocument();

                                          // Add a new page to the document
                                          PdfPage page = document.pages.add();

                                          // Create a PdfGrid
                                          PdfGrid grid = PdfGrid();

                                          // Add the columns to the grid
                                          grid.columns.add(count: 2);

                                          // Add header to the grid
                                          grid.headers.add(1);

                                          // Set the header values
                                          PdfGridRow header = grid.headers[0];
                                          header.cells[0].value = 'Grades';
                                          header.cells[1].value = 'Classified';

                                          // Add data rows to the grid
                                          DateTime startOfWeek = DateTime.now()
                                              .subtract(Duration(
                                                  days: DateTime.now().weekday -
                                                      1));
                                          DateTime endOfWeek = startOfWeek
                                              .add(const Duration(days: 6));
                                          List<String> weeklyDates = [];
                                          for (var i = 0; i < 7; i++) {
                                            var date = startOfWeek
                                                .add(Duration(days: i));
                                            weeklyDates.add(
                                                '${date.month}-${date.day}-${date.year}');
                                          }

                                          Map<String, int> weeklyTotals = {};
                                          weeklyDates.forEach((date) {
                                            if (data.containsKey(date)) {
                                              data[date].forEach((key, value) {
                                                weeklyTotals[key] =
                                                    (weeklyTotals[key] ?? 0) +
                                                        (value as int);
                                              });
                                            }
                                          });

                                          weeklyTotals.forEach((key, value) {
                                            PdfGridRow row = grid.rows.add();
                                            row.cells[0].value = key;
                                            row.cells[1].value =
                                                value.toString();
                                          });

                                          // Set the grid style
                                          grid.style = PdfGridStyle(
                                            cellPadding: PdfPaddings(
                                                left: 2,
                                                right: 3,
                                                top: 4,
                                                bottom: 5),
                                            backgroundBrush: PdfBrushes.white,
                                            textBrush: PdfBrushes.black,
                                            font: PdfStandardFont(
                                                PdfFontFamily.timesRoman, 16),
                                          );

                                          // Add the title at the top center
                                          // Header
                                          page.graphics.drawString(
                                            'Classified Abaca Fiber',
                                            PdfStandardFont(
                                                PdfFontFamily.timesRoman, 22),
                                            bounds: Rect.fromLTWH(
                                              0,
                                              0, // Top of the page
                                              page.getClientSize().width,
                                              60,
                                            ),
                                            format: PdfStringFormat(
                                                alignment:
                                                    PdfTextAlignment.center),
                                          );

                                          // Body (centered)
                                          double gridHeight =
                                              0; // Will store the height of the grid after drawing
                                          PdfLayoutResult? gridResult =
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
                                            gridHeight =
                                                gridResult.bounds.height;
                                          }

                                          // Footer
                                          page.graphics.drawString(
                                            '${startOfWeek.month}-${startOfWeek.day}-${startOfWeek.year} to ${endOfWeek.month}-${endOfWeek.day}-${endOfWeek.year}',
                                            PdfStandardFont(
                                                PdfFontFamily.timesRoman, 16),
                                            bounds: Rect.fromLTWH(
                                              0,
                                              80 +
                                                  gridHeight +
                                                  20, // Positioned below the body (grid) with some spacing
                                              page.getClientSize().width,
                                              60,
                                            ),
                                            format: PdfStringFormat(
                                                alignment:
                                                    PdfTextAlignment.right),
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
                                          final path = directory.path;

                                          // Create an empty file to write PDF data
                                          File file = File('$path/Output.pdf');

                                          // Write PDF data to the file
                                          await file.writeAsBytes(bytes,
                                              flush: true);

                                          // Open the PDF document in mobile
                                          OpenFile.open('$path/Output.pdf');
                                        } else if (dropdownValue ==
                                            'This Month') {
                                          // Create a new PDF document
                                          PdfDocument document = PdfDocument();

                                          // Add a new page to the document
                                          PdfPage page = document.pages.add();

                                          // Create a PdfGrid
                                          PdfGrid grid = PdfGrid();

                                          // Add the columns to the grid
                                          grid.columns.add(count: 2);

                                          // Add header to the grid
                                          grid.headers.add(1);

                                          // Set the header values
                                          PdfGridRow header = grid.headers[0];
                                          header.cells[0].value = 'Grades';
                                          header.cells[1].value = 'Classified';

                                          // Add data rows to the grid
                                          DateTime startOfMonth = DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              1);
                                          DateTime endOfMonth = DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month + 1,
                                              0);
                                          List<String> monthlyDates = [];
                                          for (var i = startOfMonth.day;
                                              i <= endOfMonth.day;
                                              i++) {
                                            monthlyDates.add(
                                                '${DateTime.now().month}-$i-${DateTime.now().year}');
                                          }

                                          Map<String, int> monthlyTotals = {};
                                          monthlyDates.forEach((date) {
                                            if (data.containsKey(date)) {
                                              data[date].forEach((key, value) {
                                                monthlyTotals[key] =
                                                    (monthlyTotals[key] ?? 0) +
                                                        (value as int);
                                              });
                                            }
                                          });

                                          monthlyTotals.forEach((key, value) {
                                            PdfGridRow row = grid.rows.add();
                                            row.cells[0].value = key;
                                            row.cells[1].value =
                                                value.toString();
                                          });

                                          // Set the grid style
                                          grid.style = PdfGridStyle(
                                            cellPadding: PdfPaddings(
                                                left: 2,
                                                right: 3,
                                                top: 4,
                                                bottom: 5),
                                            backgroundBrush: PdfBrushes.white,
                                            textBrush: PdfBrushes.black,
                                            font: PdfStandardFont(
                                                PdfFontFamily.timesRoman, 16),
                                          );

                                          // Add the title at the top center
                                          // Header
                                          page.graphics.drawString(
                                            'Classified Abaca Fiber',
                                            PdfStandardFont(
                                                PdfFontFamily.timesRoman, 22),
                                            bounds: Rect.fromLTWH(
                                              0,
                                              0, // Top of the page
                                              page.getClientSize().width,
                                              60,
                                            ),
                                            format: PdfStringFormat(
                                                alignment:
                                                    PdfTextAlignment.center),
                                          );

                                          // Body (centered)
                                          double gridHeight =
                                              0; // Will store the height of the grid after drawing
                                          PdfLayoutResult? gridResult =
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
                                            gridHeight =
                                                gridResult.bounds.height;
                                          }

                                          // Footer
                                          page.graphics.drawString(
                                            '${DateTime.now().month} - ${DateTime.now().year}',
                                            PdfStandardFont(
                                                PdfFontFamily.timesRoman, 16),
                                            bounds: Rect.fromLTWH(
                                              0,
                                              80 +
                                                  gridHeight +
                                                  20, // Positioned below the body (grid) with some spacing
                                              page.getClientSize().width,
                                              60,
                                            ),
                                            format: PdfStringFormat(
                                                alignment:
                                                    PdfTextAlignment.right),
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
                                          final path = directory.path;

                                          // Create an empty file to write PDF data
                                          File file = File('$path/Output.pdf');

                                          // Write PDF data to the file
                                          await file.writeAsBytes(bytes,
                                              flush: true);

                                          // Open the PDF document in mobile
                                          OpenFile.open('$path/Output.pdf');
                                        }
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                gradient2Color),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
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
            ),
          ],
        ),
      ),
    );
  }
}
