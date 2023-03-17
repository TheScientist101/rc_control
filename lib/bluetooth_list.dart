import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'controller.dart';

class BluetoothApp extends StatefulWidget {
  const BluetoothApp({super.key});

  @override
  State<BluetoothApp> createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }

  void scanForDevices() {
    flutterBlue.scan(timeout: const Duration(seconds: 15)).listen((scanResult) {
      if (!devices.contains(scanResult.device)) {
        setState(() {
          devices.add(scanResult.device);
        });
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      flutterBlue.stopScan();
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Controller(device: device),
        ),
      );
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth App'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          if (device.name == '') return Container();
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id.toString()),
            onTap: () => connectToDevice(device),
          );
        },
      ),
    );
  }
}
