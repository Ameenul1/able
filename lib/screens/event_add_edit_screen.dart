import 'dart:convert';
import 'dart:io';
import 'package:able/providers/event_provider.dart';
import 'package:able/screens/budget_screen.dart';
import 'package:able/utilities/events.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Alignment, Border,Row;


// ignore: must_be_immutable
class AddEditEvent extends StatefulWidget {
  
  Events event;
  
  AddEditEvent({required this.event});
  
  @override
  _AddEditEventState createState() => _AddEditEventState();
}

class _AddEditEventState extends State<AddEditEvent> {
  var nameController = TextEditingController();
  var modeController = TextEditingController();
  var descController = TextEditingController();
  var tpController = TextEditingController();
  var coreController = TextEditingController();
  var budController = TextEditingController();
  var splitController = TextEditingController();

  var datePicked = "chosen date";
  var isEdit = false;
  var _verticalGroupValue = 'organizing';
  var dWidth;
  var dHeight;
  static const Color darkBlue = Color.fromRGBO(0, 0, 50, 1);

  @override
  void initState(){
    if(widget.event.id!=""){
      nameController.text = widget.event.eName;
      modeController.text=widget.event.mode;
      descController.text = widget.event.eDescription;
      tpController.text = widget.event.targetParticipants;
      coreController.text = widget.event.coreElements;
      budController.text=widget.event.budget;
      splitController.text=widget.event.splitUp;
      datePicked = widget.event.date;
      _verticalGroupValue = widget.event.type;
      isEdit=true;
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    modeController.dispose();
    descController.dispose();
    tpController.dispose();
    coreController.dispose();
    budController.dispose();
    splitController.dispose();
    super.dispose();
  }

  Future<void> validateAndSubmit(Function add ,Function update) async {
    if (nameController.text.isEmpty ||
        modeController.text.isEmpty ||
        descController.text.isEmpty ||
        tpController.text.isEmpty ||
        coreController.text.isEmpty ) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  "Warning",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                content: const Text("All fields are required"),
              ));
    } else if (datePicked == "chosen date") {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  "Warning",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                content: const Text("Pick an approximate date"),
              ));
    } else {
      widget.event = Events(
          num: widget.event.num,
          eName: nameController.text,
          mode: modeController.text,
          budget: budController.text,
          coreElements: coreController.text,
          date: datePicked,
          eDescription: descController.text,
          splitUp: splitController.text,
          targetParticipants: tpController.text,
          id: widget.event.id,
          type: _verticalGroupValue
      );
      await createSheet();
      try {
        if(isEdit){
          await update(widget.event);
        }
        else{
          await add(widget.event);
        }
        Navigator.pop(context);
      } catch (e) {
        print(e);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "Error",
                style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              content: Text("May be a server error or a network error"),
            ));
      }
    }
  }

  Future<void> delete(Function delete) async{
    if(widget.event.id != ""){
      try {
        await delete(widget.event);
        Navigator.pop(context);
      } catch (e) {
        print(e);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                "Error",
                style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              content: const Text("May be a server error or a network error"),
            ));
      }
    }
  }

  void setBudget(String amount,String splitUp){
    setState(() {
      budController.text = amount;
      splitController.text = splitUp;
    });
  }

  Future<void> createSheet() async{
    //Create a Excel document.

    //Creating a workbook.
    final Workbook workbook = Workbook();
    //Accessing via index
    final Worksheet sheet = workbook.worksheets[0];
    sheet.showGridlines = true;
    List<String> sub = [];
    List<String> amount = [];
    LineSplitter ls = new LineSplitter();
    var expenses = ls.convert(widget.event.splitUp);

    expenses.forEach((element) {
      var split = element.split("---");
      sub.add(split[0]);
      amount.add(split[1]);
    });

    sheet.getRangeByName('A1').setText('Expenditure');
    sheet.getRangeByName('B1').setText('Amount');

    for(int i=1;i<=sub.length;i++){
      sheet.getRangeByName('A${i+1}').setText(sub[i-1]);
      sheet.getRangeByName('B${i+1}').setNumber(double.parse(amount[i-1]));
    }
    sheet.getRangeByName('A10').setText('Total');
    sheet.getRangeByName('B10').setFormula('=SUM(B2:B21)');

    //Save the excel.
    final List<int>? bytes = workbook.saveAsStream();
    //Dispose the document.
    workbook.dispose();
    
    final path = Directory("storage/emulated/0/able_sheets");
    var status = await Permission.storage.status;
    print(status);
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    var nextStatus = await Permission.manageExternalStorage.status;
    if (!nextStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    if ((await path.exists())) {
      path.path;
    } else {
      path.create();
      path.path;
    }

    final File file = File('${path.path}/${widget.event.eName}.xlsx');
    await file.writeAsBytes(bytes!);
    sub.clear();
    amount.clear();
  }

  @override
  Widget build(BuildContext context) {
    dWidth = MediaQuery.of(context).size.width;
    dHeight = MediaQuery.of(context).size.height;
    var ep = Provider.of<EventProvider>(context);
    return Material(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text((isEdit)?"Edit Event":"Add Events"),
              backgroundColor: darkBlue,
              actions: [
                if(widget.event.id != "")IconButton(
                    onPressed: () =>delete(ep.deleteEvent),
                    icon: const Icon(Icons.delete)
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: darkBlue,
              child: const Icon(Icons.monetization_on,color: Colors.orangeAccent,),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>Budget(setBudget: setBudget, splitUp: splitController.text,)))
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      (isEdit)?widget.event.eName:"A new event",
                    style: TextStyle(
                        fontSize: 20, color: darkBlue),
                  ),
                ),
                Container(
                  width: dWidth * 0.9,
                  height: dHeight * 0.7,
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(blurRadius: 5, color: Colors.orangeAccent)
                  ]),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text("Name : "),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: TextField(
                                controller: nameController,
                              )),
                        ),
                        const  Text("Mode : "),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: TextField(
                                controller: modeController,
                              )),
                        ),
                        const Text("Description : "),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: TextField(
                                maxLines: 3,
                                keyboardType: TextInputType.multiline,
                                controller: descController,
                              )),
                        ),
                        const Text("Target participants : "),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: TextField(
                                maxLines: 3,
                                keyboardType: TextInputType.multiline,
                                controller: tpController,
                              )),
                        ),
                        const Text("Core elements : "),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: TextField(
                                maxLines: 3,
                                keyboardType: TextInputType.multiline,
                                controller: coreController,
                              )),
                        ),
                        const Text("Budget : "),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: TextField(
                                enabled: false,
                                keyboardType: TextInputType.phone,
                                controller: budController,
                              )),
                        ),
                        const Text("Split up : "),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: TextField(
                                enabled: false,
                                maxLines: 10,
                                keyboardType: TextInputType.number,
                                controller: splitController,
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Approx. date  : "),
                              Text(datePicked)
                            ],
                          ),
                        ),
                        TextButton(
                            onPressed: () => showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now()
                                      .subtract(Duration(days: 1000)),
                                  lastDate:
                                      DateTime.now().add(Duration(days: 1000)),
                                ).then((value) {
                                  setState(() {
                                    datePicked = value!
                                        .toIso8601String()
                                        .substring(0, 10);
                                  });
                                }),
                            child: const Text("Pick a date")),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RadioGroup<String>.builder(
                            direction: Axis.horizontal,
                            groupValue: _verticalGroupValue,
                            onChanged: (value) => setState(() {
                              _verticalGroupValue = value!;
                            }),
                            items: ['organizing','attending'],
                            itemBuilder: (item) => RadioButtonBuilder(
                              item,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.orangeAccent,
                  width: dWidth,
                  child: TextButton(
                    onPressed: () => validateAndSubmit(ep.addEvent,ep.updateEvent),
                    child: Text((isEdit)?"Update event":"Add event",
                        style: TextStyle(
                            fontSize: 20, color: darkBlue)),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
