import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui_build_experiment/styling/input.dart';
import 'package:ui_build_experiment/tools.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../styling/colours.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> with TickerProviderStateMixin {

  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController password2TextController = TextEditingController();

  String emailErrorText = '';
  String passwordErrorText = '';
  String password2ErrorText = '';

  String registrationErrorMessage = '';

  late double _scaleButton;
  late AnimationController _buttonAnimController;

  late RegistrationStep step;

  void resetTextFields() {
    emailTextController.clear();
    passwordTextController.clear();
    password2TextController.clear();
  }

  void resetErrors() {
    emailErrorText = '';
    passwordErrorText = '';
    password2ErrorText = '';
    registrationErrorMessage = '';
  }

  void initAnimation() {
    _buttonAnimController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
  }

  Future<void> validateRegistration() async {
    resetErrors();

    //Validate each form field
    if (emailTextController.text.isEmpty) {
      emailErrorText = 'Email Address is mandatory!';
    }
    if (passwordTextController.text.length < 8) {
      passwordErrorText = 'Password must be atleast 8 characters!';
    }
    if (password2TextController.text.length < 8) {
      password2ErrorText = 'Password must be atleast 8 characters!';
    }
    if (passwordTextController.text.isEmpty) {
      passwordErrorText = 'Password is mandatory!';
    }
    if (password2TextController.text.isEmpty) {
      password2ErrorText = 'Password confirmation is mandatory!';
    }
    if (passwordTextController.text.isNotEmpty && password2TextController.text.isNotEmpty && passwordTextController.text != password2TextController.text) {
      passwordErrorText = 'Passwords must match!';
      password2ErrorText = 'Passwords must match!';
    }
    if (!isEmailValid(emailTextController.text) && emailTextController.text.isNotEmpty) {
      emailErrorText = 'Valid email address is mandatory!';
    }

    if (emailErrorText != '' || passwordErrorText != '' || password2ErrorText != '') {
      setState((){});
      return;
    }

    //We are validated, so swap to the loading widget
    setState(() {
      step = RegistrationStep.loading;
    });

    //Attempt to create the Firebase Auth user
    bool createdFBA = await createFirebaseAuthUser();
    if (!createdFBA) {
      setState(() {
        step = RegistrationStep.form;
      });
    }

    //Successfully created, so create the Firestore entry for this user
    //bool createdFSU = await createFirestoreUser();
    //if (!createdFSU) {
    //  setState(() {
    //    step = RegistrationStep.form;
    //    registrationErrorMessage = 'An error occurred! Please try again.';
    //  });
    //}

    //Registration completed successfully, so move on to the success step
    setState(() {
      step = RegistrationStep.done;
    });
  }

  //Create the FirebaseAuthentication User
  Future<bool> createFirebaseAuthUser() async {
    bool success = false;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailTextController.text.trim(), password: passwordTextController.text.trim()).then((value) {
        success = true;
      });
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        registrationErrorMessage = 'This email address is already in use!';
      }
    }
    catch (e) {
      registrationErrorMessage = 'An error occurred! Please try again.';
    }

    return success;
  }

  //Create the Firestore User Document
  Future<bool> createFirestoreUser() async {
    bool success = false;

    try {

    }
    catch (e) {
      log('Failed to create User: $e');
    }

    return success;
}

  @override
  void initState() {
    super.initState();
    initAnimation();
    resetTextFields();
    resetErrors();
    step = RegistrationStep.form;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget modalHeader() {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Register', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05),
                onPressed: () {
                  Navigator.pop(context);
                }
              )
            ]
          ),
          Text('Create your account to create and manage your Dungeons and Dragons characters!', style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget registrationForm() {
    _scaleButton = 1 - _buttonAnimController.value;

    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          registrationErrorMessage.isNotEmpty?
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: buttonGradient,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(registrationErrorMessage, style: Theme.of(context).textTheme.labelMedium),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          registrationErrorMessage = '';
                        });
                      },
                      icon: Icon(Icons.close, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05),
                    )
                  ]
                )
              )
          :
              const SizedBox.shrink(),
          Text('Email Address', style: Theme.of(context).textTheme.labelLarge),
          TextFormField(
            decoration: inputFieldWithErrorMessage('Enter Email Address...', emailErrorText, context),
            keyboardType: TextInputType.emailAddress,
            controller: emailTextController,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text('Password', style: Theme.of(context).textTheme.labelLarge),
          TextFormField(
            decoration: inputFieldWithErrorMessage('Enter Password...', passwordErrorText, context),
            obscureText: true,
            controller: passwordTextController,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text('Confirm Password', style: Theme.of(context).textTheme.labelLarge),
          TextFormField(
            decoration: inputFieldWithErrorMessage('Confirm Password...', password2ErrorText, context),
            obscureText: true,
            controller: password2TextController,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          GestureDetector(
            onTapDown: (details) => _buttonAnimController.forward(),
            onTapUp: (details) => _buttonAnimController.reverse(),
            onTapCancel: () => _buttonAnimController.reverse(),
            onTap: () {
              validateRegistration();
            },
            child: Transform.scale(
              scale: _scaleButton,
              child: Container(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                decoration: BoxDecoration(
                  gradient: buttonGradient,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                    child: Text('Register', style: Theme.of(context).textTheme.titleSmall)
                )
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget loadingWidget() {
    return SizedBox(
      width: double.infinity, height: MediaQuery.of(context).size.height * 0.50,
      child: Center(
        child: SpinKitThreeBounce(
          size: MediaQuery.of(context).size.width * 0.15,
          color: Colors.blueAccent,
        )
      )
    );
  }

  Widget doneWidget() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); //Close the modal after a delay
    });

    return SizedBox(
      width: double.infinity, height: MediaQuery.of(context).size.height * 0.50,
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(Icons.account_circle_sharp, color: Colors.white, size: MediaQuery.of(context).size.width * 0.4,),
              Text('Account Created!', style: Theme.of(context).textTheme.titleMedium),
            ]
        ),
      )
    );
  }

  Widget bottomImage() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Theme.of(context).primaryColor, Colors.transparent],
              )
          ),
          child: Image.asset('assets/images/bg2.jpg', fit: BoxFit.cover),
        ),
      ],
    );
  }

  Widget displayedWidget() {
    switch (step) {
      case RegistrationStep.form:
        return registrationForm();
        break;
      case RegistrationStep.loading:
        return loadingWidget();
        break;
      case RegistrationStep.done:
        return doneWidget();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            modalHeader(),
            displayedWidget(),
            bottomImage(),
          ]
        )
      ),
    );
  }
}

//Enumerator controlling what is displayed on screen
enum RegistrationStep{
  form, loading, done
}


/*
TODO
____________

Registration still works even if there should be errors. wtaf.
 */