import 'package:able/providers/links_provider.dart';
import 'package:able/screens/meeting_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LinkLoader extends StatefulWidget {

  @override
  _LinkLoaderState createState() => _LinkLoaderState();
}

class _LinkLoaderState extends State<LinkLoader> {
  @override
  Widget build(BuildContext context) {
    var lp = Provider.of<LinkProvider>(context,listen: false);
    return FutureBuilder(
        future: lp.getLinks(),
        builder: (context,snap) =>(snap.connectionState == ConnectionState.done)?MeetingLink():Scaffold(body: Center(child: CircularProgressIndicator(),),)
    );
  }
}