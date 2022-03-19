import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

void main(List<String> args) {
  runApp(MyApp());
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

  @override
  void initState() {
    super.initState();
    getDevices();
  }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
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
            Center(
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
                if ((await printer.isConnected)!) {
                  try {
                    printer.printNewLine();
                    printer.printCustom("Test Message in English", 1, 1);
                    printer.printCustom("اختبار اللغة العربية", 1, 1);
                    printer.printQRcode("textToQR", 20, 20, 1);
                  } catch (e) {
                    print("Connected but not printing " + e.toString());
                  }
                } else {
                  print("Not Connected ?????????????????");
                }
              },
              child: const Text("Print"),
            )
          ],
        ),
      ),
    );
  }
}
