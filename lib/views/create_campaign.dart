import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ui_build_experiment/controllers/shared/navigation.dart';
import 'package:ui_build_experiment/styling/input.dart';
import 'package:ui_build_experiment/tools.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../models/Campaign.dart';
import '../styling/colours.dart';

class CreateCampaign extends StatefulWidget {
  const CreateCampaign({super.key});

  @override
  State<CreateCampaign> createState() => _CreateCampaignState();
}

class _CreateCampaignState extends State<CreateCampaign> with TickerProviderStateMixin {
  //Int to hold which image is currently selected
  int selectedImage = 0;

  late double _scaleImage1;
  late double _scaleImage2;
  late double _scaleImage3;
  late double _scaleImage4;

  late double _scaleCreate;

  late AnimationController _animController1;
  late AnimationController _animController2;
  late AnimationController _animController3;
  late AnimationController _animController4;

  late AnimationController _animCreate;

  void animInit() {
    _animController1 = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
    _animController2 = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
    _animController3 = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
    _animController4 = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
    _animCreate = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.1
    )..addListener(() {setState((){});});
  }

  void animDispose() {
    _animController1.dispose();
    _animController2.dispose();
    _animController3.dispose();
    _animController4.dispose();
    _animCreate.dispose();
  }

  //Variables to handle user uploaded images
  late XFile uploadedImage;
  //Methods for retrieving and uploading images
  Future<void> getImageFromGallery() async {
    log('Calling');
    //Select an image from the gallery
    try {
      XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (picked == null) {
        return;
      }
      else {
        setState(() {
          uploadedImage = picked;
        });
      }
    }
    catch (e) {
      log('Error: $e');
    }
  }

  //Form TextControllers and Error Text
  TextEditingController campaignNameTC = TextEditingController();
  TextEditingController campaignDescriptionTC = TextEditingController();

  String nameErrorText = '';

  void resetErrors() {
    nameErrorText = '';
    uploadErrorText = '';
  }
  void clearTextFields() {
    campaignNameTC.clear();
    campaignDescriptionTC.clear();
  }

  //Form Validation
  String uploadErrorText = '';
  Future<void> validateCampaignForm() async {
    resetErrors();

    if (campaignNameTC.text.isEmpty) {
      setState(() {
        nameErrorText = 'Campaign Name is mandatory!';
      });
      return;
    }

    //Change the step
    setState(() {
      step = CampaignStep.loading;
    });

    //Create the campaign object to be uploaded
    Campaign? campaign = await createCampaignObject();
    if (campaign == null) {
      setState(() {
        uploadErrorText = 'Error creating Campaign!';
        step = CampaignStep.form;
      });
      return;
    }

    //Now upload the campaign object
    bool success = await uploadNewCampaign(campaign);
    if (!success) {
      setState(() {
        uploadErrorText = 'Error uploading campaign!';
        step = CampaignStep.form;
      });
      return;
    }

    //Successfully uploaded, so move on
    setState(() {
      step = CampaignStep.done;
    });
  }

  Future<Campaign?> createCampaignObject() async {
    String imageDownloadUrl = '';

    //Get a different url for the background based on selectedImage
    switch (selectedImage) {
      case 0:
        imageDownloadUrl = 'https://firebasestorage.googleapis.com/v0/b/dnd-npc-project.appspot.com/o/campaign_bgs%2Fdefault%2Fbg1.jpg?alt=media&token=8a5fd085-a3c8-44dc-accf-23954f7bedda';
        break;
      case 1:
        imageDownloadUrl = 'https://firebasestorage.googleapis.com/v0/b/dnd-npc-project.appspot.com/o/campaign_bgs%2Fdefault%2Fbg2.jpg?alt=media&token=1e81d10d-9024-4b0c-94f8-2fdbe2f9d034';
        break;
      case 2:
        imageDownloadUrl = 'https://firebasestorage.googleapis.com/v0/b/dnd-npc-project.appspot.com/o/campaign_bgs%2Fdefault%2Fbg3.jpg?alt=media&token=b93685aa-994e-4feb-8436-0671c95a57dd';
        break;
      case 3:
        imageDownloadUrl = await getDownloadUrl();
        break;
    }

    //If the DownloadURL is empty, return null
    if (imageDownloadUrl == '') {
      return null;
    }

    return Campaign(
      id: '',
      uid: FirebaseAuth.instance.currentUser!.uid,
      name: campaignNameTC.text.trim(),
      description: campaignDescriptionTC.text.trim(),
      displayImageUrl: imageDownloadUrl,
    );
  }

  Future<String> getDownloadUrl() async {
    //Create the file
    File imageFile = File(uploadedImage.path);

    //Get the storage reference
    Reference ref = FirebaseStorage.instance.ref('campaign_bgs').child('${FirebaseAuth.instance.currentUser!.uid}.jpg');

    //Attempt to upload the image
    try {
      await ref.putFile(imageFile);
    }
    catch (e) {
      log('Failed to upload the image: $e');
      return '';
    }

    //Get the download URL
    String downloadURL = '';
    try {
      downloadURL = await ref.getDownloadURL();
    }
    catch (e) {
      log('Failed to get downloadURL: $e');
      return '';
    }

    return downloadURL;
  }

  Future<bool> uploadNewCampaign(Campaign campaign) async {
    bool success = false;

    try {
      await FirebaseFirestore.instance.collection('campaign').doc().set(campaign.toJson()).then((value) {
        success = true;
      });
    }
    catch (e) {
      log('Failed to upload campaign: $e');
    }

    return success;
  }

  //Variable to hold which enumerator step we are on
  late CampaignStep step;

  @override
  void initState() {
    super.initState();
    step = CampaignStep.form;
    animInit();
    resetErrors();
    clearTextFields();
    selectedImage = 0;
    uploadedImage = XFile('');
  }

  @override
  void dispose() {
    super.dispose();
    animDispose();
  }

  Widget modalHeader() {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Create Campaign', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05),
                    onPressed: () {
                      Navigator.pop(context);
                    }
                )
              ]
          ),
          Text('Create a campaign to keep track of your characters and notes!', style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget campaignDetailsForm() {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name', style: Theme.of(context).textTheme.labelLarge),
            TextFormField(
              decoration: inputFieldWithErrorMessage('Enter a name for your campaign...', nameErrorText, context),
              controller: campaignNameTC,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text('Description', style: Theme.of(context).textTheme.labelLarge),
            TextFormField(
              decoration: inputFieldWithErrorMessage('Enter a description for your campaign...', '', context),
              controller: campaignDescriptionTC,
              style: Theme.of(context).textTheme.bodyMedium,
              minLines: 5,
              maxLines: 5,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text('Background', style: Theme.of(context).textTheme.labelLarge),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text('Select a background image for your campaign from the list, or upload your own.', style: Theme.of(context).textTheme.labelMedium,),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ]
        ),
      )
    );
  }

  Widget imageSelection() {
    _scaleImage1 = 1 - _animController1.value;
    _scaleImage2 = 1 - _animController2.value;
    _scaleImage3 = 1 - _animController3.value;
    _scaleImage4 = 1 - _animController4.value;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05),
      child: Column(
        children:[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTapDown: (details) => _animController1.forward(),
                onTapUp: (details) => _animController1.reverse(),
                onTapCancel: () => _animController1.reverse(),
                onTap: () {
                  setState(() {
                    selectedImage = 0;
                  });
                },
                child: Transform.scale(
                  scale: _scaleImage1,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4, height: MediaQuery.of(context).size.width * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: selectedImage == 0? Border.all(color: Colors.blue, width: 2) : null,
                      image: DecorationImage(
                        image: Image.asset('assets/images/bg1.jpg').image,
                        fit: BoxFit.cover,
                      )
                    )
                  ),
                ),
              ),
              GestureDetector(
                onTapDown: (details) => _animController2.forward(),
                onTapUp: (details) => _animController2.reverse(),
                onTapCancel: () => _animController2.reverse(),
                onTap: () {
                  setState(() {
                    selectedImage = 1;
                  });
                },
                child: Transform.scale(
                  scale: _scaleImage2,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.4, height: MediaQuery.of(context).size.width * 0.35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: selectedImage == 1? Border.all(color: Colors.blue, width: 2) : null,
                          image: DecorationImage(
                            image: Image.asset('assets/images/bg2.jpg').image,
                            fit: BoxFit.cover,
                          )
                      )
                  ),
                ),
              ),
            ]
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTapDown: (details) => _animController3.forward(),
                  onTapUp: (details) => _animController3.reverse(),
                  onTapCancel: () => _animController3.reverse(),
                  onTap: () {
                    setState(() {
                      selectedImage = 2;
                    });
                  },
                  child: Transform.scale(
                    scale: _scaleImage3,
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.4, height: MediaQuery.of(context).size.width * 0.35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: selectedImage == 2? Border.all(color: Colors.blue, width: 2) : null,
                            image: DecorationImage(
                              image: Image.asset('assets/images/bg3.jpg').image,
                              fit: BoxFit.cover,
                            )
                        )
                    ),
                  ),
                ),
                GestureDetector(
                  onTapDown: (details) => _animController4.forward(),
                  onTapUp: (details) => _animController4.reverse(),
                  onTapCancel: () => _animController4.reverse(),
                  onTap: () async {
                    await getImageFromGallery();

                    if (uploadedImage.path != '') {
                      setState(() {
                        selectedImage = 3;
                      });
                    }
                  },
                  child: Transform.scale(
                    scale: _scaleImage4,
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.4, height: MediaQuery.of(context).size.width * 0.35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: selectedImage == 3? Border.all(color: Colors.blue, width: 2) : null,
                            color: Colors.grey.shade700,
                            image: uploadedImage.path == ''?
                                null
                                :
                                DecorationImage(
                                  image: Image.file(File(uploadedImage.path)).image,
                                  fit: BoxFit.cover,
                                )
                        ),
                      child: uploadedImage.path == '' ?
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.white, size: MediaQuery.of(context).size.width * 0.1),
                              Text('Upload Image', style: Theme.of(context).textTheme.labelLarge),
                            ]
                          )
                          :
                          null,
                    ),
                  ),
                ),
              ]
          ),
        ]
      ),
    );
  }

  Widget completeCampaignButton() {
    _scaleCreate = 1 - _animCreate.value;

    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
      child: GestureDetector(
        onTapDown: (details) => _animCreate.forward(),
        onTapUp: (details) => _animCreate.reverse(),
        onTapCancel: () => _animCreate.reverse(),
        onTap: () {
          validateCampaignForm();
        },
        child: Transform.scale(
          scale: _scaleCreate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: buttonGradient,
              boxShadow: [containerShadow]
            ),
            child: Center(child: Text('Create', style: Theme.of(context).textTheme.labelLarge)),
          ),
        ),
      )
    );
  }

  Widget errorChecker() {
    if (uploadErrorText.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          decoration: BoxDecoration(
            gradient: buttonGradient,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Text(uploadErrorText, style: Theme.of(context).textTheme.bodyMedium),
              ),
              Flexible(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: MediaQuery.of(context).size.width * 0.05),
                  onPressed: () {
                    setState(() {
                      uploadErrorText = '';
                    });
                  }
                ),
              )
            ]
          )
        )
      );
    }
    else {
      return Container();
    }
  }

  Widget formStep() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          modalHeader(),
          campaignDetailsForm(),
          imageSelection(),
          errorChecker(),
          completeCampaignButton(),
        ]
    );
  }

  Widget loadingStep() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.2),
            child: Center(
              child: loadingWidget(context),
            )
          )
        ]
    );
  }

  Widget doneStep() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      goToMainView(context);
    });

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.2),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.campaign_rounded, color: Colors.white, size: MediaQuery.of(context).size.width * 0.2),
                    Text('Campaign Created!', style: Theme.of(context).textTheme.labelLarge),
                  ]
                )
              )
          )
        ]
    );
  }

  Widget viewSelector() {
    switch (step) {
      case CampaignStep.form:
        return formStep();
      case CampaignStep.loading:
        return loadingStep();
      case CampaignStep.done:
        return doneStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
            color: Theme.of(context).primaryColor,
            child: viewSelector(),
        ),
      ),
    );
  }
}

enum CampaignStep{
  form, loading, done,
}

/*
TODO
____________

Registration still works even if there should be errors. wtaf.
 */