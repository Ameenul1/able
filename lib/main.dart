// @dart=2.9
import 'package:able/providers/event_provider.dart';
import 'package:able/providers/gallery_provider.dart';
import 'package:able/providers/image_provider.dart';
import 'package:able/providers/links_provider.dart';
import 'package:able/screens/auth_screen.dart';
import 'package:able/screens/events_budgets.dart';
import 'package:able/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



String user="empty";
String userName ='';
bool cameIn = false;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'event_channel',
          channelName: 'able notifications',
          channelDescription: 'notifications for able events and birthdays',
          defaultColor: Colors.orangeAccent,
          ledColor: Colors.white,
          groupKey: "birthdays",
          importance: NotificationImportance.High,
          enableVibration: true,
          defaultPrivacy: NotificationPrivacy.Public,
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'birthday_channel',
          channelName: 'able notifications',
          channelDescription: 'notifications for able events and birthdays',
          defaultColor: Colors.orangeAccent,
          ledColor: Colors.white,
          groupKey: "events",
          importance: NotificationImportance.High,
          enableVibration: true,
          defaultPrivacy: NotificationPrivacy.Public,
          playSound: true,
        )
      ]
  );

  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(prefs.containsKey("currentUser")){
    user= prefs.getString('currentUser');
  }
  if(prefs.containsKey("isUsed")){
    cameIn=true;
  }
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => EventProvider()),
          ChangeNotifierProvider(create: (_) => GalleryProvider()),
          ChangeNotifierProvider(create: (_) => ClubImageProvider()),
          ChangeNotifierProvider(create: (_) => LinkProvider()),
        ],
        child:  MyApp(),
      )
  );

}



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  bool isLoggedIn = false;


  @override
  void initState() {
    if(user.toString() != "empty") isLoggedIn = true;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: (isLoggedIn)?HomeScreen():(cameIn)?EventBudget():AuthScreen(),
    );
  }
}

