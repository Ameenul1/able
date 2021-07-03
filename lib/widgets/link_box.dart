import 'package:able/main.dart';
import 'package:flutter/material.dart';
import 'package:able/utilities/Links.dart';
import 'package:provider/provider.dart';
import 'package:able/providers/links_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkBox extends StatefulWidget {
  Link link;
  int index;
  Function longPress;
  LinkBox(this.link,this.index,this.longPress);

  @override
  _LinkBoxState createState() => _LinkBoxState();
}

class _LinkBoxState extends State<LinkBox> {
  var isSelected = false;
  var dHeight;

  void _launchURL() async {
    print("called");
    print(widget.link.link);
    await canLaunch(widget.link.link) ? await launch(widget.link.link) : print("cannot launch");
  }


  @override
  Widget build(BuildContext context) {
    var lp = Provider.of<LinkProvider>(context,listen: false);
    dHeight = MediaQuery.of(context).size.height;
    isSelected = lp.selected[widget.index];
    return WillPopScope(
      onWillPop: () async{
        if(isSelected){
          lp.removeSelections();
          return false;
        }
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            if(lp.selectionMode) lp.updateSelected(widget.index,widget.link.id);
          },
          onLongPress: () {
            if(userName!=''){
              lp.updateSelected(widget.index,widget.link.id);
            }
          },
          child: Container(
            height: dHeight*0.08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                      child: const  Icon(Icons.link,color: Colors.orangeAccent,size: 30,),
                    ),
                    Text(
                      widget.link.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(50),
                      color: Color.fromRGBO(0, 0, 50, 1),
                    ),

                    child: TextButton(
                        onPressed: () => _launchURL(),
                        child: Text("Join now",style: TextStyle(color: Colors.white),)
                    ),
                  ),
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
