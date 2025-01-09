import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../utilities/widgets/buttons/primary_button.dart';
import '../pages/patient_registration.dart';

class PdfPage extends StatefulWidget {
  final String opNumber;
  final String firstName;
  final String lastName;
  final String address;
  final String phone;
  final String age;

  // Constructor to accept the data
  PdfPage({
    required this.firstName,
    required this.lastName,
    required this.opNumber,
    required this.address,
    required this.phone,
    required this.age,
  });

  @override
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  // Method to load image from assets
  Future<pw.ImageProvider> loadAssetImage(String path) async {
    final data = await rootBundle.load(path);
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  // PDF Generator Method for Visiting Card Size OP Ticket
  Future<File?> generateOpTicketPdf({
    required String hospitalName,
    required String firstName,
    required String lastName,
    required String age,
    required String sex,
    required String phone,
    required String ticketNumber,
    required String department,
  }) async {
    final pdf = pw.Document();

    // Load the logo from assets
    final logo = await loadAssetImage('assets/splash.png');

    pdf.addPage(
      pw.Page(
        pageFormat:
            PdfPageFormat(88.9 * PdfPageFormat.mm, 50.8 * PdfPageFormat.mm),
        // Visiting card size in mm
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Hospital Logo and Name
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(logo, height: 20, width: 20),
                    pw.Expanded(
                      child: pw.Text(
                        hospitalName,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),

                pw.Text(
                  "OP Number: ${widget.opNumber}",
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),

                // Patient Name (First, Last)
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Name: ${widget.firstName} ${widget.lastName}",
                          style: pw.TextStyle(fontSize: 8)),
                      pw.SizedBox(width: 5),
                      pw.Text(" Age: ${widget.age}",
                          style: pw.TextStyle(fontSize: 8)),
                    ]),

                // Age, Sex

                pw.SizedBox(height: 5),
                pw.Text("Address: ${widget.address}",
                    style: pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 5),
                // Phone
                pw.Text("Phone: ${widget.phone}",
                    style: pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 5),

                // Department
                pw.Text("Department: $department",
                    style: pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 10),
                pw.Divider(
                  height: 10,
                ),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Text("Mail: foxton@gmail.com",
                          style: pw.TextStyle(fontSize: 8)),
                      pw.SizedBox(width: 5),
                      pw.Text("Contact: +914500155245",
                          style: pw.TextStyle(fontSize: 8)),
                    ]),
              ],
            ),
          );
        },
      ),
    );

    Directory? output;

    if (kIsWeb) {
      return null;
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        output = await getExternalStorageDirectory();
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        output = await getApplicationDocumentsDirectory();
      }
    }

    if (output != null) {
      final file = File("${output.path}/op_ticket_${widget.firstName}.pdf");
      await file.writeAsBytes(await pdf.save());
      return file;
    } else {
      throw Exception("Failed to get storage directory");
    }
  }

  // Method to call when generating the OP Ticket PDF
  Future<void> _generateOpTicket() async {
    try {
      File? pdfFile = await generateOpTicketPdf(
        hospitalName: "City Hospital",
        firstName: "John",
        lastName: "Doe",
        age: "30",
        sex: "Male",
        phone: "1234567890",
        ticketNumber: "OP123456",
        department: "Emergency",
      );
      if (pdfFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generated at: ${pdfFile.path}'),
            backgroundColor: Colors.green, // Success color
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generation is not supported for web.'),
            backgroundColor: Colors.orange, // Web not supported color
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate OP ticket PDF'),
          backgroundColor: Colors.red, // Error color
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'OP Ticket',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontFamily: 'SanFrancisco'),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => PatientRegistration()),
                (Route<dynamic> route) =>
                    false, // This removes all previous routes
              );
            },
            icon:
                Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double buttonWidth = constraints.maxWidth * 0.4;
          double buttonHeight = 500;

          return Center(
            child: SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: Column(
                children: [
                  Lottie.asset(
                    "assets/patient.json",
                    height: 400,
                    width: buttonWidth,
                    repeat: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    onPressed: _generateOpTicket,
                    label: 'Generate OP Ticket',
                    width: screenWidth * 0.5,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
