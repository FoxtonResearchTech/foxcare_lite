import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';

import '../../utilities/widgets/buttons/primary_button.dart';
import '../pages/patient_registration.dart';

class PdfPage extends StatefulWidget {
  final String opNumber;
  final String firstName;
  final String lastName;
  final String address;
  final String phone;
  final String age;
  final String sex;

  // Constructor to accept the data
  PdfPage({
    required this.firstName,
    required this.lastName,
    required this.opNumber,
    required this.address,
    required this.phone,
    required this.age,
    required this.sex,
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

  Future<void> generateOpTicketPdf({
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
        pageFormat: const PdfPageFormat(
            88.9 * PdfPageFormat.mm, 50.8 * PdfPageFormat.mm),
        // Visiting card size in mm
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8),
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
                  "OP Number: $ticketNumber",
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
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(width: 5),
                    pw.Text("Age: ${widget.age}",
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.SizedBox(height: 5),

                // Address
                pw.Text("Address: ${widget.address}",
                    style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 5),

                // Phone
                pw.Text("Phone: ${widget.phone}",
                    style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 5),

                // Department
                pw.Text("Department: $department",
                    style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 10),
                pw.Divider(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Text("Mail: foxton@gmail.com",
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(width: 5),
                    pw.Text("Contact: +914500155245",
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    if (kIsWeb) {
      // Handle PDF for web
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: 'op_ticket.pdf');
    } else {
      Directory? output;

      if (Platform.isAndroid || Platform.isIOS) {
        output = await getExternalStorageDirectory();
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        output = await getApplicationDocumentsDirectory();
      }

      if (output != null) {
        final file = File("${output.path}/op_ticket_${firstName}.pdf");
        await file.writeAsBytes(await pdf.save());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generated at: ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Failed to get storage directory");
      }
    }
  }

  Future<void> _generateOpTicket() async {
    try {
      await generateOpTicketPdf(
        hospitalName: "City Hospital",
        firstName: widget.firstName,
        lastName: widget.lastName,
        age: widget.age,
        sex: widget.sex,
        phone: widget.phone,
        ticketNumber: widget.opNumber,
        department: "Emergency",
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate OP ticket PDF'),
          backgroundColor: Colors.red,
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
        title: const Text(
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
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18)),
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
                  const SizedBox(
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
