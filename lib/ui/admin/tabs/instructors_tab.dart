import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/create_instructor_screen.dart';
import '../screens/edit_instructor_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_title.dart';
import '../../../models/instructor.dart';
import '../../../providers/instructors_provider.dart';

class InstructorsTab extends StatefulWidget {
  @override
  _InstructorsTabState createState() => _InstructorsTabState();
}

class _InstructorsTabState extends State<InstructorsTab> {
  List<Instructor> _instructorsList;
  bool _isRunningOnce;

  @override
  void initState() {
    _instructorsList = [];
    _instructorsList.clear();
    _isRunningOnce = true;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isRunningOnce) {
      _isRunningOnce = false;
      if (InstructorsProvider.instructorsLoading)
        Provider.of<InstructorsProvider>(context)
            .fetchInstructorsList(showAll: true);
      InstructorsProvider.instructorsLoading = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    _instructorsList.clear();
    _instructorsList.addAll(
        Provider.of<InstructorsProvider>(context, listen: true)
            .instructorsList);
            _instructorsList.sort((a,b) => a.name.compareTo(b.name));
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: mediaQuery.width * 0.05,
          right: mediaQuery.width * 0.05,
          top: mediaQuery.height * 0.03,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CustomTitle(
              showLeading: false,
              title: 'INSTRUCTORS',
              size: Size(
                mediaQuery.width,
                mediaQuery.height * 0.05,
              ),
            ),
            SizedBox(height: mediaQuery.height * 0.03),
            CustomButton(
                text: 'Create Instructor',
                onPress: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (ctx) => CreateInstructorScreen()))
                      .then((value) => setState(() {
                            if (value) {
                              showSnackBar('Instructor successfully added.');
                              Provider.of<InstructorsProvider>(context,
                                      listen: false)
                                  .instructorsList;
                            }
                          }));
                }),
            SizedBox(height: mediaQuery.height * 0.03),
            Expanded(
              child: _instructorsList.isEmpty
                  ? Container()
                  : ListView.separated(
                      itemBuilder: (ctx, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).accentColor,
                          ),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => EditInstructorScreen(
                                    _instructorsList[index]),
                              ),
                            ),
                            child: ListTile(
                              isThreeLine: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              leading: CircleAvatar(
                                child: ClipOval(
                                  child: Image.network(
                                      _instructorsList[index].pictureUrl),
                                ),
                                radius: 20,
                              ),
                              title: Text(
                                _instructorsList[index].name,
                                style: TextStyle(
                                  color: _instructorsList[index].access
                                      ? Theme.of(context).primaryColor
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.025,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (ctx, index) {
                        return SizedBox(height: 10);
                      },
                      itemCount: _instructorsList.length),
            ),
          ],
        ),
      ),
    );
  }

  showSnackBar(String a) {
    SnackBar snackBar = SnackBar(
      content: Text(a),
      duration: Duration(seconds: 3),
    );
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
