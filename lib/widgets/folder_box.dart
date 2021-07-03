import 'package:able/loaders/gallery_loader.dart';
import 'package:able/providers/gallery_provider.dart';
import 'package:able/utilities/folders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class FolderBox extends StatefulWidget {
  Folder folder;
  int index;
  Function longPress;
  FolderBox(this.folder,this.index,this.longPress);

  @override
  _FolderBoxState createState() => _FolderBoxState();
}

class _FolderBoxState extends State<FolderBox> {
  var isSelected = false;
  var dHeight;
  @override
  Widget build(BuildContext context) {
    var gp = Provider.of<GalleryProvider>(context,listen: false);
    dHeight = MediaQuery.of(context).size.height;
    isSelected = gp.selected[widget.index];
    return WillPopScope(
      onWillPop: () async{
        if(isSelected){
            gp.removeSelections();
          return false;
        }
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            if(gp.selectionMode) gp.updateSelected(widget.index,widget.folder.id);
            else Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ImageLoader(folder: widget.folder,)));
          },
          onLongPress: () {
            if(userName!=''){
              gp.updateSelected(widget.index,widget.folder.id);
            }
          },
          child: Container(
            height: dHeight*0.08,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                  child: const  Icon(Icons.folder,color: Colors.orange,size: 30,),
                ),
                Text(
                  widget.folder.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(10),
              color: (isSelected)?Colors.lightBlueAccent:Colors.white
            ),
          ),
        ),
      ),
    );
  }
}
