import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui_build_experiment/models/Campaign.dart';
import 'package:ui_build_experiment/tools.dart';
import 'package:ui_build_experiment/views/campaign_modals/monster.dart';

class CampaignOverview extends StatefulWidget {
  const CampaignOverview({super.key, required this.campaign});
  final Campaign campaign;

  @override
  State<CampaignOverview> createState() => _CampaignOverviewState();
}

class _CampaignOverviewState extends State<CampaignOverview> with TickerProviderStateMixin{
  late Campaign campaign;

  late double _scaleMonster;
  late double _scaleLocation;
  late double _scaleNpc;
  late double _scaleItem;

  late AnimationController _monsterController;
  late AnimationController _locationController;
  late AnimationController _npcController;
  late AnimationController _itemController;

  void initAnim() {
    _monsterController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
    _locationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
    _npcController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
    _itemController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
  }
  void disposeAnim() {
    _monsterController.dispose();
    _locationController.dispose();
    _npcController.dispose();
    _itemController.dispose();
  }
  
  int monstersCount = 3;
  int locationsCount = 2;
  int npcCount = 6;
  int itemCount = 1;

  @override
  void initState() {
    super.initState();
    initAnim();
    campaign = widget.campaign;
  }
  @override
  void dispose() {
    super.dispose();
    disposeAnim();
  }

  Widget headerRow() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(campaign.name, style: Theme.of(context).textTheme.titleLarge!.copyWith(shadows: [containerShadow])),
              Text(campaign.description, style: Theme.of(context).textTheme.labelMedium!),
            ]
          ),
        ),
      ),
    );
  }

  //NPCs, Locations, Items, Monsters
  Widget quickInfoRow() {
    _scaleMonster = 1 - _monsterController.value;
    _scaleLocation = 1 - _locationController.value;
    _scaleNpc = 1 - _npcController.value;
    _scaleItem = 1 - _itemController.value;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTapDown: (details) => _monsterController.forward(),
                          onTapUp: (details) => _monsterController.reverse(),
                          onTapCancel: () => _monsterController.reverse(),
                          onTap: () {
                            openCampaignModalSheet(context, 'monster');
                          },
                          child: Transform.scale(
                            scale: _scaleMonster,
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.1,
                                  child: Image.asset('assets/images/monster.png', fit: BoxFit.fitWidth),
                                ),
                                Text(monstersCount.toString(), style: Theme.of(context).textTheme.titleSmall!.copyWith(shadows: [containerShadow])),
                              ]
                            ),
                          ),
                        )
                      ),
                      Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTapDown: (details) => _locationController.forward(),
                            onTapUp: (details) => _locationController.reverse(),
                            onTapCancel: () => _locationController.reverse(),
                            onTap: () {
                              //
                            },
                            child: Transform.scale(
                              scale: _scaleLocation,
                              child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.1,
                                      child: Image.asset('assets/images/location.png', fit: BoxFit.fitWidth),
                                    ),
                                    Text(locationsCount.toString(), style: Theme.of(context).textTheme.titleSmall!.copyWith(shadows: [containerShadow])),
                                  ]
                              ),
                            ),
                          )
                      ),
                      Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTapDown: (details) => _npcController.forward(),
                            onTapUp: (details) => _npcController.reverse(),
                            onTapCancel: () => _npcController.reverse(),
                            onTap: () {
                              //
                            },
                            child: Transform.scale(
                              scale: _scaleNpc,
                              child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.1,
                                      child: Image.asset('assets/images/audience.png', fit: BoxFit.fitWidth),
                                    ),
                                    Text(npcCount.toString(), style: Theme.of(context).textTheme.titleSmall!.copyWith(shadows: [containerShadow])),
                                  ]
                              ),
                            ),
                          )
                      ),
                      Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTapDown: (details) => _itemController.forward(),
                            onTapUp: (details) => _itemController.reverse(),
                            onTapCancel: () => _itemController.reverse(),
                            onTap: () {
                              //
                            },
                            child: Transform.scale(
                              scale: _scaleItem,
                              child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.1,
                                      child: Image.asset('assets/images/chest.png', fit: BoxFit.fitWidth),
                                    ),
                                    Text(itemCount.toString(), style: Theme.of(context).textTheme.titleSmall!.copyWith(shadows: [containerShadow])),
                                  ]
                              ),
                            ),
                          )
                      ),
                    ]
                )
              ]
          ),
        ),
      ),
    );
  }

  Widget notesRow() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Notes', style: Theme.of(context).textTheme.titleSmall!.copyWith(shadows: [containerShadow])),
                    //Icon(Icons.note, color: Colors.white, size: MediaQuery.of(context).size.width * 0.1),
                  ]
                ),
                Text('General notes about your adventure you want to access quickly.', style: Theme.of(context).textTheme.labelMedium,),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        //view notes modal
                      },
                      child: Padding(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('View Notes', style: Theme.of(context).textTheme.labelLarge),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                            Icon(Icons.note, color: Colors.white),
                          ]
                        )
                      )
                    )
                  ]
                )
              ]
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Theme.of(context).primaryColor, Colors.transparent],
              )
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.network(campaign.displayImageUrl).image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  headerRow(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  quickInfoRow(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  notesRow(),
                ]
            ),
          ),
        ),
      ],
    );
  }
}

void openCampaignModalSheet(BuildContext context, String type) {
  showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      builder: (BuildContext context) {
        switch (type) {
          case 'monster':
            return const MonsterModal();
          case 'location':
            return const MonsterModal();
          case 'npc':
            return const MonsterModal();
          case 'item':
            return const MonsterModal();
          default:
            return const MonsterModal();
        }
      }
  );
}
/**TODO
 * _______________
 *
 */