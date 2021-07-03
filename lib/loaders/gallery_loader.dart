
import 'package:able/providers/image_provider.dart';
import 'package:able/screens/image_gallery.dart';
import 'package:able/utilities/folders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageLoader extends StatefulWidget {
  Folder folder;
  ImageLoader({required this.folder});
  @override
  _ImageLoaderState createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader> {
  @override
  Widget build(BuildContext context) {
    var ip = Provider.of<ClubImageProvider>(context,listen: false);
    return FutureBuilder(
        future: ip.getImageUrls(widget.folder.id),
        builder: (context,snap) =>(snap.connectionState == ConnectionState.done)?ImageGallery(folder: widget.folder):Scaffold(body: Center(child: CircularProgressIndicator(),),)
    );
  }
}