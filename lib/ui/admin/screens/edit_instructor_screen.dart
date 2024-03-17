import 'dart:io';
import 'package:fcg_admin_instructor/helpers/message_helper.dart';
import 'package:fcg_admin_instructor/providers/appointments_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../widgets/background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_text_field.dart';
import '../../../providers/instructors_provider.dart';
import '../../../providers/videos_provider.dart';
import '../../../models/instructor.dart';
import '../../../res/keys.dart';
import '../../../helpers/common_functions.dart';
import '../../../helpers/message_helper.dart';

enum SourceOfImage { Gallery, Camera, None }

class EditInstructorScreen extends StatefulWidget {
  final Instructor instructor;
  EditInstructorScreen(this.instructor);
  @override
  _EditInstructorScreenState createState() => _EditInstructorScreenState();
}

class _EditInstructorScreenState extends State<EditInstructorScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameCon, _priceCon, _infoCon;

  bool _isNewImgSelected;
  File image;
  bool _blockAccess;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Instructor _editedInstructor;

  @override
  void initState() {
    _nameCon = TextEditingController();
    _priceCon = TextEditingController();
    _infoCon = TextEditingController();
    _nameCon.text = widget.instructor.name;
    _priceCon.text = widget.instructor.price.toString();
    _infoCon.text = widget.instructor.information;
    _isNewImgSelected = false;
    _blockAccess = !widget.instructor.access;
    _editedInstructor = Instructor(
      uid: widget.instructor.uid,
      name: widget.instructor.name,
      email: widget.instructor.email,
      isInstructor: true,
      access: true,
      pictureUrl: widget.instructor.pictureUrl,
      information: widget.instructor.information,
      price: widget.instructor.price,
    );
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
                          onTap: () => Navigator.of(context).pop(),
                          child: CustomContainer(
                            containerWidth: mediaQueryHeight * 0.06,
                            containerHeight: mediaQueryHeight * 0.06,
                            heightSpecified: true,
                            buildBoundary: false,
                            child: Icon(
                              Icons.arrow_back_ios_sharp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'EDIT INSTRUCTOR',
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
                              height:
                                  CommonFunctions.textFieldHeight(context) * 2,
                            ),
                            SizedBox(height: 10),
                            CustomTextField(
                              validator: (String val) => val.isEmpty
                                  ? 'Price is required field.'
                                  : null,
                              icon: Icons.attach_money_sharp,
                              controller: _priceCon,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.04),
                            CustomStaticText(
                              text: 'Active Assignments',
                              trailingWidget: Text(
                                widget.instructor.totalActiveAssignments
                                    .toString(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            CustomStaticText(
                              text: 'Active Reassignments',
                              trailingWidget: Text(
                                widget.instructor.totalReassignments.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            CustomStaticText(
                              text: 'Completed Assignments',
                              trailingWidget: Text(
                                widget.instructor.totalCompleted.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.04),
                            CustomStaticText(
                              text: 'Block Access',
                              trailingWidget: Switch(
                                  activeColor: Colors.white,
                                  activeTrackColor: Colors.grey,
                                  inactiveThumbColor: Colors.black,
                                  inactiveTrackColor: Colors.grey,
                                  value: _blockAccess,
                                  onChanged: (value) =>
                                      setState(() => _blockAccess = value)),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.04),
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
                                    context, 'Updating instructor profile ...');
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
                                    showSnackBar('Error creating instructor');
                                    Navigator.of(context).pop();
                                    return null;
                                  }
                                  _editedInstructor.pictureUrl = imageUrl;
                                }
                                _editedInstructor.name = _nameCon.text;
                                _editedInstructor.email =
                                    widget.instructor.email;
                                _editedInstructor.uid = widget.instructor.uid;
                                _editedInstructor.access = !_blockAccess;
                                _editedInstructor.information = _infoCon.text;
                                _editedInstructor.price =
                                    double.parse(_priceCon.text);
                                _editedInstructor.totalActiveAssignments =
                                    widget.instructor.totalActiveAssignments;
                                _editedInstructor.totalCompleted =
                                    widget.instructor.totalCompleted;
                                _editedInstructor.totalReassignments =
                                    widget.instructor.totalReassignments;
                                _editedInstructor.totalRejected =
                                    widget.instructor.totalRejected;
                                await Provider.of<InstructorsProvider>(context,
                                        listen: false)
                                    .editInstructor(_editedInstructor);
                                Navigator.of(context)
                                    .pop(); //Popping the dialog box
                                Navigator.of(context).pop(true);
                              },
                            ),
                            SizedBox(height: 10),
                            CustomButton(
                                text: 'DELETE INSTRUCTOR',
                                onPress: () async {
                                  if (!await CommonFunctions.yesNoDialog(
                                      context,
                                      'Are you sure you want to delete ${widget.instructor.name}?'))
                                    return;
                                  CommonFunctions.showProgressDialog(
                                      context, 'Deleting instructor ...');

                                  await Provider.of<VideosProvider>(context,
                                          listen: false)
                                      .instructorWaitingVideosReturn(
                                          _editedInstructor);

                                  await MessageHelper.deleteUserChat(
                                      _editedInstructor.uid);

                                  MessageHelper.deletedInstructorsUids
                                      .add(widget.instructor.uid);

                                  await Provider.of<AppointmentsProvider>(
                                          context,
                                          listen: false)
                                      .deleteAllAppointments(
                                          _editedInstructor.uid);

                                  await Provider.of<InstructorsProvider>(
                                          context,
                                          listen: false)
                                      .deleteInstructor(_editedInstructor);
                                  /*
                                  await FirebaseAuth.instance.signOut();
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: widget.instructor.email,
                                          password: widget.instructor.password);
                                  await FirebaseAuth.instance
                                      .currentUser()
                                      .then((value) => value.delete());
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: StaticInfo.ADMIN_EMAIL,
                                          password: StaticInfo.ADMIN_PASSWORD);
                                  await Provider.of<InstructorsProvider>(
                                          context,
                                          listen: false)
                                      .deleteInstructor(_editedInstructor);*/
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                }),
                            SizedBox(height: 20),
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
                : ImageSource.camera,
        imageQuality: 40);

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
