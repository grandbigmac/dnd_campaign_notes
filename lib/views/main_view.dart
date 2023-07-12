import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui_build_experiment/controllers/home.dart';
import 'package:ui_build_experiment/styling/colours.dart';
import 'package:ui_build_experiment/tools.dart';
import 'package:ui_build_experiment/views/navbar.dart';

import '../models/Campaign.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key,});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    log('Reinit home');
    clearLists();
    homePageDataFuture = getHomeData();
  }
  @override
  void dispose() {
    super.dispose();
    log('Dispose home');
    clearLists();
  }

  Widget campaignIconWidget(Campaign campaign, int index) {
    AnimationController controller = animControllerList[index];
    scaleList[index] = 1 - controller.value;

    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: GestureDetector(
        onTapDown: (details) => controller.forward(),
        onTapUp: (details) => controller.reverse(),
        onTapCancel: () => controller.reverse(),
        onTap: () {
          //Go to campaign view
        },
        child: Transform.scale(
          scale: scaleList[index],
          child: Container(
              width: double.infinity, height: MediaQuery.of(context).size.height * 0.15,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [containerShadow],
                image: campaign.displayImageUrl.isNotEmpty?
                DecorationImage(
                  image: NetworkImage(campaign.displayImageUrl,),
                  fit: BoxFit.cover,
                )
                    :
                DecorationImage(
                  image: Image.asset('assets/images/defaultbg.png').image,
                  fit: BoxFit.cover,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaY: 2, sigmaX: 6),
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.name,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white, shadows: [containerShadow]),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ]
                    ),
                  ),
                ),
              )
          ),
        ),
      ),
    );
  }

  Widget campaignListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              openCreateCampaignModal(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Create Campaign', style: Theme.of(context).textTheme.labelMedium),
                  Icon(Icons.add, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05)
                ]
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: FutureBuilder(
            future: homePageDataFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                //If no Campaigns found:
                if (campaignList.isEmpty) {
                  return Center(
                    child: Text('No Campaigns found yet!', style: Theme.of(context).textTheme.labelMedium),
                  );
                }

                //If Campaigns found:
                //Iterate through the campaign list and build the column
                List<Widget> campaigns = [];
                int count = 0;
                for (Campaign i in campaignList) {
                  animControllerList.add(AnimationController(
                      vsync: this,
                      duration: const Duration(milliseconds: 100),
                      lowerBound: 0.0,
                      upperBound: 0.1
                  )..addListener(() {setState((){});}));
                  scaleList.add(0.0);
                  campaigns.add(campaignIconWidget(i, count));
                  count++;
                }
                return Column(
                  children: campaigns,
                );
              }
              else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: loadingWidget(context));
              }
              else {
                return Center(child: Text('An error occurred when retrieving campaigns.', style: Theme.of(context).textTheme.labelMedium));
              }
            }
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03, right: MediaQuery.of(context).size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Campaigns', style: Theme.of(context).textTheme.titleLarge),
                Container(
                  width: double.infinity, height: MediaQuery.of(context).size.width * 0.01,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft, end: Alignment.centerRight,
                      colors: [Colors.grey.shade900, Theme.of(context).primaryColor]
                    )
                  ),
                ),
                campaignListView(),
              ]
          ),
        )
    );
  }
}


/**TODO
 * _______________
 *
 */