import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ui_build_experiment/styling/colours.dart';

import 'controllers/shared/navigation.dart';

bool isEmailValid(String email) {
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}

void loadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
        child: SpinKitThreeBounce(
          size: MediaQuery.of(context).size.width * 0.05,
          color: Colors.blueAccent,
        )
    ),
  );
}

Widget loadingWidget(BuildContext context) {
  return SpinKitThreeBounce(
    size: MediaQuery.of(context).size.width * 0.05,
    color: Colors.blueAccent,
  );
}

void logoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
            width: double.infinity, height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(
              gradient: dialogGradient,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Logout', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text('Are you sure you want to logout?', style: Theme.of(context).textTheme.labelLarge),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                          child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge),
                        )
                      ),
                      InkWell(
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          goToLogin(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                          child: Text('Yes', style: Theme.of(context).textTheme.labelLarge),
                        )
                      )
                    ]
                  )
                ]
            )
        ),
      );
    }
  );
}

BoxShadow containerShadow = const BoxShadow(
  color: Colors.black38,
  offset: Offset(3, 3),
  blurRadius: 5,
  spreadRadius: 1,
);