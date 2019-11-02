import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';


class ControlPanel extends StatefulWidget {

  final BluetoothDevice server;

  ControlPanel({@required this.server});

  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {

  BluetoothConnection _connection;
  GlobalKey<ScaffoldState> _scaffoldKey= GlobalKey<ScaffoldState>();

  double _brightness = 0;

  @override
  void initState() {
    super.initState();
    _establishConnection();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home Controller'),
      ),
      body: Center(
        child:Padding(
          padding: const EdgeInsets.symmetric(horizontal:16.0),
          child: Card(
            elevation: 6.0,
            child: Container(
              width: double.infinity,
              height: height * 0.75,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_changeToPercentage(_brightness, 0, 255).round()}%',
                        style: Theme.of(context).textTheme.display4
                      ),
                    ),
                  ),
                  Slider(
                    onChanged: (val){
                      setState(() {
                        _brightness = val;
                      });
                    },
                    onChangeEnd: (val){
                      _sendMessage('${val.round()}');
                    },
                    value: _brightness,
                    min: 0.0,
                    max: 255.0,
                    activeColor: Colors.white,
                  )
                ],
              ),
            ),
          ),
        )
      ),
    );
  }

  Future<void> _establishConnection() async{
    _connection = await BluetoothConnection.toAddress(widget.server.address)
        .then((con){
            print(con.toString());
            return con;
        })
        .catchError((e){
          print(e);
          Navigator.pop(context);
        });

    _connection.input.listen(_onDataReceived).onDone((){
      print('connection done');
    });
  }

  void _sendMessage(String data) async{
    try{
      _connection.output.add(utf8.encode('$data\r\n'));
      await _connection.output.allSent;
    }catch(ex){
      print('failed to send data ${ex.toString()}');
    }
  }

  void _onDataReceived(Uint8List data) async{

  }

  double _changeToPercentage(double val,double lower,double upper){
    print(100*val/(upper - lower));
    return 100 * val/(upper - lower) ;
  }

  @override
  void dispose() {
    _connection.close();
    _connection.dispose();
    super.dispose();
  }

}
