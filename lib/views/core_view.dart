import 'package:flutter/material.dart';
import 'package:ui_build_experiment/models/Campaign.dart';
import 'package:ui_build_experiment/tools.dart';
import 'package:ui_build_experiment/views/create_view.dart';
import 'package:ui_build_experiment/views/drawer.dart';
import 'package:ui_build_experiment/views/navbar.dart';
import 'package:ui_build_experiment/views/profile_view.dart';

import 'campaign_overview.dart';
import 'main_view.dart';

//Defines which widgets can be accessed from the application
List<Widget> availableViews = [
  const HomeView(), const ProfileView(), const CreateView()
];
//Defines the currently accessed widget
late Widget selectedView;
late StateSetter stateSetter;

class CoreView extends StatefulWidget {
  const CoreView({super.key,});

  @override
  State<CoreView> createState() => _CoreViewState();
}

class _CoreViewState extends State<CoreView> {

  @override
  void initState() {
    super.initState();
    selectedView = availableViews[0];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      stateSetter = setState;
    });
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        logoutDialog(context);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.menu, color: Colors.white,),
                );
              }
            ),
          ),
          drawer: newDrawer(context),
          bottomNavigationBar: BottomNavBar(setMainState: setState,),
          resizeToAvoidBottomInset: true,
          body: selectedView
      ),
    );
  }
}


/**TODO
 * _______________
 *
 */