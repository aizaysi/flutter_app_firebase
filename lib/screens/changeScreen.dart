import 'package:cmseduc/screens/addOrChangeCourse.dart';
import 'package:cmseduc/screens/addOrChangeResources.dart';
import 'package:cmseduc/screens/documentScreen.dart';
import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';

class ChangeScreen extends StatefulWidget {
  final String changeItem;
  const ChangeScreen({Key? key, required this.changeItem}) : super(key: key);

  @override
  _ChangeScreenState createState() => _ChangeScreenState();
}

class _ChangeScreenState extends State<ChangeScreen> {
  bool _isLoading = true;
  Map _uploadedAtAndBy = {};
  List _courseList = [];

  //for resources
  List _materialList = [];
  List _subjectList = [];
  List _semesterList = [1, 2, 3, 4, 5, 6];
  List _documentsList = [];

  Map _resourcesItemMap = {
    "Course": "none",
    "Material": "none",
    "Semester": "none"
  };

  bool _isEverythingSelected = false;
  bool _subjectListLoaded = false;
  bool _isDocumentsLoaded = false;

  @override
  void initState() {
    loadInitialData();
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
            widget.changeItem,
            style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: Get.isDarkMode ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: selectedIconColor,
                  strokeWidth: 4.0,
                ),
              )
            : widget.changeItem == "Courses"
                ? configureCourse()
                : resourcesAddOrChange());
  }

  //for resources widget
  Widget resourcesAddOrChange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        _chooseItemWidget(_materialList, "Material"),
        _chooseItemWidget(_courseList, "Course"),
        _chooseItemWidget(_semesterList, "Semester"),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () {
                if (_resourcesItemMap.values.contains("none")) {
                  Fluttertoast.showToast(
                      msg: "Please select every field.",
                      toastLength: Toast.LENGTH_LONG);
                } else {
                  loadResourcesData();
                }
              },
              child: Text("Load Subjects"),
              style: ElevatedButton.styleFrom(primary: selectedIconColor),
            ),
          ),
        ),
        _lightTextWidget("Subjects"),
        Expanded(
          child: _isEverythingSelected
              ? _subjectListLoaded
                  ? fullWidthListViewBuilder(
                      context, _subjectList)
                  : CircularProgressIndicator(
                      color: selectedIconColor,
                      strokeWidth: 4.0,
                    )
              : Center(child: Text("No Subject Data")),
        )
      ],
    );
  }

  //for resources widget
  Widget _chooseItemWidget(List namesList, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lightTextWidget("Select $title"),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
          child: InkWell(
            onTap: () {
              showMaterialRadioPicker(
                context: context,
                items: namesList,
                selectedItem: _resourcesItemMap[title],
                title: title,
                onChanged: (value) {
                  _resourcesItemMap[title] = value.toString();
                  setState(() {});
                },
                maxLongSide: title == "Material"
                    ? 420
                    : title == "Semester"
                        ? 470
                        : 600,
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(8.0, 10.0, 5, 10),
                  color: Get.isDarkMode ? offBlackColor : offWhiteColor,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 0.0, 10.0, 0.0),
                        child:
                            Icon(Icons.list_rounded, color: selectedIconColor),
                      ),
                      Text(
                        _resourcesItemMap[title],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _lightTextWidget(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 0, 10.0),
      child: Text(
        title,
        style:
            Get.isDarkMode ? darkModeLightTextStyle : lightModeLightTextStyle,
      ),
    );
  }

  Widget configureCourse() {
    return Column(
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
                          (BuildContext context, animation1, animation2) {
                        return 
                             AddOrChangeCourse(
                                addOrChange: "Add New",
                                changeCourse: "none",
                              );
                      }, transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.linearToEaseOut;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      }));
                },
                child: Container(
                  height: 100.0,
                  width: 100.0,
                  color: Get.isDarkMode ? offBlackColor : offWhiteColor,
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
          _lightTextWidget("Current ourses List"),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadInitialData,
              child:  fullWidthListViewBuilder(
                      context, _courseList)
            ),
          )
        ]);
  }

  Future<void> loadInitialData() async {
    _courseList = await FirebaseData().courses();
    _materialList = await FirebaseData().materialType();

    if (widget.changeItem == "Courses") {
      for (var course in _courseList) {
        _uploadedAtAndBy[course] = await FirebaseData().uploadByAndAt(course);
      }
    }

    try {
      setState(() {
        _isLoading = false;
      });
    } catch (e) {}
  }

  Future<void> loadResourcesData() async {
    _subjectList = await FirebaseData().subjectsOfCourse(
        _resourcesItemMap["Course"], int.parse(_resourcesItemMap["Semester"]));

    if (_subjectList.isNotEmpty) {
      setState(() {
        _isEverythingSelected = true;
        _subjectListLoaded = true;
      });
    }
  }

  Widget fullWidthListViewBuilder(
      dynamic context, List namesList) {
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
                      child: fullWidthRoundedRectangleWidget(
                          context, namesList[index]),
                    );
                  }),
            )));
  }

  Widget fullWidthRoundedRectangleWidget(
      dynamic context, String title) {
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
                      widget.changeItem == "Courses"
                          ? "Uploaded on ${_uploadedAtAndBy[title][0]}."
                          : "Last updated on 21 December 2021",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? darkModeLightTextColor
                              : lightModeLightTextColor,
                          fontSize: 12),
                    ),
                    Text(
                      widget.changeItem == "Courses"
                          ? "By " + _uploadedAtAndBy[title][1]
                          : "By Yash",
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
              return widget.changeItem == "Courses"
                  ? AddOrChangeCourse(
                      addOrChange: "Change",
                      changeCourse: title,
                    )
                  : COnfigureResources(addOrChange: "", subject: "");
            }, transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.linearToEaseOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            }));
      },
    );
  }

}