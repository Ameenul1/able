

class Events {
  late int num;
  late String id;
  late String mode;
  late String eName;
  late String eDescription;
  late String coreElements;
  late String targetParticipants;
  String budget = "0";
  String splitUp = "none";
  late String date;
  late String type;

  Events(
      {required this.num,
        required this.eName,
      required this.mode,
      required this.budget,
      required this.coreElements,
      required this.date,
      required this.eDescription,
      required this.splitUp,
      required this.targetParticipants,
        required this.id,
        required this.type
      });
}
