//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//
//
//class TestPage extends StatefulWidget {
//  @override
//  _TestPageState createState() => _TestPageState();
//}
//
//class _TestPageState extends State<TestPage> {
//
//  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
//
//  List<BluetoothDevice> _deviceList = new List<BluetoothDevice>();
//  BluetoothDevice _device;
//  bool _connected = false;
//  bool _pressed = false;
//
//  @override
//  void initState() {
//    super.initState();
//    _bluetoothConnectionState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      key: _scaffoldKey,
//      appBar: AppBar(
//        title: Text('PIC USART'),
//      ),
//      body: Container(
//        child: Column(
//          mainAxisSize: MainAxisSize.max,
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.only(top: 8.0),
//              child: Text(
//                "PAIRED DEVICES",
//                style: TextStyle(fontSize: 24, color: Colors.blue),
//                textAlign: TextAlign.center,
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              // Defining a Row containing THREE main Widgets:
//              // 1. Text
//              // 2. DropdownButton
//              // 3. RaisedButton
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Text(
//                    'Device:',
//                    style: TextStyle(
//                      fontWeight: FontWeight.bold,
//                    ),
//                  ),
//                  DropdownButton(
//                    // To be implemented : _getDeviceItems()
//                    items: _getDeviceItems(),
//                    onChanged: (value) => setState(() => _device = value),
//                    value: _device,
//                  ),
//                  RaisedButton(
//                    onPressed:
//                    // To be implemented : _disconnect and _connect
//                    _pressed ? null : _connected ? _disconnect : _connect,
//                    child: Text(_connected ? 'Disconnect' : 'Connect'),
//                  ),
//                ],
//              ),
//            ),
//
//            Padding(
//              padding: const EdgeInsets.all(16.0),
//              child: Card(
//                elevation: 4,
//                child: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  // Defining a Row containing THREE main Widgets:
//                  // 1. Text (wrapped with "Expanded")
//                  // 2. FlatButton
//                  // 3. FlatButton
//                  child: Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: Text(
//                          "DEVICE 1",
//                          style: TextStyle(
//                            fontSize: 20,
//                            color: Colors.green,
//                          ),
//                        ),
//                      ),
//                      FlatButton(
//                        onPressed:
//                        // To be implemented : _sendOnMessageToBluetooth()
//                        _connected ? _sendOnMessageToBluetooth : null,
//                        child: Text("ON"),
//                      ),
//                      FlatButton(
//                        onPressed:
//                        // To be implemented : _sendOffMessageToBluetooth()
//                        _connected ? _sendOffMessageToBluetooth : null,
//                        child: Text("OFF"),
//                      ),
//                    ],
//                  ),
//                ),
//              ),
//            ),
//
//            Expanded(
//              child: Padding(
//                padding: const EdgeInsets.all(20),
//                child: Center(
//                  child: Text(
//                    "NOTE: If you cannot find the device in the list, "
//                        "please turn on bluetooth and pair the device by "
//                        "going to the bluetooth settings",
//                    style: TextStyle(
//                        fontSize: 15,
//                        fontWeight: FontWeight.bold,
//                        color: Colors.red),
//                  ),
//                ),
//              ),
//            )
//
//          ],
//        ),
//      ),
//    );
//  }
//
//  Future<void> _bluetoothConnectionState() async{
//
//    try{
//      await bluetooth.getBondedDevices().then((val){
//        print(val);
//        setState(() {
//          _deviceList = val; //delete if code fails
//        });
//      });
//    }on PlatformException{
//      print('Error');
//    }
//
//    bluetooth.onStateChanged().listen((state){
//
//      if(state == FlutterBluetoothSerial.CONNECTED){
//        setState(() {
//          _connected = true;
//          _pressed = false;
//        });
//      }else if(state == FlutterBluetoothSerial.DISCONNECTED){
//        setState(() {
//          _connected = false;
//          _pressed = false;
//        });
//      }else{
//        print('state');
//      }
//
//    });
//
//    if(!mounted){
//      return;
//    }
//
//  }
//
//  void _connect() {
//    if (_device == null) {
//      show('No device selected');
//    } else {
//      bluetooth.isConnected.then((isConnected) {
//        if (!isConnected) {
//          bluetooth
//              .connect(_device)
//              .timeout(Duration(seconds: 10))
//              .catchError((error) {
//            setState(() => _pressed = false);
//          });
//          setState(() => _pressed = true);
//        }
//      });
//    }
//  }
//
//  // Method to disconnect bluetooth
//  void _disconnect() {
//    bluetooth.disconnect();
//    setState(() => _pressed = true);
//  }
//
//  // Method to show a Snackbar,
//  // taking message as the text
//  Future show(
//      String message, {
//        Duration duration: const Duration(seconds: 3),
//      }) async {
//    await new Future.delayed(new Duration(milliseconds: 100));
//    _scaffoldKey.currentState.showSnackBar(
//      new SnackBar(
//        content: new Text(
//          message,
//        ),
//        duration: duration,
//      ),
//    );
//  }
//
//  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
//    List<DropdownMenuItem<BluetoothDevice>> items = [];
//    if (_deviceList.isEmpty) {
//      items.add(DropdownMenuItem(
//        child: Text('NONE'),
//      ));
//    } else {
//      _deviceList.forEach((device) {
//        items.add(DropdownMenuItem(
//          child: Text(device.name),
//          value: device,
//        ));
//      });
//    }
//    return items;
//  }
//
//  // Method to send message,
//  // for turning the bletooth device on
//  void _sendOnMessageToBluetooth() {
//    bluetooth.isConnected.then((isConnected) {
//      if (isConnected) {
//        bluetooth.write("1");
//        show('Device Turned On');
//      }
//    });
//  }
//
//  // Method to send message,
//  // for turning the bletooth device off
//  void _sendOffMessageToBluetooth() {
//    bluetooth.isConnected.then((isConnected) {
//      if (isConnected) {
//        bluetooth.write("0");
//        show('Device Turned Off');
//      }
//    });
//  }
//}
