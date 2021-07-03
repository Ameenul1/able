import 'package:able/utilities/Links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class LinkProvider extends ChangeNotifier{
  List<Link> linksList =[];

  //from server
  Future<void> addLink(Link link) async {
    await FirebaseFirestore.instance.collection("links").add({
      'id' : link.id,
      'name' : link.name,
      'createdBy' : link.addedBy,
      'modifiedBy' : link.modifiedBy,
      'dateCreated' : link.dateCreated,
      'dateModified' : link.dateModified,
      'link' : link.link,
    });

    await getLinks();

    notifyListeners();
  }

  Future<void> getLinks() async {
    await FirebaseFirestore.instance.collection("links").get().then((querySnapshot) {
      linksList = [];
      querySnapshot.docs.forEach((result) {

        linksList.add(new Link(
          id: result.id,
          name: result.data()['name'],
          dateCreated: result.data()['dateCreated'],
          dateModified: result.data()['dateModified'],
          addedBy: result.data()['createdBy'],
          modifiedBy: result.data()['modifiedBy'],
          link: result.data()['link'],
        )
        );
      });

    });
    removeSelections();
    setSelectedList();
  }

  Future<void> updateLink(Link link) async{
    await FirebaseFirestore.instance.collection("links").doc(link.id).update({
      'name' : link.name,
      'modifiedBy' : link.modifiedBy,
      'dateModified' : link.dateModified,
       'link' : link.link
    });
    await getLinks();

    notifyListeners();
  }

  Future<void> deleteLink() async{
    for(int i=0;i<selectedLinks.length;i++){
      await FirebaseFirestore.instance.collection("links").doc(selectedLinks[i]).delete();
    }
    await getLinks();
    notifyListeners();
  }


  bool checkIfNotExists(String name){
    bool res = true;
    linksList.forEach((element) {
      if(selectedLinks.isNotEmpty){
        if(element.id != selectedLinks[0]){
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
  List<String> selectedLinks =[];
  void updateSelected(int i,String id){
    selectedItemCount =0;
    selected[i] = !selected[i];
    selectionMode = false;
    if(!selected[i]){
      selectedLinks.removeWhere((element) => element==id);
    }
    else{
      selectedLinks.add(id);
    }
    selected.forEach((element) {
      if(element) {
        selectionMode =true;
        selectedItemCount+=1;
      }
    });
    notifyListeners();
  }

  Link getSingleSelectedLink(String id){
    var singleSelectedLink = linksList.firstWhere((element) {
      if(element.id==id) return true;
      return false;
    });
    return singleSelectedLink;
  }

  void removeSelections(){
    selected.forEach((element) {
      element = false;
    });
    selectionMode=false;
    selectedItemCount=0;
    selectedLinks=[];
    setSelectedList();
    notifyListeners();
  }

  void setSelectedList(){
    selected = [];
    for(int i=0;i<linksList.length;i++){
      selected.add(false);
    }
  }

  String getName(){
    var name ='';
    for(int i=0;i<linksList.length;i++){
      if(linksList[i].id ==selectedLinks[0]){
        name = linksList[i].name;
      }
    }
    return name;
  }

  String getLink(){
    var name ='';
    for(int i=0;i<linksList.length;i++){
      if(linksList[i].id ==selectedLinks[0]){
        name = linksList[i].link;
      }
    }
    return name;
  }

}