import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ui_build_experiment/models/Location.dart';
import 'package:ui_build_experiment/styling/colours.dart';
import 'package:ui_build_experiment/styling/input.dart';
import 'package:ui_build_experiment/tools.dart';

import '../../models/Campaign.dart';

class LocationModal extends StatefulWidget {
  const LocationModal({super.key, required this.campaign});
  final Campaign campaign;

  @override
  State<LocationModal> createState() => _LocationModalState();
}

class _LocationModalState extends State<LocationModal> with TickerProviderStateMixin {
  late LocationModalState step;
  late Campaign campaign;

  //Location Retrieval and Search
  late Future<void> locationFuture;
  TextEditingController locationSearchController = TextEditingController();
  List<Location> locationListUnfiltered = [];

  Future<void> getLocationListData() async {
    try {
      await FirebaseFirestore.instance.collection('location').where('campaignID', isEqualTo: campaign.id).get().then((value) {
        for (var i in value.docs) {
          try {
            locationListUnfiltered.add(Location.getLocation(i));
          }
          catch (e) {
            log('Failed to get location: ${i.id}\nReason: $e');
          }
        }
      });
    }
    catch (e) {
      log('Failed to get location data: $e');
    }
  }

  //Variables for adding a location
  late String selectedLocation;
  List<DropdownMenuItem<String>> locationTypesList = [
    const DropdownMenuItem<String>(value: 'village', child: Text('Village',)),
    const DropdownMenuItem<String>(value: 'city', child: Text('City',)),
    const DropdownMenuItem<String>(value: 'cave', child: Text('Cave',)),
    const DropdownMenuItem<String>(value: 'dungeon', child: Text('Dungeon',)),
    const DropdownMenuItem<String>(value: 'fortress', child: Text('Fortress',)),
  ];
  TextEditingController locationNameController = TextEditingController();
  TextEditingController locationDescriptionController = TextEditingController();
  String locationNameError = '';
  String locationDescriptionError = '';
  String locationAddErrorMessage = '';
  void clearTextFields() {
    locationNameController.clear();
    locationDescriptionController.clear();
  }
  void clearErrors() {
    locationNameError = '';
    locationDescriptionError = '';
  }

  //Button Animations
  late double _scaleAdd;
  late AnimationController _addAnim;
  void initAnim() {
    _addAnim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
  }
  void disposeAnim() {
    _addAnim.dispose();
  }

  //Methods for Firebase
  void validateAddLocation() async {
    clearErrors();

    if (locationNameController.text.isEmpty) {
      locationNameError = 'Location name is mandatory!';
    }
    if (locationDescriptionController.text.isEmpty) {
      locationDescriptionError = 'Location description is mandatory!';
    }

    if (locationNameError != '' || locationDescriptionError != '') {
      setState((){});
      return;
    }

    //Validation was successful, so create the Location Object
    Location location = createLocation();

    //Now attempt to post the location to Firestore
    //Swap to loading state
    setState(() {
      step = LocationModalState.loading;
    });

    bool success = await addLocationToFirestore(location);
    if (!success) {
      setState(() {
        locationAddErrorMessage = 'An error occurred adding the location!';
        step = LocationModalState.add;
      });
    }

    //All done, so go back to the list
    setState(() {
      step = LocationModalState.done;
    });
  }

  Location createLocation() {
    return Location(
        id: '',
        name: locationNameController.text.trim(),
        description: locationDescriptionController.text.trim(),
        locationType: selectedLocation,
        notes: [],
        campaignID: campaign.id,
    );
  }

  Future<bool> addLocationToFirestore(Location location) async {
    bool success = false;

    try {
      await FirebaseFirestore.instance.collection('location').doc().set(location.toJson()).then((value) {
        success = true;
      });
    }
    catch (e) {
      log('Failed to add location: $e');
    }

    return success;
  }

  onSearchChanged() {
    searchResultsList();
  }

  searchResultsList() {
    //List<OutstandingKey> showResults = [];
//
    //if (outstandingKeysSearchTextController.text.isNotEmpty) {
    //  for (var i in outstandingKeysList) {
    //    var name = i.visitorName.toLowerCase();
    //    var keyName = i.keyTag.toLowerCase();
//
    //    if (name.contains(outstandingKeysSearchTextController.text.toLowerCase()) || keyName.contains(outstandingKeysSearchTextController.text.toLowerCase())) {
    //      showResults.add(i);
    //    }
    //  }
    //}
    //else {
    //  showResults = List.from(outstandingKeysList);
    //}
//
    //setState(() {
    //  outstandingKeysSearchResultsList = showResults;
    //});
  }

  //Swapping Steps
  void swapToAddLocation() {
    clearErrors();
    clearTextFields();
    setState(() {
      step = LocationModalState.add;
    });
  }
  void swapToLocationList() {
    //Retrieve the future for locations again to reset the list with the new addition
    locationListUnfiltered.clear();
    locationFuture = getLocationListData();
    setState(() {
      step = LocationModalState.list;
    });
  }

  @override
  void initState() {
    super.initState();
    initAnim();
    campaign = widget.campaign;
    locationFuture = getLocationListData();
    step = LocationModalState.list;
    selectedLocation = locationTypesList.first.value!;
    locationSearchController.addListener(onSearchChanged);
    clearTextFields();
    clearErrors();
  }

  @override
  void dispose() {
    super.dispose();
    disposeAnim();
  }


