import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../widgets/background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_text_field.dart';
import '../../../models/instructor.dart';
import '../../../res/keys.dart';
import '../../../res/static_info.dart';
import '../../../helpers/auth_helper.dart';
import '../../../helpers/common_functions.dart';
import '../../../providers/instructors_provider.dart';

enum SourceOfImage { Gallery, Camera, None }

class CreateInstructorScreen extends StatefulWidget {
  @override
  _CreateInstructorScreenState createState() => _CreateInstructorScreenState();
}

class _CreateInstructorScreenState extends State<CreateInstructorScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameCon,
      _emailCon,
      _passwordCon,
      _confrirmCon,
      _infoCon,
      _priceCon;
  bool _isImgSelected;
  File image;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _nameCon = TextEditingController();
    _emailCon = TextEditingController();
    _passwordCon = TextEditingController();
    _confrirmCon = TextEditingController();
    _infoCon = TextEditingController();
    _priceCon = TextEditingController();

    _isImgSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    String _passwordText;
    double mediaQueryHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Background(),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  //Top app bar
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.03,
                    right: MediaQuery.of(context).size.width * 0.03,
                  ),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: CustomContainer(
                            containerWidth: mediaQueryHeight * 0.06,
                            containerHeight: mediaQueryHeight * 0.06,
                            heightSpecified: true,
                            buildBoundary: false,
                            child: Container(
                              child: Icon(
                                Icons.arrow_back_ios_sharp,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'NEW INSTRUCTOR',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Container(),
                          onPressed: null,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: _onSelectImg,
                              child: CustomContainer(
                                containerWidth: mediaQueryHeight * 0.18,
                                containerHeight: mediaQueryHeight * 0.18,
                                heightSpecified: true,
                                buildBoundary: false,
                                child: Center(
                                  child: _isImgSelected
                                      ? ClipRRect(
                                          child: Image.file(image,
                                              fit: BoxFit.cover),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            SizedBox(height: 10),
                                            Icon(
                                              Icons.add,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            Text(
                                              "Picture",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                            CustomTextField(
                              hint: 'Name',
                              validator: (String val) =>
                                  val.isEmpty ? 'Enter name' : null,
                              icon: Icons.person,
                              controller: _nameCon,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                            CustomTextField(
                              hint: 'Email',
                              controller: _emailCon,
                              validator: (String val) =>
                                  val.isEmpty ? 'Enter email' : null,
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                            CustomTextField(
                              hint: 'Information',
                              validator: (String val) =>
                                  val.isEmpty ? 'Enter information' : null,
                              icon: Icons.perm_device_information_sharp,
                              controller: _infoCon,
                              minLines: 3,
                              maxLines: 3,
                              height: CommonFunctions.textFieldHeight(context) * 2,
                              keyboardType: TextInputType.multiline,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                            CustomTextField(
                              hint: 'Price per 30 mins',
                              controller: _priceCon,
                              validator: (String val) => val.isEmpty
                                  ? 'Enter price per 30 mins.'
                                  : null,
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                            CustomTextField(
                              hint: 'Password',
                              controller: _passwordCon,
                              icon: Icons.vpn_key,
                              validator: (String val) {
                                _passwordText = _passwordCon.text.trim();
                                if (val.isEmpty)
                                  return 'Enter password';
                                else if (val.length < 6)
                                  return 'Password must be atleast 6 characters long';
                                return null;
                              },
                              obscure: true,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                            CustomTextField(
                              hint: 'Confirm Password',
                              icon: Icons.vpn_key,
                              controller: _confrirmCon,
                              validator: (String val) {
                                if (val.isEmpty)
                                  return 'Re-enter your password';
                                else if (val != _passwordText)
                                  return 'Password does not match';
                                return null;
                              },
                              obscure: true,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            CustomButton(
                              text: 'CREATE',
                              onPress: () async {
                                FocusScope.of(context).requestFocus();
                                if (!_isImgSelected) {
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Profile picture is required.',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      backgroundColor: Colors.white38,
                                    ),
                                  );
                                  return null;
                                }
                                _formKey.currentState.validate();

                                final isValid =
                                    _formKey.currentState.validate();
                                if (!isValid) return null;

                                _formKey.currentState.save();

                                CommonFunctions.showProgressDialog(
                                    context, 'Creating instructor ...');
                                    
                                var result = await AuthHelper().signUpByAdmin(
                                  email: _emailCon.text.trim(),
                                  password: _passwordCon.text.trim(),
                                );

                                if (result != null) {
                                  showSnackBar(
                                      'Error creating instructor. ${AuthErrors.ERROR_INVALID_EMAIL}');
                                  Navigator.of(context)
                                      .pop(); //Popping the dialog box
                                  return null;
                                }

                                var imgUpload = FirebaseStorage.instance
                                    .ref()
                                    .child(Keys.profilePictures)
                                    .child(StaticInfo.LastSignedUpInstructor)
                                    .putFile(image);

                                var imageUrl =
                                    await (await imgUpload.onComplete)
                                        .ref
                                        .getDownloadURL();

                                if (imageUrl == null) {
                                  showSnackBar('Error creating instructor');
                                  Navigator.of(context).pop();
                                  return null;
                                }

                                await Provider.of<InstructorsProvider>(context,
                                        listen: false)
                                    .createNewInstructor(
                                  Instructor(
                                    uid: StaticInfo.LastSignedUpInstructor,
                                    name: _nameCon.text.trim(),
                                    email: _emailCon.text.trim(),
                                    isInstructor: true,
                                    access: true,
                                    pictureUrl: imageUrl,
                                    information: _infoCon.text.trim(),
                                    price: double.parse(_priceCon.text.trim()),
                                  ),
                                );

                                Navigator.of(context).pop();
                                if (result == null) {
                                  showSnackBar(
                                      'Instructor created successfully.');
                                  Navigator.of(context).pop(true);
                                }
                                if (result != null && result.isNotEmpty)
                                  showSnackBar(result);
                              },
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _onSelectImg() async {
    SourceOfImage selectedImgSource = SourceOfImage.None;
    await showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                'Select image source',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        selectedImgSource = SourceOfImage.Camera;
                        Navigator.of(ctx).pop();
                      },
                      color: Colors.white38,
                      child: Text('Camera',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    FlatButton(
                      onPressed: () {
                        selectedImgSource = SourceOfImage.Gallery;
                        Navigator.of(ctx).pop();
                      },
                      color: Colors.white38,
                      child: Text('Gallery',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ));

    if (selectedImgSource == SourceOfImage.None) return;

    var rawImg = await ImagePicker.pickImage(
        source: selectedImgSource == SourceOfImage.None
            ? null
            : selectedImgSource == SourceOfImage.Gallery
                ? ImageSource.gallery
                : ImageSource.camera,
        imageQuality: 40);

    if (rawImg != null) {
      var cropped = await ImageCropper.cropImage(
        sourcePath: rawImg.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      if (cropped != null)
        setState(() {
          _isImgSelected = true;
          image = cropped;
        });
    }
  }

  showSnackBar(String a) {
    SnackBar snackBar = SnackBar(
      content: Text(a),
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  showAlertDialog(BuildContext context, String title) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(title),
            content: Container(
              height: MediaQuery.of(context).size.height / 15,
              width: MediaQuery.of(context).size.width / 10,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.black,
                  ),
                ),
              ),
            ),
          );
        });
  }
}
