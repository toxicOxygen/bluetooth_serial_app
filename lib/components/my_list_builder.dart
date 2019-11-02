import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:usart/pages/ControlPanel.dart';


class MyListBuilder extends StatelessWidget {

  bool showingScannedDevices = false;
  final List<BluetoothDevice> devices;
  final List<BluetoothDiscoveryResult> scanResults;
  //final VoidCallback openNewPage;

  MyListBuilder({@required this.devices,@required this.scanResults}){
    if(devices.isEmpty && scanResults.isNotEmpty)
      showingScannedDevices = true;
  }


  factory MyListBuilder.pairDevices({
    @required List<BluetoothDevice> devices}){
    return MyListBuilder(devices: devices,scanResults: []);
  }

  factory MyListBuilder.scannedDevices({
    @required List<BluetoothDiscoveryResult> scanResults}){
    return MyListBuilder(scanResults: scanResults,devices: []);
  }

  @override
  Widget build(BuildContext context) {
    if(!showingScannedDevices)
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: devices.map((device){
          return ListTile(
            leading: Icon(Icons.devices),
            title: Text(device.name??device.address,style: TextStyle(fontSize: 13.0),),
            trailing: IconButton(
              icon: Icon(Icons.settings),
              onPressed: (){},
            ),
            onTap: (){
              //TODO move to new page
              print('testing');
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                  ControlPanel(server: device,)
              ));
            },
          );
        }).toList(),
      );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: scanResults.map((device){
        print(device.device.isConnected);
        if(device.device.isBonded){
          print('this devices is already bonded');
          return Container(height: 0.001,width: 0.001,);
        }

        return ListTile(
          leading: Icon(Icons.devices),
          title: Text(device.device.name??device.device.address,style: TextStyle(fontSize: 13.0)),
          trailing: IconButton(
            icon: Icon(Icons.settings),
            onPressed: (){},
          ),
          onTap: (){
            FlutterBluetoothSerial.instance.bondDeviceAtAddress(device.device.address)
                .then((bool val){
                  print('val');//TODO navigate to com_page
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                      ControlPanel(server: device.device,)
                  ));
                });
          },
        );
      }).toList(),
    );
  }
}