  Widget modalHeader() {
    String title = '';
    String description = '';

    switch (step) {
      case LocationModalState.list:
        title = 'Location List';
        description = 'Keep track of important locations you visit on your ${campaign.name} adventure, and keep notes to help you remember important information';
        break;
      case LocationModalState.add:
        title = 'Add Location';
        description = 'Add a new location to your ${campaign.name} adventure!';
        break;
      case LocationModalState.specific:
        title = '';
        description = '';
        break;
      case LocationModalState.loading:
        title = 'Working...';
        description = '';
      case LocationModalState.done:
        title = 'Success!';
        description = '';
    }

    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05),
                    onPressed: () {
                      Navigator.pop(context);
                    }
                )
              ]
          ),
          Text(description, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget locationList() {
    return SingleChildScrollView(
      child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  onTap: () {
                    swapToAddLocation();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Add New Location', style: Theme.of(context).textTheme.labelMedium,),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                          Icon(Icons.add, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05),
                        ]
                    ),
                  ),
                ),
                TextFormField(
                  decoration: inputFieldWithErrorMessage('Search for a location...', '', context),
                  controller: locationSearchController,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                FutureBuilder(
                  future: locationFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<Widget> widgets = [];

                      Widget locationIconWidget(Location location,) {

                        return Padding(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                          child: GestureDetector(
                            onTap: () {

                            },
                            child: Container(
                                width: double.infinity, height: MediaQuery.of(context).size.height * 0.15,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [containerShadow],
                                  image: DecorationImage(
                                    image: Image.asset(getBackdropImagePath(location.locationType)).image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaY: 2, sigmaX: 6),
                                    child: Padding(
                                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              location.name,
                                              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white, shadows: [containerShadow]),
                                              maxLines: 2, overflow: TextOverflow.ellipsis,
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                )
                            ),
                          ),
                        );
                      }

                      for (Location i in locationListUnfiltered) {
                        widgets.add(locationIconWidget(i));
                      }

                      return Column(
                        children: widgets,
                      );
                    }
                    else if (snapshot.connectionState == ConnectionState.waiting) {
                      return loadingWidget(context);
                    }
                    else {
                      return Center(
                        child: Text('An error occurred getting locations!', style: Theme.of(context).textTheme.labelMedium),
                      );
                    }
                  }
                )
              ]
          )
      ),
    );
  }

  Widget locationSpecific() {
    return Container();
  }

  String getBackdropImagePath(String which) {
    String path = '';

    switch (which) {
      case 'village':
        path = 'assets/images/village.jpg';
        break;
      case 'city':
        path = 'assets/images/city.jpg';
        break;
      case 'cave':
        path = 'assets/images/cave.jpg';
        break;
      case 'dungeon':
        path = 'assets/images/dungeon.webp';
        break;
      case 'fortress':
        path = 'assets/images/fortress.jpg';
        break;
    }

    return path;
  }

  Widget locationAdd() {
    String backdropImage = getBackdropImagePath(selectedLocation);

    _scaleAdd = 1 - _addAnim.value;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center, end: Alignment.bottomCenter,
                colors: [Theme.of(context).primaryColor, Colors.transparent],
              )
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset(backdropImage).image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name', style: Theme.of(context).textTheme.labelLarge),
              TextFormField(
                decoration: inputFieldWithErrorMessage('Enter location name...', locationNameError, context),
                controller: locationNameController,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text('Description', style: Theme.of(context).textTheme.labelLarge),
              TextFormField(
                decoration: inputFieldWithErrorMessage('Enter a description of the location...', locationDescriptionError, context),
                minLines: 5,
                maxLines: 5,
                controller: locationDescriptionController,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text('Location Type', style: Theme.of(context).textTheme.labelLarge),
              DropdownButtonFormField(
                items: locationTypesList,
                value: selectedLocation,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value!;
                  });
                },
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: inputFieldWithErrorMessage('Choose a location type...', '', context),
                dropdownColor: Colors.grey.shade600,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
              locationAddErrorMessage.isNotEmpty?
              Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: buttonGradient,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(locationAddErrorMessage, style: Theme.of(context).textTheme.labelMedium),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              locationAddErrorMessage = '';
                            });
                          },
                          icon: Icon(Icons.close, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05),
                        )
                      ]
                  )
              )
                  :
              const SizedBox.shrink(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
              Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                child: GestureDetector(
                  onTapDown: (details) => _addAnim.forward(),
                  onTapUp: (details) => _addAnim.reverse(),
                  onTapCancel: () => _addAnim.reverse(),
                  onTap: () {
                    validateAddLocation();
                  },
                  child: Transform.scale(
                    scale: _scaleAdd,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                      decoration: BoxDecoration(
                        gradient: buttonGradient,
                        boxShadow: [containerShadow],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text('Add Location', style: Theme.of(context).textTheme.labelLarge)
                      )
                    ),
                  ),
                )
              )
            ]
          )
        ),
      ],
    );
  }

  Widget locationLoading() {
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

  Widget locationDone() {
    Future.delayed(const Duration(seconds: 3), () {
      swapToLocationList();
    });

    return SizedBox(
      width: double.infinity, height: MediaQuery.of(context).size.height * 0.50,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.landscape, color: Colors.white, size: MediaQuery.of(context).size.width * 0.2),
            SizedBox(height: MediaQuery.of(context).size.width * 0.03),
            Text('Location Added!', style: Theme.of(context).textTheme.labelLarge),
          ]
        )
      )
    );
  }

  Widget stepSwitch() {
    switch (step) {
      case LocationModalState.list:
        return locationList();
      case LocationModalState.specific:
        return locationSpecific();
      case LocationModalState.add:
        return locationAdd();
      case LocationModalState.loading:
        return locationLoading();
      case LocationModalState.done:
        return locationDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
          color: Theme.of(context).primaryColor,
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                modalHeader(),
                Expanded(child: stepSwitch()),
              ]
          )
      ),
    );
  }
}

enum LocationModalState {
  list, specific, add, loading, done
}