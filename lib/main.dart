import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  Uint8List? bytes;
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    getImage();
    getDevices();
  }

  /*
  arabic Invoice require printer that support arabic language , otherwise you can return the invoice as an image 
  them convert it to unit8List them print it
  */
  String url =
      "http://mohamedmostafa88-001-site4.etempurl.com/test/Print?TransId=0201000001";

  //Convert the Network image to unit8List Image
  Future<void> getImage() async {
    try {
      bytes = (await NetworkAssetBundle(Uri.parse(url)).load(url))
          .buffer
          .asUint8List();
    } catch (e) {
      // print(e.toString());
      Get.snackbar(e.toString(), "");
    }
  }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Thermal Printer Demo"),
        ),
        body: Column(
          children: [
            SizedBox(
              width: Get.width,
              child: Center(
                child: DropdownButton<BluetoothDevice>(
                    value: selectedDevice,
                    hint: const Text("Select Device"),
                    items: devices
                        .map(
                          (e) => DropdownMenuItem(
                            child: Text(e.name!),
                            value: e,
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedDevice = val;
                      });
                    }),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await printer.connect(selectedDevice!);
                  // print(selectedDevice!.name);
                } catch (e) {
                  print(e.toString());
                }
              },
              child: const Text("Connect"),
            ),
            ElevatedButton(
              onPressed: () {
                printer.disconnect();
              },
              child: const Text("Disconnect"),
            ),
            ElevatedButton(
                onPressed: () async {
                  try {
                    getImage().then((value) {
                      setState(() {
                        loaded = true;
                      });
                    });
                  } catch (e) {
                    Get.snackbar("ERROR", e.toString(),
                        duration: const Duration(minutes: 1));
                  }
                },
                child: const Text("Get Image")),
            ElevatedButton(
              onPressed: () async {
                if ((await printer.isConnected)!) {
                  try {
                    //Image Byte Print
                    printer.printImageBytes(
                      bytes!,
                    );
                    //QR Code
                    printer.printQRcode("Test QR", 60, 60, 1);
                    //English
                    printer.printCustom("Test Engilsh Message", 50, 1,
                        charset: 'UTF-8');
                    /*
                    Arabic Text Require Charset to be UTF-16 for the text 
                    and the thermal printer
                    */
                    printer.printCustom("اختبار النص العربي", 50, 1,
                        charset: 'UTF-16');
                  } catch (e) {
                    Get.snackbar("ERROR", e.toString(),
                        duration: const Duration(minutes: 1));
                    print("Connected but not printing " + e.toString());
                  }
                } else {
                  Get.snackbar("Printer is not connected", "",
                      duration: const Duration(minutes: 1));
                  print("Not Connected");
                }
              },
              child: const Text("Print"),
            ),
            SizedBox(
              width: Get.width,
              height: Get.height / 3,
              child: loaded == true
                  ? Image.memory(
                      bytes!,
                      fit: BoxFit.fitHeight,
                    )
                  : const Text("Please Click on Get Image Button"),
            )
          ],
        ),
      ),
    );
  }
}
