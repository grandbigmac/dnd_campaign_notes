import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui_build_experiment/controllers/shared/navigation.dart';
import 'package:ui_build_experiment/styling/input.dart';

import '../controllers/splash.dart';

class Splash extends StatefulWidget {
  const Splash({super.key,});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin{
  late Future<bool> loggedIn;

  late double _scaleLogin;
  late AnimationController loginAnimController;


  void animInit() {
    loginAnimController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
  }

  Timer initTimer() {
    timerInit = true;

    return Timer.periodic(Duration(seconds: 5,), (timer) {
      setState(() {

        if (imageIndex == images.length - 1) {
          imageIndex = 0;
        }
        else if (imageIndex > images.length - 1) {
          imageIndex = 0;
        }
        else {
          imageIndex++;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loggedIn = checkIfLoggedIn(context);
    animInit();
    if (!timerInit) {
      timer = initTimer();
    }
  }
  @override
  void dispose() {
    super.dispose();
    loginAnimController.dispose();
    timer.cancel();
  }

  Widget splash() {
    return SizedBox(
      width: double.infinity,
      child: Column(
          mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12.0),
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Theme.of(context).primaryColor,
              child: Text('My New App', style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  )
              )),
            )
          ]
      ),
    );
  }

  Widget error() {
    return SizedBox(
      width: double.infinity,
      child: Column(
          mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('An error occurred.', style: Theme.of(context).textTheme.bodyMedium),
          ]
      ),
    );
  }

  Widget login() {
    _scaleLogin = 1 - loginAnimController.value;

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Theme.of(context).primaryColor, Colors.transparent],
                )
              ),
              child: images[imageIndex],
            )
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.075),
          Padding(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Log In', style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.075),
          Padding(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextFormField(
                textDirection: TextDirection.ltr,
                decoration: inputFieldWithErrorMessage('Email Address', loginEmailErrorText, context),
                style: Theme.of(context).textTheme.bodyMedium,
                controller: loginEmailTC,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.075),
          Padding(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextFormField(
                textDirection: TextDirection.ltr,
                decoration: inputFieldWithErrorMessage('Password', loginPassErrorText, context),
                style: Theme.of(context).textTheme.bodyMedium,
                controller: loginPassTC,
                obscureText: true,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.075),
          Padding(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05),
            child: GestureDetector(
              onTapDown: (details) => loginAnimController.forward(),
              onTapUp: (details) => loginAnimController.reverse(),
              onTapCancel: () => loginAnimController.reverse(),
              onTap: () {
                validateLoginInputs(context, setState);
              },
              child: Transform.scale(
                scale: _scaleLogin,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey.shade900,
                  ),
                  child: Center(
                    child: Text('Login', style: Theme.of(context).textTheme.labelLarge),
                  )
                ),
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              openRegistrationTab(context);
            },
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              child: Text('Don\'t have an account? Click here!', style: Theme.of(context).textTheme.labelMedium),
            )
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: loggedIn,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //If loggedIn, go to CoreView
          //If not loggedIn, show login screen

          if (snapshot.data) {
            Future.delayed(const Duration(milliseconds: 500), () {
              goToMainView(context);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          else {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: login(),
            );
          }
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: splash(),
          );
        }
        else {
          return Scaffold(
            body: error(),
          );
        }
      }
    );
  }
}
