import 'dart:convert';

import 'package:able/widgets/list_boxes.dart';
import 'package:flutter/material.dart';

class Budget extends StatefulWidget {
  final Function setBudget;
  final String splitUp;

  Budget({required this.splitUp,required this.setBudget});
  
  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {

  List<String> sub = ['Travel expenses','Registration fee','Postage and telegram','Momento','Stationary expenses','Consumables','Honorarium','Others'];
  List<String> amount = new List.filled(8, '0');
  int totalAmt =0;
  static const Color darkBlue = Color.fromRGBO(0, 0, 50, 1);

  @override
  void initState() {
    // TODO: implement initState
    if(widget.splitUp !=""){
      LineSplitter ls = new LineSplitter();
      var expenses = ls.convert(widget.splitUp);
      print(expenses);
      int i=0;
      expenses.forEach((element) {
        var split = element.split("---");
        amount[i] = split[1];
        i++;
      });
      totalAmt = total();
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sub.clear();
    super.dispose();
  }


  int total(){
    int total = 0;
    amount.forEach((element) {
      if(element!='') total+=int.parse(element);
    });
    return total;
  }

  void setValue(String sub,String amt,int i){
    setState(() {
      amount[i] = amt;
      this.sub[i] =sub;
      totalAmt = total();
    });

  }

  @override
  Widget build(BuildContext context) {
    var dWidth = MediaQuery.of(context).size.width;
    var dHeight = MediaQuery.of(context).size.height;
    return Material(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text("Budget Calculator"),
                backgroundColor: darkBlue,
              ),
              body: Container(
                width: dWidth,
                height: dHeight*0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text("Sub",style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold),),
                          Text("Amount" ,style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold),)
                        ],
                      ),
                    ),
                    Container(
                      height: dHeight*0.7,
                      width: dWidth*0.9,
                      decoration: BoxDecoration(
                        border: Border.all()
                      ),
                      child: ListView.builder(
                          itemCount: 8,
                          itemBuilder: (context,index) {
                            return ListBoxes(sub: sub[index],amt: amount[index],i: index,setValues: setValue,);
                          }
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: dWidth*0.3,
                            decoration: BoxDecoration(
                                border: Border.all(),
                              color: Colors.orangeAccent,
                            ),

                            child: TextButton(onPressed: () {
                              String splitUp ='';
                              for(int i=0;i<8;i++){
                                if(amount[i]=='') {
                                  amount[i] = '0';
                                }
                                  splitUp+=sub[i]+"---"+amount[i];
                                  splitUp+="\n";
                              }
                              totalAmt=total();
                              widget.setBudget(totalAmt.toString(),splitUp);
                              Navigator.of(context).pop();
                            }, child: const Text("save changes",style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold),)),
                          ),
                        ),
                        Text("Total amount : "+totalAmt.toString(),style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold),)
                      ],
                    )
                  ],
                ),
              ),
            )));
  }
}
