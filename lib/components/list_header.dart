import 'package:flutter/material.dart';

class ListHeader extends StatelessWidget {
  final String title;

  ListHeader({@required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left:16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text('${title.toUpperCase()}'),
          SizedBox(width: 2.5,),
          Flexible(child: Divider(thickness: 1.5,))
        ],
      ),
    );
  }
}
