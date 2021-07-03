import 'package:able/main.dart';
import 'package:able/providers/gallery_provider.dart';
import 'package:able/utilities/folders.dart';
import 'package:able/widgets/drawer_widget.dart';
import 'package:able/widgets/folder_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  void actionOnLongPress(int id) {}
  var folderNameController = TextEditingController();
  var dWidth;
  var dHeight;

  @override
  void dispose() {
    // TODO: implement dispose
    folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var gp = Provider.of<GalleryProvider>(context);
    dWidth = MediaQuery.of(context).size.width;
    dHeight = MediaQuery.of(context).size.height;
    return Material(
        child: GestureDetector(
          onTap: () => gp.removeSelections(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Gallery"),
              backgroundColor: Color.fromRGBO(0, 0, 50, 1),
              actions: (userName!='')?[
                if (!gp.selectionMode)
                  IconButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) {
                          folderNameController = TextEditingController();
                          var folderWarning = '';
                          return StatefulBuilder(
                            builder: (BuildContext context, void Function(void Function()) setState) {
                                return AlertDialog(
                                  title: const Text("Enter folder name"),
                                  content: Container(
                                    height: dHeight * 0.2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              width: dWidth * 0.5,
                                              child: Column(
                                                children: [
                                                  TextField(
                                                    controller: folderNameController,
                                                    decoration: InputDecoration(
                                                      labelText: 'Name'
                                                    ),
                                                  ),

                                                ],
                                              )
                                          ),
                                        ),
                                        Text(folderWarning,style: TextStyle(color: Colors.red),),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  if(gp.checkIfNotExists(folderNameController.text)){
                                                    if(folderNameController.text != "" ) {
                                                      gp.addFolder(
                                                          Folder(
                                                              id: "",
                                                              name: folderNameController
                                                                  .text,
                                                              dateCreated: DateTime
                                                                  .now()
                                                                  .toString()
                                                                  .substring(
                                                                  0, 10),
                                                              dateModified: DateTime
                                                                  .now()
                                                                  .toString()
                                                                  .substring(
                                                                  0, 10),
                                                              modifiedBy: userName,
                                                              addedBy: userName,

                                                          )
                                                      );
                                                      folderNameController
                                                          .text = "";
                                                      Navigator.pop(context);
                                                    }
                                                    else{
                                                      setState(() {
                                                        folderWarning = 'A valid name required';
                                                      });
                                                    }
                                                  }
                                                  else{
                                                    setState(() {
                                                      folderWarning = 'Folder name already exists';
                                                    });
                                                  }
                                                },
                                                child: const Text("Create")),
                                            TextButton(
                                                onPressed: () =>Navigator.pop(context), child: const Text("Cancel"))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                            },
                          );
                        } ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                if (gp.selectionMode)
                  IconButton(
                    onPressed: () =>showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Warning" , style: TextStyle(color: Colors.red),),
                          content: Container(
                            height: dHeight * 0.15,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      width: dWidth * 0.5,
                                      child: const Text(
                                        "Are you sure that you want to delete selected folder(s)"
                                      ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                            gp.deleteFolder();
                                            Navigator.pop(context);
                                          },
                                        child: const Text("Yes")),
                                    TextButton(
                                        onPressed: () =>Navigator.pop(context), child: const Text("Cancel"))
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                    ),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                if (gp.selectionMode && gp.selectedItemCount == 1)
                  IconButton(
                    onPressed: () =>  showDialog(
                        context: context,
                        builder: (context) {
                          var folderWarning = '';
                          folderNameController = TextEditingController(text: gp.getName());
                          return StatefulBuilder(
                            builder: (BuildContext context, void Function(void Function()) setState) {
                              return AlertDialog(
                                title: const Text("Update folder"),
                                content: Container(
                                  height: dHeight * 0.2,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                            width: dWidth * 0.5,
                                            child: Column(
                                              children: [
                                                TextField(
                                                  controller: folderNameController,
                                                ),
                                              ],
                                            )
                                        ),
                                      ),
                                      Text(folderWarning,style: TextStyle(color: Colors.red),),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                if(gp.checkIfNotExists(folderNameController.text)){
                                                  if(folderNameController.text != "" ) {
                                                    gp.updateFolder(
                                                        Folder(
                                                            id: gp.selectedFolders[0],
                                                            name: folderNameController
                                                                .text,
                                                            dateCreated: DateTime
                                                                .now()
                                                                .toString()
                                                                .substring(
                                                                0, 10),
                                                            dateModified: DateTime
                                                                .now()
                                                                .toString()
                                                                .substring(
                                                                0, 10),
                                                            modifiedBy: userName,
                                                            addedBy: userName,

                                                        )
                                                    );
                                                    folderNameController
                                                        .text = "";

                                                    Navigator.pop(context);
                                                  }
                                                  else{
                                                    setState(() {
                                                      folderWarning = 'A valid name required';
                                                    });
                                                  }
                                                }
                                                else{
                                                  setState(() {
                                                    folderWarning = 'Folder name already exists';
                                                  });
                                                }
                                              },
                                              child: const Text("Rename")),
                                          TextButton(
                                              onPressed: () =>Navigator.pop(context), child: const Text("Cancel"))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } ),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                if (gp.selectionMode && gp.selectedItemCount == 1)
                  IconButton(
                    onPressed: () =>showDialog(
                        context: context,
                        builder: (context) {
                          var selectedFolder = gp.getSingleSelectedFolder(gp.selectedFolders[0]);
                          return AlertDialog(
                          title: const Text("Folder info"),
                          content: Container(
                            height: dHeight*0.4,
                            width: dWidth*0.9,
                            decoration: BoxDecoration(
                              border: Border.all()
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                    "Name : "+ selectedFolder.name,
                                ),
                                Text(
                                  "Added Date : "+ selectedFolder.dateCreated,
                                ),
                                Text(
                                  "Added By : "+ selectedFolder.addedBy,
                                ),
                                Text(
                                  "Modified Date : "+ selectedFolder.dateModified,
                                ),
                                Text(
                                  "Modified By: "+ selectedFolder.modifiedBy,
                                ),
                              ],
                            ),
                          ),
                        );}
                    ),
                    icon: const  Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                  ),
              ]:[],
            ),
            drawer: Drawer(
              child: DrawerWidget(),
            ),
            body: Center(
              child: Container(
                width: dWidth * 0.95,
                child: (gp.foldersList.isNotEmpty)?ListView.builder(
                    itemCount: gp.foldersList.length,
                    itemBuilder: (context, index) => FolderBox(
                        gp.foldersList[index], index, actionOnLongPress)):Center(child: const Text("No folders created"),),
              ),
            ),
          ),
        ),
    );
  }
}
