import 'package:flutter/material.dart';
import 'package:ui_build_experiment/views/registration.dart';
import 'package:ui_build_experiment/views/splash.dart';

import '../../views/core_view.dart';

void goToRegistration(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Registration()),
  );
}

void goToMainView(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const CoreView()),
  );
}

void goToLogin(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const Splash()),
  );
}