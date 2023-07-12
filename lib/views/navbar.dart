import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_build_experiment/main.dart';
import 'package:ui_build_experiment/views/create_view.dart';
import 'package:ui_build_experiment/views/core_view.dart';
import 'package:ui_build_experiment/views/main_view.dart';
import 'package:ui_build_experiment/views/profile_view.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, required this.setMainState});
  final StateSetter setMainState;

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin {

  late double _scaleHome;
  late AnimationController homeAnimController;

  late double _scaleProfile;
  late AnimationController profileAnimController;

  late double _scaleCreate;
  late AnimationController createAnimController;

  animInit() {
    homeAnimController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});

    profileAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {setState((){});});

    createAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {setState((){});});
  }

  @override
  void initState() {
    super.initState();
    animInit();
  }

  @override
  void dispose() {
    super.dispose();
    homeAnimController.dispose();
    profileAnimController.dispose();
    createAnimController.dispose();
  }

  GestureDetector homeButton() {
    _scaleHome = 1 - homeAnimController.value;

    return GestureDetector(
      onTapDown: (details) => homeAnimController.forward(),
      onTapUp: (details) => homeAnimController.reverse(),
      onTapCancel: () => homeAnimController.reverse(),
      onTap: () {
        widget.setMainState(() {
          selectedView = const HomeView();
        });
      },
      child: Transform.scale(
        scale: _scaleHome,
        child: Icon(Icons.home, size: MediaQuery.of(context).size.width * 0.1, color: selectedView.toString() == 'HomeView'? Colors.white : null),
      )
    );
  }

  GestureDetector profileButton() {
    _scaleProfile = 1 - profileAnimController.value;

    return GestureDetector(
        onTapDown: (details) => profileAnimController.forward(),
        onTapUp: (details) => profileAnimController.reverse(),
        onTapCancel: () => profileAnimController.reverse(),
        onTap: () {
          widget.setMainState(() {
            selectedView = const ProfileView();
          });
        },
        child: Transform.scale(
          scale: _scaleProfile,
          child: Icon(Icons.account_circle_rounded, size: MediaQuery.of(context).size.width * 0.1, color: selectedView.toString() == 'ProfileView'? Colors.white : null,),
        )
    );
  }

  GestureDetector createButton() {
    _scaleCreate = 1 - createAnimController.value;

    return GestureDetector(
        onTapDown: (details) => createAnimController.forward(),
        onTapUp: (details) => createAnimController.reverse(),
        onTapCancel: () => createAnimController.reverse(),
        onTap: () {
          widget.setMainState(() {
            selectedView = const CreateView();
          });
        },
        child: Transform.scale(
          scale: _scaleCreate,
          child: Icon(CupertinoIcons.bolt_circle_fill, size: MediaQuery.of(context).size.width * 0.1, color: selectedView.toString() == 'CreateView'? Colors.white : null),
        )
    );
  }


  @override
  Widget build(BuildContext context) {

    List<Widget> navBarItems = [
      homeButton(), profileButton(), createButton(),
    ];

    return BottomAppBar(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: navBarItems
      ),
    );
  }
}