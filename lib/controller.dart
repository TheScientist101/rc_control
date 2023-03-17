import 'dart:typed_data';

import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Controller extends StatefulWidget {
  final BluetoothDevice device;
  const Controller({super.key, required this.device});

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late BluetoothDevice connectedDevice;
  late BluetoothCharacteristic txCharacteristic;
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    connectedDevice = widget.device;
    connectedDevice.discoverServices().then((value) {
      for (var service in value) {
        if (service.uuid.toString().toUpperCase() ==
            "6E400001-B5A3-F393-E0A9-E50E24DCCA9E") {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toUpperCase() ==
                "6E400002-B5A3-F393-E0A9-E50E24DCCA9E") {
              txCharacteristic = characteristic;
            }
          }
        }
      }
    });
    _controller = WebViewController();
    _controller
        .loadRequest(Uri.parse('http://raspberrypi.local:5000/video_feed'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RC Controller'),
      ),
      body: Center(
        child: Column(children: [
          // URL iFrame
          Container(
            width: 640,
            height: 360,
            child: WebViewWidget(
              controller: _controller,
            ),
          ),
          Joystick(listener: (details) {
            sendCommand(details);
          }),
        ]),
      ),
    );
  }

  void sendCommand(StickDragDetails details) {
    // Send x and y values to the device multiplied by 100 into txCharacteristic
    ByteData byteData = ByteData(2);
    byteData.setInt8(0, (details.x * 100).round());
    byteData.setInt8(1, (details.y * 100).round());
    txCharacteristic.write(byteData.buffer.asUint8List());
  }
}
