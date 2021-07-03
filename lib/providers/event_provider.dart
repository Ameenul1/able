import 'dart:convert';
import 'package:able/main.dart';
import 'package:able/utilities/events.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_share/social_share.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

class EventProvider with ChangeNotifier {
  //link with database
  List<Events> events = [];
  int primaryKey = 1000;

  Future<void> addEvent(Events event) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var currentUID = prefs.getString('currentUser');
    await FirebaseFirestore.instance.collection("events").add({
      "id" : primaryKey,
      "ename": event.eName,
      "mode": event.mode,
      "desc": event.eDescription,
      "target": event.targetParticipants,
      "budget": event.budget,
      "core": event.coreElements,
      "splitup": event.splitUp,
      "date": event.date,
      "addedBy": userName,
      "type" : event.type,
    });
    await FirebaseFirestore.instance.collection("id_tracker").doc('key').update({
      'id' : primaryKey+1
    });

    notifyListeners();
  }

  Future<void> getEvents() async {
    await FirebaseFirestore.instance.collection("events").get().then((querySnapshot) {
      events.clear();
      querySnapshot.docs.forEach((result) {

        events.add(new Events(
            num: result.data()['id'],
            eName: result.data()['ename'],
            mode: result.data()['mode'],
            budget: result.data()['budget'],
            coreElements: result.data()['core'],
            date: result.data()['date'],
            eDescription: result.data()['desc'],
            splitUp: result.data()['splitup'],
            targetParticipants: result.data()['target'],
            id: result.id.toString(),
            type : result.data()['type']
        )
        );
      });

    });
    await FirebaseFirestore.instance.collection("id_tracker").doc('key').get().then((querySnapshot) {
      primaryKey = querySnapshot.data()!['id'];
    });
    await showScheduled();
    await setNotificationsForEvents();
    await setNotificationsForBirthDays();
  }

  Future<void> updateEvent(Events event) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var currentUID = prefs.getString('currentUser');
    await FirebaseFirestore.instance.collection("events").doc(event.id).update({
      "ename": event.eName,
      "mode": event.mode,
      "desc": event.eDescription,
      "target": event.targetParticipants,
      "budget": event.budget,
      "core": event.coreElements,
      "splitup": event.splitUp,
      "date": event.date,
      "updatedBy": userName,
      "type" : event.type,
    });
    await AwesomeNotifications().cancel(event.num);
    notifyListeners();
  }

  Future<void> deleteEvent(Events event) async{
    await FirebaseFirestore.instance.collection("events").doc(event.id).delete();
    await AwesomeNotifications().cancel(event.num);
    notifyListeners();
  }


  //getting dates for calendar

  List<Events> eventsForMonth =[];
  String commonAttribute = DateTime.now().toString().substring(0,7);

  List<String> getEventsForDay(String day){
    List<String> eventsForDay = [];
    if(commonAttribute!=day.substring(0,7))
    {
      commonAttribute = day.substring(0,7);
      getEventsForMonth();
    }
    var eventsForDayFull = events.where((element) => element.date==day).toList();
    eventsForDayFull.forEach((element) {
      eventsForDay.add(element.eName);
    });
    return eventsForDay;
  }

  List<Events> getEventsForMonth(){
    eventsForMonth =[];
    eventsForMonth = (events.where((element) {
      if(element.date.substring(0,7)==commonAttribute){
        return true;
      }
      return false;
    }).toList());
    return eventsForMonth;
  }

  Map<String,String> birthDays = {};

  Future<void> loadBirthdayJson() async {
    String data = await rootBundle.loadString('assets/birthdays');
    var jsonResult = json.decode(data);
    List<dynamic> res = jsonResult['Sheet1'];
    res.forEach((value) {
      birthDays.addAll({value['DOB'] : value['NAME']});
    });

  }

  List<String> getBirthDays(String day){
    List<String> res = [];
    birthDays.forEach((key, value) {
      if(key.substring(0,5)==day.substring(5,10)){
        res.add(value);
      }
    });
    return res;
  }

  List<String> birthdaysForMonth = [];
  List<String> getBirthDaysForList(){
    birthdaysForMonth = [];
    birthDays.forEach((key, value) {
      if(key.substring(0,2)==commonAttribute.substring(5,7)){
        birthdaysForMonth.add(key+value+"'s Birthday");
      }
    });
    birthdaysForMonth.sort();
    return birthdaysForMonth;
  }

  //setting up notifications

  Future<void> setNotificationsForBirthDays() async{
    int i=0;
    birthDays.forEach((key, value) {
      var day = DateTime(
        DateTime.now().year,
        int.parse(key.substring(0,2)),
        int.parse(key.substring(3,5)),
      );

      if(day.isAfter(DateTime.now())){
        if(!scheduledNotificationsForBdId.contains(i)){
          print("$i selected");
          showNotification(day, i, "Yipee , Its $value 's Birthday ", 'Birthday Notification','birthday_channel');
        }
      }
      i++;
    });
  }

  Future<void> setNotificationsForEvents() async{
     events.forEach((element) {
       var day = DateTime(
         int.parse(element.date.substring(0,4)),
         int.parse(element.date.substring(5,7)),
         int.parse(element.date.substring(8,10)),
       );
       if(day.isAfter(DateTime.now())){
         if(!scheduledNotificationsForEventsId.contains(element.id)){

           showNotification(day.subtract(Duration(days: 3)), element.num, " ${element.eName} coming soon", 'Event Notification','event_channel');
         }
       }
     });
  }

  List<int> scheduledNotificationsForBdId = [];
  List<int> scheduledNotificationsForEventsId = [];
  Future<void> showScheduled() async{
    scheduledNotificationsForBdId = [];
    scheduledNotificationsForEventsId = [];
    var sn = await AwesomeNotifications().listScheduledNotifications();
    sn.forEach((element) {
      if(element.content.channelKey == 'birthday_channel'){
        scheduledNotificationsForBdId.add(element.content.id);
      }
      else if(element.content.channelKey == 'event_channel') {
        scheduledNotificationsForEventsId.add(element.content.id);
      }
    });

  }

  Future<void> showNotification(DateTime date , int id , String message, String title,String channel) async{

    DateTime dateTime = date;

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channel,
        title: title,
        body: message,
        autoCancel: false,
      ),
      schedule: NotificationSchedule(
        allowWhileIdle: true,
        crontabSchedule: CronHelper.instance.atDate(dateTime.toUtc(),initialSecond: 0),
      )
    );

  }


  // Future<File> urlToFile(String imageUrl) async {
  //   var rng = new Random();
  //   Directory tempDir = await getTemporaryDirectory();
  //   String tempPath = tempDir.path;
  //   File file = new File('$tempPath'+ (rng.nextInt(100)).toString() +'.png');
  //   http.Response response = await http.get(Uri.parse(imageUrl));
  //   await file.writeAsBytes(response.bodyBytes);
  //   return file;
  // }
  //
  // // Insta stories
  // Future<void> postStory(String name) async{
  //   var names = name.split(' \$ ');
  //   for(int i=0;i<names.length;i++){
  //     Reference ref = FirebaseStorage.instance
  //         .ref()
  //         .child('birthday_images').child('${names[i]}.jpg');
  //     var url = await ref.getDownloadURL();
  //     var image = await urlToFile(url);
  //     SocialShare.shareInstagramStory(
  //        image.path,
  //       backgroundBottomColor: '#ffffff',
  //       backgroundTopColor: '#ffa500',
  //       attributionURL: "@ameenul__",
  //     );
  //   }
  //
  // }
}
