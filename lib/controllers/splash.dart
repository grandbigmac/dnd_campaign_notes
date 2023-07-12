import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui_build_experiment/tools.dart';
import 'package:ui_build_experiment/views/splash.dart';

import '../views/registration.dart';
import 'shared/navigation.dart';

Future<bool> checkIfLoggedIn(BuildContext context) async {
  String uId = '';

  try {
    uId = FirebaseAuth.instance.currentUser!.uid;
  }
  catch (e) {
    return false;
  }

  return true;
}


//Control images shown at the top of the page
late final Timer timer;
bool timerInit = false;
int imageIndex = 0;

//Array containing the images displayed above the login form
List<Image> images = [
  Image.asset('assets/images/bg1.jpg', fit: BoxFit.cover), Image.asset('assets/images/bg2.jpg', fit: BoxFit.cover), Image.asset('assets/images/bg3.jpg', fit: BoxFit.cover),
];


//Login Handling Code
TextEditingController loginEmailTC = TextEditingController();
TextEditingController loginPassTC = TextEditingController();

String loginEmailErrorText = '';
String loginPassErrorText = '';

void resetFields() {
  loginEmailTC.clear();
  loginPassTC.clear();
}

void resetErrors() {
  loginEmailErrorText = '';
  loginPassErrorText = '';
}

Future<void> validateLoginInputs(BuildContext context, StateSetter setState) async {
  resetErrors();

  if (loginEmailTC.text.isEmpty && loginPassTC.text.isEmpty) {
    setState(() {
      loginEmailErrorText = 'Email address is required';
      loginPassErrorText = 'Password is required';
    });
    return;
  }
  else if (loginEmailTC.text.isEmpty) {
    setState(() {
      loginEmailErrorText = 'Email address is required';
    });
    return;

  }
  else if (loginPassTC.text.isEmpty) {
    setState(() {
      loginPassErrorText = 'Password is required';
    });
    return;
  }

  //Start loading dialog
  loadingDialog(context);

  //Validation is successful, now try to login
  bool loggedIn = await attemptLogin(setState);

  //Close the loading dialog
  Navigator.pop(context);

  //Successfully logged in, so go to the core view
  goToMainView(context);
}

Future<bool> attemptLogin(StateSetter setState) async {
  bool success = false;

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: loginEmailTC.text.trim(), password: loginPassTC.text.trim()).then((value) {
      success = true;
    });
  }
  on FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      setState(() {
        loginPassErrorText = 'Incorrect password';
      });
    }
    else if (e.code == 'invalid-email') {
      setState(() {
        loginEmailErrorText = 'Invalid email address';
      });
    }
    else if (e.code == 'user-not-found') {
      setState(() {
        loginEmailErrorText = 'No user found with this email';
      });
    }
  }
  catch (e) {
    log('Failed to login: $e');
  }

  return success;
}

//Open Registration into a modal bottom sheet
void openRegistrationTab(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    builder: (BuildContext context) {
      return const Registration();
    }
  );
}