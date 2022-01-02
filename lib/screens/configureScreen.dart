import 'package:cmseduc/screens/mainScreen.dart';
import 'package:cmseduc/screens/textFieldScreens/addOrChangeResources.dart';
import 'package:cmseduc/screens/textFieldScreens/manageUsers.dart';
import 'package:cmseduc/utils/firebaseData.dart';
import 'package:flutter/material.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:get/route_manager.dart';

class ConfigureScreen extends StatefulWidget {
  final String whichScreen;
  final Map resources;
  // final Map users;
  const ConfigureScreen({
    Key? key,
    required this.whichScreen,
    required this.resources,
    // required this.users
  }) : super(key: key);

  @override
  _ConfigureScreenState createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends State<ConfigureScreen> {
  List _documentsList = [];
  bool _isDocumentsLoaded = false;

  Map _updatedBy = {};
  Map _updatedOn = {};

  @override
  void initState() {
    _loadMaterial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
          title: Text(
            widget.whichScreen == "Resources"
                ? widget.resources["subject"]
                : "Users",
            overflow: TextOverflow.ellipsis,
            style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: Get.isDarkMode ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isDocumentsLoaded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                    Padding(padding: EdgeInsets.all(5.0)),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(pageBuilder:
                                    (BuildContext context, animation1,
                                        animation2) {
                                  return widget.whichScreen == "Resources"
                                      ? AddOrChangeResources(
                                          addOrChange: "Add",
                                          semester:
                                              widget.resources["semester"],
                                          subject: widget.resources["subject"],
                                          course: widget.resources["course"],
                                          materialType:
                                              widget.resources["materialType"],
                                          changeMaterial: "none",
                                        )
                                      : ManageUsers(
                                          addOrChange: "Add",
                                          previousUserName: "none");
                                }, transitionsBuilder: transitionEffectForNavigator()));
                          },
                          child: Container(
                            height: 100.0,
                            width: 100.0,
                            color:
                                Get.isDarkMode ? offBlackColor : offWhiteColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_box_outlined,
                                  color: selectedIconColor,
                                  size: 50.0,
                                ),
                                Center(
                                    child: Text(
                                  "Add New",
                                  style: TextStyle(fontSize: 12.0),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    widget.whichScreen == "Resources"
                        ? lightTextWidget(
                            "Current ${widget.resources["materialType"]} List")
                        : lightTextWidget("Current Users List"),
                        Padding(padding: EdgeInsets.all(5.0)),
                    Expanded(
                      child: RefreshIndicator(
                          onRefresh: _loadMaterial,
                          child: _fullWidthListViewBuilder(
                              context, _documentsList)),
                    )
                  ])
            : Center(
                child: CircularProgressIndicator(
                  color: selectedIconColor,
                  strokeWidth: 4,
                ),
              ));
  }

  Future<void> _loadMaterial() async {
    try {
      if (widget.whichScreen == "Resources") {
        _documentsList = [];
        List documentData = await FirebaseData().materialData(
            context,
            "none",
            "none",
            widget.resources["course"],
            widget.resources["materialType"],
            widget.resources["subject"],
            widget.resources["semester"],
            "none",
            "none");

        for (var item in documentData) {
          _documentsList.add(item["name"]);
          _updatedBy[item["name"]] = item["updatedBy"];
          _updatedOn[item["name"]] = item["updatedOn"];
        }
        setState(() {
          _isDocumentsLoaded = true;
        });
      } else if (widget.whichScreen == "Manage Users") {
        _documentsList = [];
        _updatedOn ={};

        Map userData = await FirebaseData().allUsers();
        for (var user in userData.keys) {
          _documentsList.add(user);
          _updatedBy[user] = userData[user]["email"];
          if (userData[user]["isAdmin"]) {
            _updatedOn[user] = "Admin,";
          }
          if (userData[user]["courseAccess"]) {
            _updatedOn[user] = _updatedOn[user] + " CourseAccess";
          }
        }
        setState(() {
          _isDocumentsLoaded = true;
        });
      }
    } catch (e) {}
  }

  Widget _fullWidthListViewBuilder(dynamic context, List namesList) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: Container(
              child: ListView.builder(
                  itemCount: namesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _fullWidthRoundedRectangleWidget(
                          context, namesList[index]),
                    );
                  }),
            )));
  }

  Widget _fullWidthRoundedRectangleWidget(dynamic context, String title) {
    // double widthOfBox = ((MediaQuery.of(context).size.width));
    return InkWell(
      focusColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          color: Get.isDarkMode ? offBlackColor : offWhiteColor,
          child: SizedBox(
            height: 100.0,
            // width: widthOfBox,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                      child: Icon(
                    Icons.edit,
                    color: selectedIconColor,
                    size: 35.0,
                  )),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.whichScreen == "Resources"
                          ? "Last updated on ${_updatedOn[title]}"
                          // : "",
                          : "Email : ${_updatedBy[title]}", //for email
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? darkModeLightTextColor
                              : lightModeLightTextColor,
                          fontSize: 12),
                    ),
                    Text(
                      widget.whichScreen == "Resources"
                          ? "By ${_updatedBy[title]}"
                          // : "",
                          : "Roles : ${_updatedOn[title]}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? darkModeLightTextColor
                              : lightModeLightTextColor,
                          fontSize: 12),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (BuildContext context, animation1, animation2) {
              return widget.whichScreen == "Resources"
                  ? AddOrChangeResources(
                      addOrChange: "Change",
                      semester: widget.resources["semester"],
                      subject: widget.resources["subject"],
                      course: widget.resources["course"],
                      materialType: widget.resources["materialType"],
                      changeMaterial: title)
                  : ManageUsers(addOrChange: "Change", previousUserName: title);
            }, transitionsBuilder:transitionEffectForNavigator()));
      },
    );
  }
}