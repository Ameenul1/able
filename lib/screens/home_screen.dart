
import 'package:able/widgets/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';


class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final String name;

  late final String dept;

  late final String roll;

  late final String role;

  late final String phone;

  var dWidth;
  var dHeight;

  Future<void> getHomeDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var currentUID  = prefs.getString('currentUser');
    await FirebaseFirestore.instance.collection("users").doc(currentUID).get().then((value){
      name = value.data()!['name'];
      dept = value.data()!['dept'];
      roll = value.data()!['roll'];
      role = value.data()!['role'];
      phone = value.data()!['phone'];
    });
    userName = name;
  }

  @override
  Widget build(BuildContext context) {
    dWidth = MediaQuery.of(context).size.width;
    dHeight = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: getHomeDetails(),
      builder: (context,snapShot)=>(snapShot.connectionState == ConnectionState.done)?Material(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Home"),
            backgroundColor: Color.fromRGBO(0, 0, 50, 1),
          ),
          drawer: Drawer(
            child: DrawerWidget(),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orangeAccent,Colors.white70],
                begin: Alignment.topRight,
                end: Alignment.bottomRight,
              )
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: dWidth*0.75,
                    height: dHeight*0.55,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 5,
                              color: Colors.orangeAccent
                          )
                        ]
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                                width: dWidth*0.2,
                                height: dHeight*0.15,
                                child: Image.asset('assets/able_club.jpg')
                            ),
                          ),
                          Table(
                              columnWidths: {
                                0: FixedColumnWidth(dWidth*0.30),
                                1: FixedColumnWidth(dWidth*0.30)
                              },
                            children: [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text("Name :",style: TextStyle(fontSize: 15),),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(name ,style: TextStyle(fontSize: 15),),
                                  )
                                ]
                              ),
                              TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text("Roll no. :" ,style: TextStyle(fontSize: 15),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(roll ,style: TextStyle(fontSize: 15),),
                                    )
                                  ]
                              ),
                              TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text("Department :" ,style: TextStyle(fontSize: 15),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(dept ,style: TextStyle(fontSize: 15),),
                                    )
                                  ]
                              ),
                              TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text("Role :" ,style: TextStyle(fontSize: 15),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(role ,style: TextStyle(fontSize: 15),),
                                    )
                                  ]
                              ),
                              TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text("Phone :" ,style: TextStyle(fontSize: 15),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(phone ,style: TextStyle(fontSize: 15),),
                                    )
                                  ]
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ):Scaffold(body: const Center(child: CircularProgressIndicator())),
    );
  }
}
