import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui_build_experiment/views/create_campaign.dart';

import '../models/Campaign.dart';

late Future<void> homePageDataFuture;
List<Campaign> campaignList = [];

Future<void> getHomeData() async {
  campaignList = await getCampaignsForUser();
}

//Futures to fill lists
Future<List<Campaign>> getCampaignsForUser() async {
  List<Campaign> list = [];

  try {
    await FirebaseFirestore.instance.collection('campaign').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      for (var i in value.docs) {
        try {
          list.add(Campaign.getCampaign(i));
        }
        catch (e) {
          log('Failed to get campaign ${i.id}\nReason: $e');
        }
      }
    });
  }
  catch (e) {
    log('Failed to get campaigns: $e');
  }

  return list;
}


//Animation Controller + Scale lists for each campaign widget
List<AnimationController> animControllerList = [];
List<double> scaleList = [];

void clearLists() {
  //for (AnimationController i in animControllerList) {
  //  i.dispose();
  //}
  animControllerList.clear();
  scaleList.clear();
}

void disposeControllers() {
  for (AnimationController i in animControllerList) {
    i.dispose();
  }
}

void openCreateCampaignModal(BuildContext context) {
  showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      builder: (BuildContext context) {
        return const CreateCampaign();
      }
  );
}