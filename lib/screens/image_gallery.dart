import 'package:able/main.dart';
import 'package:able/providers/image_provider.dart';
import 'package:able/utilities/folders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:provider/provider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';


class ImageGallery extends StatefulWidget {
  Folder folder;
  ImageGallery({required this.folder});

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<Asset> images = [];
  String _error = '';
  List<File> fileImageArray =[];
  var totalSize = 0;
  bool isStarted = false;

  @override
  void initState() {
    // TODO: implement initState
    var ip = Provider.of<ClubImageProvider>(context,listen: false);
    ip.getImageUrls(widget.folder.id);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    images.clear();
    fileImageArray.clear();
    super.dispose();
  }


  Widget buildGridView(List<String> imgUrl,BuildContext context,Function delete) {

    if (imgUrl.isNotEmpty)
      return GridView.builder(
       gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
         maxCrossAxisExtent: 150,
         mainAxisExtent: 150,
         mainAxisSpacing: 5,
         crossAxisSpacing: 5
       ),
        itemCount: imgUrl.length,
        itemBuilder: (context,index) => InkWell(
          onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 600,
                      width: 500,
                      child: CachedNetworkImage(
                        fit: BoxFit.contain,
                        imageUrl: imgUrl[index],
                        imageBuilder: (context, imageProvider) => PhotoView(
                          imageProvider: imageProvider,
                        ),
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        cacheManager: CacheManager(Config(
                          "custom cache clear",
                          maxNrOfCacheObjects: 30,
                          stalePeriod: const Duration(days: 2),
                        )),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: (userName!='')?IconButton(
                        icon: Icon(Icons.delete,color: Colors.red,),
                        onPressed: () async{
                          await delete(index,widget.folder.id);
                          Navigator.of(context).pop();
                        },
                      ):Container(),
                    )
                  ],
                ),
              )
          ),
            child: Container(
              height: 400,
              width: 400,
              child: CachedNetworkImage(
                memCacheWidth: 150,
                memCacheHeight: 150,
                fit: BoxFit.cover,
                imageUrl: imgUrl[index],
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                errorWidget: (context, url, error) => Icon(Icons.error),
                cacheManager: CacheManager(Config(
                  "custom cache",
                  maxNrOfCacheObjects: 20,
                  stalePeriod: const Duration(days: 5),
                )),
              ),
            ),
          )
        );
    else
      return Container(color: Colors.white);
  }

  Future<void> loadAssets(BuildContext context) async {
    setState(() {
      images = [];
    });

    List<Asset> resultList =[];
    String error ='';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      if (error == '') _error = 'No Error Dectected';
    });
    if(images.isNotEmpty){
      setState(() {
        isStarted = true;
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setState) {
                var ip = Provider.of<ClubImageProvider>(context);
                return AlertDialog(
                  content: Container(
                    child: Column(
                      mainAxisSize:  MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: ip.totalProgress / 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("uploaded ${ip.totalProgress.toInt()}%"),
                        )
                      ],
                    ),
                  ),
                );
              }
          )
      );
      await convertAssertToFile();
      var ip = Provider.of<ClubImageProvider>(context,listen: false);
      await ip.uploadImages(fileImageArray, widget.folder.id,totalSize);
      Navigator.of(context).pop();
      setState(() {
        isStarted = false;
      });
    }

  }

  Future<void> convertAssertToFile() async{
    fileImageArray=[];
    for(int i=0;i<images.length;i++){
      final filePath = await FlutterAbsolutePath.getAbsolutePath(
          images[i].identifier);

      File tempFile = File(filePath);

      if (tempFile.existsSync()) {
        totalSize+= await tempFile.length();
        fileImageArray.add(tempFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var dWidth = MediaQuery.of(context).size.width;
    var dHeight = MediaQuery.of(context).size.height;
    var ip = Provider.of<ClubImageProvider>(context);
    return Material(
        child: Scaffold(
                  appBar: AppBar(
                     title: Text(widget.folder.name),
                      backgroundColor: Color.fromRGBO(0, 0, 50, 1),
                    actions: [
                      IconButton(
                        onPressed: () =>ip.getImageUrls(widget.folder.id),
                        icon: const Icon(Icons.refresh),
                      )
                    ],
                  ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: dHeight*0.8,
                  child: Center(
                    child: buildGridView(ip.imageUrls, context,ip.deleteImage)
                  ),
                ),
                if(userName!='')Container(
                  color: Colors.orangeAccent,
                  width: dWidth,
                  child: TextButton(
                    onPressed: () => loadAssets(context),
                    child: Text("Upload Images",
                        style: TextStyle(
                            fontSize: 20, color: Color.fromRGBO(0, 0, 50, 1))),
                  ),
                )
              ],
            ),
        )
    );
  }
}
