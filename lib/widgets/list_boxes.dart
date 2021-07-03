import 'package:flutter/material.dart';

class ListBoxes extends StatefulWidget {
  String sub;
  String amt;
  Function setValues;
  int i;

  ListBoxes({required this.sub,required this.amt,required this.setValues,required this.i});

  @override
  _ListBoxesState createState() => _ListBoxesState();
}

class _ListBoxesState extends State<ListBoxes> {
  var subController = TextEditingController();
  var amountController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    subController.text = widget.sub;
    amountController.text = widget.amt;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    subController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text((widget.i +1).toString()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: MediaQuery.of(context).size.width*0.4,
                decoration: BoxDecoration(border: Border.all()),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    enabled: false,
                    controller: subController,
                    onChanged: (val) => widget.setValues(val,amountController.text,widget.i),
                  ),
                )),
          ),
          Text("="),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: MediaQuery.of(context).size.width*0.3,
                decoration: BoxDecoration(border: Border.all()),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => widget.setValues(subController.text,val,widget.i),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
