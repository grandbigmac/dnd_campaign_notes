import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  String id;

  String uid;
  String name;
  String description;

  String displayImageUrl;

  Campaign({
    required this.id,
    required this.uid,
    required this.name,
    required this.description,
    required this.displayImageUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'displayImageUrl': displayImageUrl,
    'uid': uid,
  };

  factory Campaign.getCampaign(DocumentSnapshot snapshot) {
    return Campaign(
      id: snapshot.id,
      uid: snapshot.get('uid'),
      name: snapshot.get('name'),
      description: snapshot.get('description'),
      displayImageUrl: snapshot.get('displayImageUrl'),
    );
  }
}