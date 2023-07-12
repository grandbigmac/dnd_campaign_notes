import 'package:flutter/material.dart';

class MonsterModal extends StatefulWidget {
  const MonsterModal({super.key});

  @override
  State<MonsterModal> createState() => _MonsterModalState();
}

class _MonsterModalState extends State<MonsterModal> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

              ]
          )
      ),
    );
  }
}