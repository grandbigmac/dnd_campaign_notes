import 'package:flutter/material.dart';
import 'package:ui_build_experiment/styling/input.dart';

import '../../models/Campaign.dart';

class NPCModal extends StatefulWidget {
  const NPCModal({super.key, required this.campaign});
  final Campaign campaign;

  @override
  State<NPCModal> createState() => _NPCModalState();
}

class _NPCModalState extends State<NPCModal> with TickerProviderStateMixin {
  late NPCModalState step;
  late Campaign campaign;

  //NPC Searching
  TextEditingController npcSearchController = TextEditingController();


  onSearchChanged() {
    searchResultsList();
  }

  searchResultsList() {
    //List<OutstandingKey> showResults = [];
//
    //if (outstandingKeysSearchTextController.text.isNotEmpty) {
    //  for (var i in outstandingKeysList) {
    //    var name = i.visitorName.toLowerCase();
    //    var keyName = i.keyTag.toLowerCase();
//
    //    if (name.contains(outstandingKeysSearchTextController.text.toLowerCase()) || keyName.contains(outstandingKeysSearchTextController.text.toLowerCase())) {
    //      showResults.add(i);
    //    }
    //  }
    //}
    //else {
    //  showResults = List.from(outstandingKeysList);
    //}
//
    //setState(() {
    //  outstandingKeysSearchResultsList = showResults;
    //});
  }

  //Swapping Steps
  void swapToAddNPC() {
    setState(() {
      step = NPCModalState.add;
    });
  }

  @override
  void initState() {
    super.initState();
    campaign = widget.campaign;
    step = NPCModalState.list;
    npcSearchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    super.dispose();
  }


  Widget modalHeader() {
    String title = '';
    String description = '';

    switch (step) {
      case NPCModalState.list:
        title = 'NPC List';
        description = 'Keep track of the notable NPCs you encounter on your adventure here and add memorable details that will help you down the line.';
        break;
      case NPCModalState.add:
        title = 'Add NPC';
        description = 'Add a new NPC to your ${campaign.name} adventure!';
        break;
      case NPCModalState.specific:
        title = '';
        description = '';
        break;
    }

    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05),
                    onPressed: () {
                      Navigator.pop(context);
                    }
                )
              ]
          ),
          Text(description, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget npcList() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          InkWell(
            onTap: () {
              swapToAddNPC();
            },
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Add New NPC', style: Theme.of(context).textTheme.labelMedium,),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                    Icon(Icons.add, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05),
                  ]
              ),
            ),
          ),
          TextFormField(
            decoration: inputFieldWithErrorMessage('Search for an NPC...', '', context),
            controller: npcSearchController,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ]
      )
    );
  }

  Widget npcSpecific() {
    return Container();
  }

  Widget npcAdd() {
    return Container();
  }

  Widget stepSwitch() {
    switch (step) {
      case NPCModalState.list:
        return npcList();
        break;
      case NPCModalState.specific:
        return npcSpecific();
        break;
      case NPCModalState.add:
        return npcAdd();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          color: Theme.of(context).primaryColor,
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                modalHeader(),
                stepSwitch(),
              ]
          )
      ),
    );
  }
}

enum NPCModalState {
  list, specific, add
}