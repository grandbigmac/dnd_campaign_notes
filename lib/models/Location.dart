import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  String id;
  String name;
  String description;
  String locationType;

  List<String> notes;

  String campaignID;

  Location({
    required this.id,
    required this.name,
    required this.description,
    required this.locationType,
    required this.notes,
    required this.campaignID,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'locationType': locationType,
    'notes': notes,
    'campaignID': campaignID,
  };

  factory Location.getLocation(DocumentSnapshot snapshot) {
    return Location(
      id: snapshot.id,
      name: snapshot.get('name'),
      description: snapshot.get('description'),
      locationType: snapshot.get('locationType'),
      notes: List.from(snapshot.get('notes')),
      campaignID: snapshot.get('campaignID'),
    );
  }
}