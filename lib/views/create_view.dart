import 'package:flutter/material.dart';
import 'package:ui_build_experiment/views/navbar.dart';

class CreateView extends StatefulWidget {
  const CreateView({super.key,});

  @override
  State<CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> {

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
        child: Column(
            children: [
              Text('Create View', style: Theme.of(context).textTheme.titleLarge),
              Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
              Text('Title Medium', style: Theme.of(context).textTheme.titleMedium),
              Text('Title Small', style: Theme.of(context).textTheme.titleSmall),
              Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
              Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
              Text('Body Small', style: Theme.of(context).textTheme.bodySmall),
            ]
        )
    );
  }
}


/**TODO
 * _______________
 *
 */