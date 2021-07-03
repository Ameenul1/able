import 'package:able/providers/links_provider.dart';
import 'package:able/widgets/drawer_widget.dart';
import 'package:able/widgets/link_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:able/utilities/Links.dart';
import '../main.dart';

class MeetingLink extends StatefulWidget {


  @override
  _MeetingLinkState createState() => _MeetingLinkState();
}

class _MeetingLinkState extends State<MeetingLink> {
  void actionOnLongPress(int id) {}
  var linkNameController = TextEditingController();
  var linkController = TextEditingController();
  var dWidth;
  var dHeight;

  @override
  void dispose() {
    // TODO: implement dispose
    linkNameController.dispose();
    linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lp = Provider.of<LinkProvider>(context);
    dWidth = MediaQuery.of(context).size.width;
    dHeight = MediaQuery.of(context).size.height;
    return Material(
      child: GestureDetector(
        onTap: () => lp.removeSelections(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Meeting Links"),
            backgroundColor: Color.fromRGBO(0, 0, 50, 1),
            actions: (userName!='')?[
              if (!lp.selectionMode)
                IconButton(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        linkNameController = TextEditingController();
                        var linkWarning = '';
                        return StatefulBuilder(
                          builder: (BuildContext context, void Function(void Function()) setState) {
                            return AlertDialog(
                              title: const Text("Enter link name"),
                              content: Container(
                                height: dHeight * 0.3,
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
                                                controller: linkNameController,
                                                decoration: InputDecoration(
                                                    labelText: 'meeting name'
                                                ),
                                              ),
                                              TextField(
                                                controller: linkController,
                                                decoration: InputDecoration(
                                                    labelText: 'meeting link'
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                    Text(linkWarning,style: TextStyle(color: Colors.red),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              if(lp.checkIfNotExists(linkNameController.text)){
                                                if(linkNameController.text != "" && linkController.text!='') {
                                                  lp.addLink(
                                                      Link(
                                                        id: "",
                                                        name: linkNameController
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
                                                          link: linkController
                                                              .text
                                                      )
                                                  );
                                                  linkNameController
                                                      .text = "";
                                                  Navigator.pop(context);
                                                }
                                                else{
                                                  setState(() {
                                                    linkWarning = 'All fields required';
                                                  });
                                                }
                                              }
                                              else{
                                                setState(() {
                                                  linkWarning = 'meeting name already exists';
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
              // if (lp.selectionMode)
              //   IconButton(
              //     onPressed: () =>showDialog(
              //         context: context,
              //         builder: (context) => AlertDialog(
              //           title: const Text("Warning" , style: TextStyle(color: Colors.red),),
              //           content: Container(
              //             height: dHeight * 0.15,
              //             child: Column(
              //               children: [
              //                 Padding(
              //                   padding: const EdgeInsets.all(8.0),
              //                   child: Container(
              //                     width: dWidth * 0.5,
              //                     child: const Text(
              //                         "Are you sure that you want to delete selected link(s)"
              //                     ),
              //                   ),
              //                 ),
              //                 Row(
              //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //                   children: [
              //                     TextButton(
              //                         onPressed: () {
              //                           lp.deleteLink();
              //                           Navigator.pop(context);
              //                         },
              //                         child: const Text("Yes")),
              //                     TextButton(
              //                         onPressed: () =>Navigator.pop(context), child: const Text("Cancel"))
              //                   ],
              //                 )
              //               ],
              //             ),
              //           ),
              //         )
              //     ),
              //     icon: const Icon(
              //       Icons.delete,
              //       color: Colors.white,
              //     ),
              //   ),
              // if (lp.selectionMode && lp.selectedItemCount == 1)
              //   IconButton(
              //     onPressed: () =>  showDialog(
              //         context: context,
              //         builder: (context) {
              //           var linkWarning = '';
              //           linkNameController = TextEditingController(text: lp.getName());
              //           linkController = TextEditingController(text: lp.getLink());
              //           return StatefulBuilder(
              //             builder: (BuildContext context, void Function(void Function()) setState) {
              //               return AlertDialog(
              //                 title: const Text("Update link"),
              //                 content: Container(
              //                   height: dHeight * 0.3,
              //                   child: Column(
              //                     children: [
              //                       Padding(
              //                         padding: const EdgeInsets.all(8.0),
              //                         child: Container(
              //                             width: dWidth * 0.5,
              //                             child: Column(
              //                               children: [
              //                                 TextField(
              //                                   controller: linkNameController,
              //                                 ),
              //                                 TextField(
              //                                   controller: linkController,
              //                                 ),
              //                               ],
              //                             )
              //                         ),
              //                       ),
              //                       Text(linkWarning,style: TextStyle(color: Colors.red),),
              //                       Row(
              //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
              //                         children: [
              //                           TextButton(
              //                               onPressed: () {
              //                                 if(lp.checkIfNotExists(linkNameController.text)){
              //                                   if(linkNameController.text != "" ) {
              //                                     lp.updateLink(
              //                                         Link(
              //                                           id: lp.selectedLinks[0],
              //                                           name: linkNameController
              //                                               .text,
              //                                           dateCreated: DateTime
              //                                               .now()
              //                                               .toString()
              //                                               .substring(
              //                                               0, 10),
              //                                           dateModified: DateTime
              //                                               .now()
              //                                               .toString()
              //                                               .substring(
              //                                               0, 10),
              //                                           modifiedBy: userName,
              //                                           addedBy: userName,
              //                                             link: linkController
              //                                                 .text
              //                                         )
              //                                     );
              //                                     linkNameController
              //                                         .text = "";
              //                                     linkController.text = "";
              //                                     Navigator.pop(context);
              //                                   }
              //                                   else{
              //                                     setState(() {
              //                                       linkWarning = 'All fields required';
              //                                     });
              //                                   }
              //                                 }
              //                                 else{
              //                                   setState(() {
              //                                     linkWarning = 'meeting name already exists';
              //                                   });
              //                                 }
              //                               },
              //                               child: const Text("Rename")),
              //                           TextButton(
              //                               onPressed: () =>Navigator.pop(context), child: const Text("Cancel"))
              //                         ],
              //                       )
              //                     ],
              //                   ),
              //                 ),
              //               );
              //             },
              //           );
              //         } ),
              //     icon: const Icon(
              //       Icons.edit,
              //       color: Colors.white,
              //     ),
              //   ),
              if (lp.selectionMode && lp.selectedItemCount == 1)
                IconButton(
                  onPressed: () =>showDialog(
                      context: context,
                      builder: (context) {
                        var selectedLink = lp.getSingleSelectedLink(lp.selectedLinks[0]);
                        return AlertDialog(
                          title: const Text("Link info"),
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
                                  "Name : "+ selectedLink.name,
                                ),
                                Text(
                                  "Added Date : "+ selectedLink.dateCreated,
                                ),
                                Text(
                                  "Added By : "+ selectedLink.addedBy,
                                ),
                                Text(
                                  "Modified Date : "+ selectedLink.dateModified,
                                ),
                                Text(
                                  "Modified By: "+ selectedLink.modifiedBy,
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
              child: (lp.linksList.isNotEmpty)?ListView.builder(
                  itemCount: lp.linksList.length,
                  itemBuilder: (context, index) => LinkBox(
                      lp.linksList[index], index, actionOnLongPress)):Center(child: const Text("No links created"),),
            ),
          ),
        ),
      ),
    );
  }
}
