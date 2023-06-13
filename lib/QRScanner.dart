import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // Instantiate a DatabaseService object
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();

      String? fullCode = scanData.code;
      String? loggedInEmail = FirebaseAuth.instance.currentUser?.email;

      if (fullCode != null && loggedInEmail != null) {
        String documentName = fullCode.split('çç')[1];
        controller.pauseCamera();

        bool studentExists = await _databaseService.studentExists(documentName, loggedInEmail);

        if (studentExists) {
                controller.pauseCamera();
          // Show a warning popup
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Aviso!"),
                content: Text("Já está registado nesta aula."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        } else {
          await _databaseService.addStudent(documentName);
                controller.pauseCamera();


          String contentBeforeCC = fullCode.split('çç')[0];

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Registou-se com sucesso!"),
                content: Text(contentBeforeCC),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Erro"),
              content: Text("Ocorreu um erro. Tente novamente."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }

      controller.resumeCamera();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}