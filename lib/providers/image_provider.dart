import 'dart:io';
import 'package:able/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


class ClubImageProvider extends ChangeNotifier{
   List<String> imageUrls = [];

   
    var totalProgress = 0.0;
   Future<void> uploadImages(List<File> images,String folderId,int totalSize) async{
     totalProgress =0.0;
     var totalBytesTransfer = 0.0;
     for(int i=0;i<images.length;i++) {
       var splited = images[i].path.split('cache/');
       Reference ref = FirebaseStorage.instance
           .ref()
           .child('$folderId/${splited[1]}');
       final UploadTask uploadTask = ref.putFile(images[i]);
       final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
       totalBytesTransfer+=taskSnapshot.totalBytes;
       totalProgress =
           (totalBytesTransfer/ totalSize.toDouble()) *
               100;
       final url = await taskSnapshot.ref.getDownloadURL();

       imageUrls.add(url);
       notifyListeners();
     }
     await updateFolder(folderId);

   }

   Future<void> getImageUrls(String folderId) async{
     imageUrls = [];
     Reference ref = FirebaseStorage.instance
         .ref()
         .child('$folderId');
     var res = await ref.listAll();
     for(int i=0;i<res.items.length;i++){
       var url = await res.items[i].getDownloadURL();
       imageUrls.add(url);
     }
     notifyListeners();
   }

   Future<void> deleteImage(int index,String folderId) async {
     await FirebaseStorage.instance.refFromURL(imageUrls[index]).delete();
     imageUrls.removeAt(index);
     await updateFolder(folderId);
     notifyListeners();
   }
   
   Future<void> updateFolder(String folderId) async{
     await FirebaseFirestore.instance.collection("folders").doc(folderId).update({
       'modifiedBy' : userName,
       'dateModified' : DateTime.now().toString().substring(0,10),
     });
   } 



  // //getting from drive
  // Future<void> getImagesFromDrive(String id) async{
  //   if(id == 'invalid'){
  //     return;
  //   }
  //   imageUrls = [];
  //   var folderId = id;
  //   var api_key = 'AIzaSyB5oPSlu-oMRq0u0IO-ZWIuVkz3aYevnkE';
  //   var url = Uri.parse("https://www.googleapis.com/drive/v3/files?q='" + folderId + "'+in+parents&key=" + api_key);
  //   var response = await http.get(url);
  //   if(response.statusCode == 200){
  //     print(response.body);
  //     var jsonResult = json.decode(response.body);
  //     List<dynamic> res = jsonResult['files'];
  //     res.forEach((value) {
  //       imageUrls.add('https://drive.google.com/uc?export=view&id=${value['id']}');
  //     });
  //   }
  //   else{
  //     print('error' + response.statusCode.toString());
  //   }
  //
  // }
  //


}