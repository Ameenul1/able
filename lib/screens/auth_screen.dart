
import 'package:able/main.dart';
import 'package:able/screens/events_budgets.dart';
import 'package:able/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  
  var emailController  = TextEditingController();
  var passController = TextEditingController();
  bool? isValid = true;
  var dWidth;
  var dHeight;

  Future<void> saveSession(User user) async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    prefs.setString('currentUser', user.uid.toString());
    prefs = null;
  }

  Future<void> saveUnLoggedSession(String isUsed) async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    prefs.setString('isUsed', isUsed);
    prefs = null;
  }


  Future<void> validationAndSubmit() async {
    try {
      final User? user = (await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      ))
          .user;
      await saveSession(user!);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> HomeScreen()));
    } catch (e) {
      setState(() {
        isValid = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passController.dispose();
    isValid = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dWidth = MediaQuery.of(context).size.width;
    dHeight = MediaQuery.of(context).size.height;
    return Material(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                width: dWidth,
                height: dHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors:  [Colors.white,Colors.orangeAccent],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                ),
              ),
              Center(
                child: Container(
                  width: dWidth*0.7,
                  height: dHeight*0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5
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
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            width: dWidth*0.6,
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Enter college mail",
                                labelStyle: TextStyle(fontSize: 15),
                              ),
                              controller: emailController,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            width: dWidth*0.6,
                            child: TextField(
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                  labelText: "Password",
                                  labelStyle: TextStyle(fontSize: 15)
                              ),
                              controller: passController,
                            ),
                          ),
                        ),
                        if(!isValid!)Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text("Invalid user credentials",style: TextStyle(color: Colors.red,fontSize: 10),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                              onPressed: ()=> validationAndSubmit(),
                              style: ButtonStyle(
                                splashFactory: InkSplash.splashFactory
                              ),
                              child: Container(
                                width: dWidth*0.3,
                                height: dHeight*0.05,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 110, 1),
                                  border: Border.all(width: 1.0),
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    const Icon(Icons.login,color: Colors.white,),
                                    const Text("Login",style: TextStyle(color: Colors.white,fontSize: 20),)
                                  ],
                                ),
                              )
                          ),
                        ),
                        TextButton(onPressed: () async {
                          if(!cameIn) await saveUnLoggedSession('unlogged');
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>EventBudget()));
                            },
                            child: Text("Continue without sign in"))
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
