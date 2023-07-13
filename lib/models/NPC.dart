import 'package:cloud_firestore/cloud_firestore.dart';

class NPC {
  String id;
  String name;
  String description;

  String locationID;
  List<String> notes;

  String campaignID;

  NPC({
    required this.id,
    required this.name,
    required this.description,
    required this.locationID,
    required this.notes,
    required this.campaignID,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'locationID': locationID,
    'notes': notes,
    'campaignID': campaignID,
  };

  factory NPC.getNPC(DocumentSnapshot snapshot) {
    return NPC(
      id: snapshot.id,
      name: snapshot.get('name'),
      description: snapshot.get('description'),
      locationID: snapshot.get('locationID'),
      notes: List.from(snapshot.get('notes')),
      campaignID: snapshot.get('campaignID'),
    );
  }
}