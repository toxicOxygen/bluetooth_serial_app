import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:usart/components/list_header.dart';
import 'package:usart/components/my_list_builder.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FlutterBluetoothSerial _bluetoothSerial = FlutterBluetoothSerial.instance;
  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  bool _isBluetoothOn = false;
  bool _isScanning = false;
  List<BluetoothDevice> _devices = [];
  List<BluetoothDiscoveryResult> _discoveryResult = [];

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PIC USART'),
        actions: <Widget>[
          _isBluetoothOn?
            FlatButton(
              onPressed: !_isScanning?_scanForDevice : _stopScanning,
              child: Text(_isScanning ? 'Stop':'Scan'),
            ):
            Container(height: 0.01,width: 0.01,)
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: Text(_isBluetoothOn?'TURN OFF':'TURN ON'),
              value: _isBluetoothOn,
              onChanged: (bool val){
                if(val){
                  _turnOnBluetooth();
                }else{
                  _turnOffBluetooth();
                }
              },
            ),
            Divider(),
            _isBluetoothOn?
              Expanded(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 16.0,right: 16.0,top: 8.0,bottom: 16.0),
                    child: _isScanning? Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top:8.0,bottom: 8.0,right: 10.0),
                          child: CircularProgressIndicator(),
                        ),
                        Text('Scanning for near by devices')
                      ],
                    ):Text('Select the bluetooth adapter; HC-05 or HC-06 '
                        'from the list of paired devices. If it is not available '
                        'scan for it'),
                  ),
                  ListHeader(title: 'Paired Devices',),
                  MyListBuilder.pairDevices(devices: _devices),
                  ListHeader(title: 'Available Devices',),
                  MyListBuilder.scannedDevices(scanResults: _discoveryResult)
                ],
              ),
            ) :
              Padding(
                padding: EdgeInsets.symmetric( vertical: 16.0,horizontal: 16.0 ),
                child: Text('Turn on bluetooth to access near by devices. '
                    'Without bluetooth, you can not proceed further with app'),
              )
          ],
        ),
      )
    );
  }

  Future<void> _checkBluetoothState() async{

    await _bluetoothSerial.isEnabled.then((val){
      setState(() {
        _isBluetoothOn = val;
      });
      if(val){
        _getPairedDevices();
      }
    }).catchError((e){
      print(e);
    });

    _bluetoothSerial.onStateChanged().listen((state){
      if(state == BluetoothState.STATE_OFF){
        setState(() { _isBluetoothOn = false; });
      }else if(state == BluetoothState.STATE_ON){
        setState(() { _isBluetoothOn = true; });
        _getPairedDevices();
      }
    });
  }

  void _turnOnBluetooth() {
    try{
      _bluetoothSerial.requestEnable();
    }on PlatformException{
      print('error');
    }
  }

  void _turnOffBluetooth(){
    try{
      _bluetoothSerial.requestDisable();
    }on PlatformException{
      print('error');
    }
  }

  void _getPairedDevices() async{
    await _bluetoothSerial.getBondedDevices().then((vals){
      print(vals);
      setState(() {
        _devices = vals;
      });
    }).catchError((e){
      print(e);
    });
  }

  void _scanForDevice() async{
    setState(() { _isScanning = true; });
    _streamSubscription =_bluetoothSerial.startDiscovery().listen((data){
      setState(() {
        _discoveryResult.add(data);
      });
    })..onDone((){
      print('scanning completed');
      setState(() { _isScanning = false; });
    });
  }

  void _stopScanning() async{
    _bluetoothSerial.cancelDiscovery().then((_){
      setState(() {
        _isScanning = false;
      });
    });
  }



  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

}
