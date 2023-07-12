import 'package:flutter/material.dart';

import '../tools.dart';

Widget newDrawer(BuildContext context) {
  return Drawer(
    width: MediaQuery.of(context).size.width * 0.65,
    backgroundColor: Theme.of(context).primaryColor,
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        DrawerHeader(
          padding: EdgeInsets.zero,
          child: Center(
            child: Container(
              width: double.infinity,
              foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [Theme.of(context).primaryColor, Colors.transparent],
                  )
              ),
              child: Image.asset('assets/images/bg2.jpg', fit: BoxFit.cover),
            ),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            logoutDialog(context);
          },
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sign Out', style: Theme.of(context).textTheme.labelLarge),
                Icon(Icons.logout, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05,),
              ]
            )
          )
        )
      ],
    ),
  );
}