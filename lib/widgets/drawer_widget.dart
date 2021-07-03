import 'package:able/loaders/folder_loader.dart';
import 'package:able/loaders/link_loader.dart';
import 'package:able/main.dart';
import 'package:able/screens/auth_screen.dart';
import 'package:able/screens/events_budgets.dart';
import 'package:able/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DrawerWidget extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height*0.25,
          width: MediaQuery.of(context).size.width,
          color: Colors.orangeAccent,
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Welcome, \n" + userName,
              style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if(userName!='')Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.home,color: Colors.orangeAccent,),
                    SizedBox(width: 10,),
                    Text("Home",style: TextStyle(fontSize: 18,color: Color.fromRGBO(0, 0, 50, 1)),)
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.calendar_today,color: Colors.orangeAccent,),
                    SizedBox(width: 10,),
                    Text("Events and budget",style: TextStyle(fontSize: 18,color: Color.fromRGBO(0, 0, 50, 1)),)
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EventBudget()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.image,color: Colors.orangeAccent,),
                    SizedBox(width: 10,),
                    Text("Gallery",style: TextStyle(fontSize: 18,color: Color.fromRGBO(0, 0, 50, 1)),)
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => FolderLoader()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.video_call,color: Colors.orangeAccent,),
                    SizedBox(width: 10,),
                    Text("Meeting Links",style: TextStyle(fontSize: 18,color: Color.fromRGBO(0, 0, 50, 1)),)
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LinkLoader()));
                },
              ),
            ),

            if(userName!='')Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.logout,color: Colors.orangeAccent,),
                    SizedBox(width: 10,),
                    Text("Logout",style: TextStyle(fontSize: 18,color: Color.fromRGBO(0, 0, 50, 1)),)
                  ],
                ),
                onPressed: () async {
                  FirebaseAuth.instance.signOut();
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.remove('currentUser');
                  userName='';
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthScreen()));
                },
              ),
            ),
            if(userName=='') Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.login,color: Colors.orangeAccent,),
                    SizedBox(width: 10,),
                    Text("Login",style: TextStyle(fontSize: 18,color: Color.fromRGBO(0, 0, 50, 1)),)
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthScreen()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
