import 'package:able/main.dart';
import 'package:able/utilities/events.dart';
import 'package:able/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:able/providers/event_provider.dart';
import 'package:provider/provider.dart';

import 'event_add_edit_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Alignment, Border,Row;


class EventBudget extends StatefulWidget {

  @override
  _EventBudgetState createState() => _EventBudgetState();
}

class _EventBudgetState extends State<EventBudget> {

  var currentFocus = DateTime.now();
  var yearMonth="";
  var dHeight;
  var isFirst;
  static const Color darkBlue = Color.fromRGBO(0, 0, 50, 1);

  @override
  void initState() {
    // TODO: implement initState
    var ep= Provider.of<EventProvider>(context,listen: false);
    ep.commonAttribute = DateTime.now().toString().substring(0,7);
    ep.getEventsForMonth();
    ep.loadBirthdayJson();
    super.initState();
  }



  Future<void> createSheet(List<Events> events) async{
    //Create a Excel document.

    //Creating a workbook.
    final Workbook workbook = Workbook();
    //Accessing via index
    final Worksheet sheet = workbook.worksheets[0];
    sheet.showGridlines = true;
    sheet.getRangeByName('A1').setText('Event no');
    sheet.getRangeByName('B1').setText('Event Date');
    sheet.getRangeByName('C1').setText('Event Name');
    sheet.getRangeByName('D1').setText('Organizing/Attending');
    sheet.getRangeByName('E1').setText('Total Budget');
    sheet.getRangeByName('F1').setText('Travel Expenses');
    sheet.getRangeByName('G1').setText('Registration Fees');
    sheet.getRangeByName('H1').setText('Postage and Telegram');
    sheet.getRangeByName('I1').setText('Momento');
    sheet.getRangeByName('J1').setText('Stationary Expenses');
    sheet.getRangeByName('K1').setText('Consumables');
    sheet.getRangeByName('L1').setText('Honorarium');
    sheet.getRangeByName('M1').setText('Others');

    for(int k=1;k<=events.length;k++){
      List<String> amount = [];
      LineSplitter ls = new LineSplitter();
      var expenses = ls.convert(events[k-1].splitUp);

      expenses.forEach((element) {
        var split = element.split("---");
        amount.add(split[1]);
      });
      sheet.getRangeByName('A${k+1}').setText(k.toString());
      sheet.getRangeByName('B${k+1}').setText(events[k-1].date);
      sheet.getRangeByName('C${k+1}').setText(events[k-1].eName);
      sheet.getRangeByName('D${k+1}').setText(events[k-1].type);
      sheet.getRangeByName('E${k+1}').setText(events[k-1].budget);
      sheet.getRangeByName('F${k+1}').setText(amount[0]);
      sheet.getRangeByName('G${k+1}').setText(amount[1]);
      sheet.getRangeByName('H${k+1}').setText(amount[2]);
      sheet.getRangeByName('I${k+1}').setText(amount[3]);
      sheet.getRangeByName('J${k+1}').setText(amount[4]);
      sheet.getRangeByName('K${k+1}').setText(amount[5]);
      sheet.getRangeByName('L${k+1}').setText(amount[6]);
      sheet.getRangeByName('M${k+1}').setText(amount[7]);
   
    }
    //Save the excel.
    final List<int>? bytes = workbook.saveAsStream();
    //Dispose the document.
    workbook.dispose();

    //Get the storage folder location using path_provider package.
    final path = Directory("storage/emulated/0/able_sheets");
    var status = await Permission.storage.status;

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

    final File file = File('${path.path}/events.xlsx');
    await file.writeAsBytes(bytes!);
  }




  @override
  Widget build(BuildContext context) {
    var ep = Provider.of<EventProvider>(context);
    dHeight = MediaQuery.of(context).size.height;
    isFirst = false;
    return FutureBuilder(
      future: ep.getEvents(),
      builder: (context,snapShot) => (snapShot.connectionState == ConnectionState.done)?
      Material(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Events and Budgets"),
            backgroundColor: darkBlue,
            actions: (userName!='')?[
              IconButton(
                  onPressed: () =>Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEditEvent(event:new Events(num: 0,eName: "", mode: "", budget: "budget", coreElements: "", date: "", eDescription: "", splitUp: "", targetParticipants: "", id: "", type: "")))),
                  icon: const Icon(Icons.add)
              ),
              IconButton(
                  onPressed: () => createSheet(ep.events).then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Excel sheet created"),))),
                  icon: const Icon(Icons.print)
              ),
            ]:[],
          ),
          drawer: Drawer(
            child: DrawerWidget(),
          ),
          body: Container(
            height: dHeight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: TableCalendar(
                      firstDay: DateTime.utc(2021, 6, 1),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: currentFocus,
                      eventLoader: (days) {
                        if(days.toString().substring(8,10) == "01" && !isFirst){
                          yearMonth = days.toString().substring(0,7);
                          isFirst = true;
                        }
                        if(days.toString().substring(0,7) != yearMonth) return [];
                        return ep.getEventsForDay(days.toString().substring(0,10)) + ep.getBirthDays(days.toString());
                      },
                      onPageChanged: (day){
                        setState(() {
                          yearMonth="";
                          currentFocus = day;
                          ep.commonAttribute = day.toString().substring(0,7);
                          ep.getEventsForMonth();
                          ep.getBirthDaysForList();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text("Events",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  ),
                  Container(

                    child: (ep.getEventsForMonth().isNotEmpty)?ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: ep.eventsForMonth.length,
                        itemBuilder: (context,index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(),borderRadius: BorderRadius.circular(50)),
                            child: ListTile(
                              title: Text(ep.eventsForMonth[index].eName),
                              subtitle: Text(ep.eventsForMonth[index].date),
                              trailing: (userName!='')?IconButton(
                                onPressed: () =>Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEditEvent(event:ep.eventsForMonth[index]))),
                                icon: const Icon(Icons.edit,color: Colors.orangeAccent,),
                              ):Container(),
                            ),
                          ),
                        )
                    ):Center(child: const Text("No events planned for this month"),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text("Birthdays",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  ),
                  Container(

                    child: (ep.getBirthDaysForList().isNotEmpty)?ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: ep.birthdaysForMonth.length,
                        itemBuilder: (context,index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(),borderRadius: BorderRadius.circular(50)),
                            child: ListTile(
                              title: Text(ep.birthdaysForMonth[index].substring(5)),
                              subtitle: Text(ep.birthdaysForMonth[index].substring(0,5)),
                            ),
                          ),
                        )
                    ):Center(child: const Text("No Birthdays for this month"),),
                  )
                ],
              ),
            ),
          ),
        ),
      ):Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
