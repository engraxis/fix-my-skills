import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../screens/availability_screen_edit.dart';
import '../../../providers/instructors_provider.dart';
import '../../../models/instructor.dart';
import '../../../res/static_info.dart';
import '../../../res/keys.dart';
import '../../../helpers/common_functions.dart';
import '../../widgets/background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_text_field.dart';

enum SourceOfImage { Gallery, Camera, None }

class EditProfileScreen extends StatefulWidget {
  final Instructor instructor;
  EditProfileScreen(this.instructor);
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameCon, _infoCon, _priceCon;

  bool _isNewImgSelected;
  File image;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Instructor _editedInstructor = Instructor(
    uid: StaticInfo.currentUser.uid,
    name: StaticInfo.currentUser.name,
    email: StaticInfo.currentUser.email,
    isInstructor: StaticInfo.currentUser.isInstructor,
    access: StaticInfo.currentUser.access,
    pictureUrl: StaticInfo.currentUser.pictureUrl,
    availability: StaticInfo.currentUser.availability,
    isOffline: StaticInfo.currentUser.isOffline,
    price: StaticInfo.currentUser.price,
    information: StaticInfo.currentUser.information,
  );

  @override
  void initState() {
    _nameCon = TextEditingController();
    _infoCon = TextEditingController();
    _priceCon = TextEditingController();
    _nameCon.text = widget.instructor.name;
    _infoCon.text = widget.instructor.information;
    _priceCon.text = widget.instructor.price.toString();
    _isNewImgSelected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                            'EDIT PROFILE',
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
                              onTap: _onSelectNewImg,
                              child: CustomContainer(
                                containerWidth: mediaQueryHeight * 0.18,
                                containerHeight: mediaQueryHeight * 0.18,
                                heightSpecified: true,
                                buildBoundary: false,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: _onSelectNewImg,
                                    child: ClipRRect(
                                      child: _isNewImgSelected
                                          ? Image.file(
                                              image,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              widget.instructor.pictureUrl,
                                              fit: BoxFit.cover),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            CustomTextField(
                              validator: (String val) {
                                if (val.isEmpty)
                                  return 'Name is required field.';
                                return null;
                              },
                              icon: Icons.person,
                              controller: _nameCon,
                            ),
                            SizedBox(height: 10),
                            CustomStaticText(
                              text: widget.instructor.email,
                              icon: Icon(
                                Icons.email,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 10),
                            CustomTextField(
                              validator: (String val) {
                                if (val.isEmpty)
                                  return 'Information is required field.';
                                return null;
                              },
                              icon: Icons.perm_device_information_sharp,
                              controller: _infoCon,
                              minLines: 3,
                              maxLines: 3,
                              height: CommonFunctions.textFieldHeight(context) * 2,
                            ),
                            SizedBox(height: 10),
                            CustomTextField(
                              validator: (String val) {
                                if (val.isEmpty)
                                  return 'Price is required field.';
                                return null;
                              },
                              icon: Icons.attach_money_outlined,
                              controller: _priceCon,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.055),
                            CustomButton(
                              text: 'Update Time Table',
                              onPress: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          AvailabilityScreenEdit())),
                            ),
                            SizedBox(height: 10),
                            CustomButton(
                              text: 'UPDATE',
                              onPress: () async {
                                FocusScope.of(context).requestFocus();

                                _formKey.currentState.validate();

                                final isValid =
                                    _formKey.currentState.validate();
                                if (!isValid) return null;

                                _formKey.currentState.save();
                                CommonFunctions.showProgressDialog(
                                    context, 'Updating your profile ...');
                                if (!_isNewImgSelected)
                                  _editedInstructor.pictureUrl =
                                      widget.instructor.pictureUrl;
                                else {
                                  var imgUpload = FirebaseStorage.instance
                                      .ref()
                                      .child(Keys.profilePictures)
                                      .child(widget.instructor.uid)
                                      .putFile(image);
                                  var imageUrl =
                                      await (await imgUpload.onComplete)
                                          .ref
                                          .getDownloadURL();
                                  if (imageUrl == null) {
                                    showSnackBar(
                                        'Error updating profile. Try again.');
                                    Navigator.of(context).pop(false);
                                    return null;
                                  }
                                  _editedInstructor.pictureUrl = imageUrl;
                                }
                                _editedInstructor.name = _nameCon.text;
                                _editedInstructor.information = _infoCon.text;
                                _editedInstructor.price = double.parse(_priceCon.text);
                                await Provider.of<InstructorsProvider>(context,
                                        listen: false)
                                    .updateProfile(_editedInstructor);
                                Navigator.of(context)
                                    .pop(); //Popping the dialog box
                                Navigator.of(context).pop();
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

  _onSelectNewImg() async {
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

    var rawImg = await ImagePicker.pickImage(
        source: selectedImgSource == SourceOfImage.None
            ? null
            : selectedImgSource == SourceOfImage.Gallery
                ? ImageSource.gallery
                : ImageSource.camera);

    if (rawImg != null) {
      var cropped = await ImageCropper.cropImage(
        sourcePath: rawImg.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      if (cropped != null)
        setState(() {
          _isNewImgSelected = true;
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
}

class CustomStaticText extends StatelessWidget {
  final String text;
  final Icon icon;
  final Widget trailingWidget;

  CustomStaticText({
    @required this.text,
    this.icon,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: CommonFunctions.textFieldHeight(context),
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(width: 15),
          icon == null
              ? Container()
              : Icon(Icons.email, color: Theme.of(context).primaryColor),
          icon == null ? SizedBox(width: 0) : SizedBox(width: 15),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          Spacer(),
          trailingWidget ?? Container(),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}
