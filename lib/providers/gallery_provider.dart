import 'package:able/utilities/folders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class GalleryProvider extends ChangeNotifier{
  List<Folder> foldersList =[];

  //from server
  Future<void> addFolder(Folder folder) async {
    await FirebaseFirestore.instance.collection("folders").add({
      'id' : folder.id,
      'name' : folder.name,
      'createdBy' : folder.addedBy,
      'modifiedBy' : folder.modifiedBy,
      'dateCreated' : folder.dateCreated,
      'dateModified' : folder.dateModified,
    });

    await getFolders();

    notifyListeners();
  }

  Future<void> getFolders() async {
    await FirebaseFirestore.instance.collection("folders").get().then((querySnapshot) {
      foldersList = [];
      querySnapshot.docs.forEach((result) {

        foldersList.add(new Folder(
            id: result.id,
            name: result.data()['name'],
          dateCreated: result.data()['dateCreated'],
          dateModified: result.data()['dateModified'],
          addedBy: result.data()['createdBy'],
          modifiedBy: result.data()['modifiedBy'],
        )
        );
      });

    });
    removeSelections();
    setSelectedList();
  }

  Future<void> updateFolder(Folder folder) async{
    await FirebaseFirestore.instance.collection("folders").doc(folder.id).update({
      'name' : folder.name,
      'modifiedBy' : folder.modifiedBy,
      'dateModified' : folder.dateModified,

    });
    await getFolders();

    notifyListeners();
  }

  Future<void> deleteFolder() async{
    for(int i=0;i<selectedFolders.length;i++){
      await FirebaseFirestore.instance.collection("folders").doc(selectedFolders[i]).delete();
    }

    await getFolders();
    notifyListeners();
  }


  bool checkIfNotExists(String name){
    bool res = true;
    foldersList.forEach((element) {
      if(selectedFolders.isNotEmpty){
        if(element.id != selectedFolders[0]){
          if(element.name.toLowerCase() ==  name.toLowerCase()) res = false;
        }
      }
      else{
        if(element.name.toLowerCase() ==  name.toLowerCase()) res = false;
      }
    });
    return res;
  }


  List selected = [];

  var selectionMode = false;
  var selectedItemCount = 0;
  List<String> selectedFolders =[];
  void updateSelected(int i,String id){
    selectedItemCount =0;
    selected[i] = !selected[i];
    selectionMode = false;
    if(!selected[i]){
      selectedFolders.removeWhere((element) => element==id);
    }
    else{
      selectedFolders.add(id);
    }
    selected.forEach((element) {
      if(element) {
        selectionMode =true;
        selectedItemCount+=1;
      }
    });
   notifyListeners();
  }

  Folder getSingleSelectedFolder(String id){
    var singleSelectedFolder = foldersList.firstWhere((element) {
      if(element.id==id) return true;
      return false;
    });
    return singleSelectedFolder;
  }

  void removeSelections(){
    selected.forEach((element) {
      element = false;
    });
    selectionMode=false;
    selectedItemCount=0;
    selectedFolders=[];
    setSelectedList();
    notifyListeners();
  }

  void setSelectedList(){
    selected = [];
    for(int i=0;i<foldersList.length;i++){
      selected.add(false);
    }
  }

  String getName(){
    var name ='';
    for(int i=0;i<foldersList.length;i++){
      if(foldersList[i].id ==selectedFolders[0]){
        name = foldersList[i].name;
      }
    }
    return name;
  }

}