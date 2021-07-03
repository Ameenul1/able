import 'package:able/screens/gallery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:able/providers/gallery_provider.dart';
class FolderLoader extends StatefulWidget {

  @override
  _FolderLoaderState createState() => _FolderLoaderState();
}

class _FolderLoaderState extends State<FolderLoader> {
  @override
  Widget build(BuildContext context) {
    var gp = Provider.of<GalleryProvider>(context,listen: false);
    return FutureBuilder(
        future: gp.getFolders(),
        builder: (context,snap) =>(snap.connectionState == ConnectionState.done)?Gallery():Scaffold(body: Center(child: CircularProgressIndicator(),),)
    );
  }
}
