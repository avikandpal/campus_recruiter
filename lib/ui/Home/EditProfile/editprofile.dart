import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geek_test/model/User.dart';
import 'package:flutter_geek_test/ui/upload_resume.dart';
import 'package:flutter_geek_test/network/ApiHandler.dart';
import 'package:flutter_geek_test/utils/constants/Appmessage.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/routing/route_list.dart';
import 'package:flutter_geek_test/utils/spacer/spacers.dart';
import 'package:flutter_geek_test/utils/utils.dart';

import '../../../network/apis.dart';

//Edit Profile Screen Widget
class EditProfileWidget extends StatefulWidget {
  @override
  _EditProfileWidgetState createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  final _formKey = GlobalKey<FormState>();
  User? user;

  //Focus Nodes
  final _nameFocusNode = FocusNode();
  final _rollNoFocusNode = FocusNode();
  final _fatherNameFocusNode = FocusNode();
  final _dateOfBirthFocusNode = FocusNode();

//  final _institutionNameFocusNode = FocusNode();
//  final _branchNameFocusNode = FocusNode();
//  final _qualificationFocusNode = FocusNode();
//  final _batchFocusNode = FocusNode();
  final _phoneNumberFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  //Text Editing Controller
  var _nameTextEditingController = TextEditingController();
  var _rollNoTextEditingController = TextEditingController();
  var _fatherNameTextEditingController = TextEditingController();
  var _dateOfBirthTextEditingController = TextEditingController();
  var _instituteNameTextEditingController = TextEditingController();
  var _branchNameTextEditingController = TextEditingController();
  var _qualificationTextEditingController = TextEditingController();
  var _batchTextEditingController = TextEditingController();
  var _phoneNumberTextEditingController = TextEditingController();
  var _emailTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  //MARK:- This method is used to get user profile info from the server.
  _getUserProfile() {
    checkInternet((value) {
      if (value) {
        showLoader(context, "");
        ApiHandler.get(ApiNames.profile, context, (response) {
          _setUserDataInModel(response["data"]);
        });
      } else {
        showAlert(context, AppMessage.noInternetMessage, () {
          Navigator.pop(context);
        }, isWarning: true);
      }
    });
  }

  //MARK:- This method is use to update user profile info to the server.
  _updateUserProfile() {
    _setUserModelAfterChanges();
    checkInternet((value) {
      if (value) {
        showLoader(context, "");
        ApiHandler.put(user?.toJson() ?? {}, ApiNames.profile, context,
            (response) {
          showAlert(context, response["message"], () {
            Navigator.pop(context);
          }, isWarning: false);
        });
      } else {
        showAlert(context, AppMessage.noInternetMessage, () {
          Navigator.pop(context);
        }, isWarning: true);
      }
    });
  }

  //MARK:- This method is used to set data in User model.
  _setUserDataInModel(Map<String, dynamic> data) {
    user = User.fromJson(data);
    _nameTextEditingController.text = user?.name ?? '';
    _rollNoTextEditingController.text = user?.rollNo ?? '';
    _fatherNameTextEditingController.text = user?.fatherName ?? '';
    var currentDate =
        Utils.convertDateFromString(user?.dob ?? '', "yyyy/MM/dd");
    _dateOfBirthTextEditingController.text =
        Utils.stringDateInFormat("dd/MM/yyyy", currentDate.toLocal());
    _instituteNameTextEditingController.text = user?.instituteName ?? '';
    _branchNameTextEditingController.text = user?.branch ?? '';
    _qualificationTextEditingController.text = user?.qualification ?? '';
    _batchTextEditingController.text = "${user?.batch ?? ''}";
    _phoneNumberTextEditingController.text = user?.phoneNo ?? '';
    _emailTextEditingController.text = user?.email ?? '';
  }

  _setUserModelAfterChanges() {
    user?.name = _nameTextEditingController.text;
    user?.rollNo = _rollNoTextEditingController.text;
    user?.fatherName = _fatherNameTextEditingController.text;
    var currentDate = Utils.convertDateFromString(
        _dateOfBirthTextEditingController.text, "dd/MM/yyyy");
    user?.dob = Utils.stringDateInFormat("yyyy/MM/dd", currentDate).toString();
    user?.instituteName = _instituteNameTextEditingController.text;
    user?.branch = _branchNameTextEditingController.text;
    user?.qualification = _qualificationTextEditingController.text;
    user?.batch = int.parse(_batchTextEditingController.text);
    user?.phoneNo = _phoneNumberTextEditingController.text;
    user?.email = _emailTextEditingController.text;
  }

  Future<bool> _onWillPop() async {
    bool val = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: <Widget>[
                Form(
                    key: _formKey,
                    child: Expanded(
                      child: ListView(
                        children: <Widget>[
                          Spacers.height10px,
                          _profileForm(),
                        ],
                      ),
                    )),
                Container(
                  child: Column(
                    children: <Widget>[
                      Spacers.height10px,
                      _editProfileActionButton(),
                      Spacers.height15px,
                      _skipButton(),
                      Spacers.height15px,
                    ],
                  ),
                )
              ],
            ),
          ),
        )),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: appThemeColor,
          centerTitle: true,
        ),
      ),
    );
  }

  Widget _profileForm() {
    return Column(
      children: <Widget>[
        _nameTextField(),
        Spacers.height20px,
        _rollNoTextField(),
        Spacers.height20px,
        _fatherNameTextField(),
        Spacers.height20px,
        _dateOfBirthTextField(),
        Spacers.height20px,
        _phoneNumberTextField(),
        Spacers.height20px,
        _emailTextField(),
        Spacers.height20px,
        _institutionNameTextField(),
        Spacers.height20px,
        _branchNameTextField(),
        Spacers.height20px,
        _qualificationTextField(),
        Spacers.height20px,
        _batchTextField(),
      ],
    );
  }

  Widget _editProfileActionButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: RoundedActionButton(
        title: "Update",
        fontSize: 18.0,
        onClick: () {
          if (_formKey.currentState?.validate() ?? false) {
            print("success");
            _updateUserProfile();
          }
        },
        padding: 50,
      ),
    );
  }

  Widget _skipButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: RoundedActionButton(
        title:"Accept & Proceed",
        fontSize: 18.0,
        onClick: () {
          showAlertWithTwoButton(
              context,
              "Once submitted you can't edit your details. Please verify your details and continue.",
              Icon(
                Icons.warning,
                color: Colors.amber,
                size: 50,
              ), () {
            Navigator.pushNamed(
              context,
              RouteList.uploadResume,
              arguments: UploadResumeScreenArguments(user, true),
            );
          }, () {
            Navigator.pop(context);
          }, cancelActionTitle: "Cancel", actionTitle: "Submit");
        },
        padding: 50,
      ),
    );
  }

  Widget _nameTextField() {
    return _formTextField("Name", "",
        validator: (value) {
          if (value == "") {
            return "Please enter name";
          } else {
            return null;
          }
        },
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z][a-zA-Z ]*')),
          LengthLimitingTextInputFormatter(25)
        ],
        keyboardType: TextInputType.text,
        focusNode: _nameFocusNode,
        onFieldSubmitted: (value) {
          _changeFieldFocus(
              currentFocus: _nameFocusNode, nextFocus: _rollNoFocusNode);
        },
        textEditingController: _nameTextEditingController);
  }

  Widget _emailTextField() {
    return _formTextField("Email ID", "",
        keyboardType: TextInputType.emailAddress, validator: (value) {
      return Utils.validateEmail(value);
    },
        focusNode: FocusNode(),
        onFieldSubmitted: (value) {},
        enabled: false,
        textEditingController: _emailTextEditingController);
  }

  Widget _rollNoTextField() {
    return _formTextField("Roll No.", "",
        validator: (value) {
          if (value == "") {
            return AppMessage.enterRollNo;
          }
          return null;
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(20)
        ],
        focusNode: _rollNoFocusNode,
        onFieldSubmitted: (value) {
          _changeFieldFocus(
              currentFocus: _rollNoFocusNode, nextFocus: _fatherNameFocusNode);
        },
        textEditingController: _rollNoTextEditingController);
  }

  Widget _fatherNameTextField() {
    return _formTextField("Father's Name", "",
        validator: (value) {
          if (value == "") {
            return AppMessage.enterFatherName;
          }
          return null;
        },
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z][a-zA-Z ]*')),
          LengthLimitingTextInputFormatter(25)
        ],
        focusNode: _fatherNameFocusNode,
        onFieldSubmitted: (value) {
          this._showDatePicker();
        },
        textEditingController: _fatherNameTextEditingController);
  }

  Widget _dateOfBirthTextField() {
    return InkWell(
      child: _formTextField("Date of Birth", "",
          validator: (value) {
            if (value == "") {
              return AppMessage.enterDateOfBirth;
            }
            return null;
          },
          focusNode: _dateOfBirthFocusNode,
          onFieldSubmitted: (value) {
            _changeFieldFocus(
                currentFocus: _dateOfBirthFocusNode,
                nextFocus: _phoneNumberFocusNode);
          },
          textEditingController: _dateOfBirthTextEditingController,
          enabled: false),
      onTap: () {
        this._showDatePicker();
      },
    );
  }

  Widget _institutionNameTextField() {
    return _formTextField("Institution Name", "", validator: (value) {
      if (value == "") {
        return AppMessage.enterInstitutionName;
      }
      return null;
    },
        focusNode: FocusNode(),
        onFieldSubmitted: (value) {},
        textEditingController: _instituteNameTextEditingController,
        enabled: false);
  }

  Widget _branchNameTextField() {
    return _formTextField("Branch Name", "", validator: (value) {
      if (value == "") {
        return AppMessage.enterBranchName;
      }
      return null;
    },
        focusNode: FocusNode(),
        onFieldSubmitted: (value) {},
        textEditingController: _branchNameTextEditingController,
        enabled: false);
  }

  Widget _qualificationTextField() {
    return _formTextField("Qualification", "", validator: (value) {
      if (value == "") {
        return AppMessage.enterQualification;
      }
      return null;
    },
        focusNode: FocusNode(),
        onFieldSubmitted: (value) {},
        textEditingController: _qualificationTextEditingController,
        enabled: false);
  }

  Widget _batchTextField() {
    return _formTextField("Batch", "", validator: (value) {
      if (value == "") {
        return AppMessage.enterBatchName;
      }
      return null;
    },
        focusNode: FocusNode(),
        onFieldSubmitted: (value) {},
        textEditingController: _batchTextEditingController,
        enabled: false);
  }

  Widget _phoneNumberTextField() {
    return _formTextField("Phone Number", "",
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value != null) {
            if (value == "") {
              return AppMessage.enterPhoneNumber;
            } else if (value.length < 6 || value.length > 15) {
              return 'Mobile Number must be of 6-15 digits.';
            }
          }
          return null;
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15)
        ],
        focusNode: _phoneNumberFocusNode,
        onFieldSubmitted: (value) {
          _changeFieldFocus(
              currentFocus: _phoneNumberFocusNode, nextFocus: _emailFocusNode);
        },
        textEditingController: _phoneNumberTextEditingController);
  }

  //change focus node
  void _changeFieldFocus({FocusNode? currentFocus, FocusNode? nextFocus}) {
    currentFocus?.unfocus();
    if (nextFocus != null) {
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }

  //Single TextField widget
  Widget _formTextField(
    String header,
    String value, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String? value)? validator,
    FocusNode? focusNode,
    ValueChanged<String>? onFieldSubmitted,
    bool? last,
    TextEditingController? textEditingController,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          header,
          style: TextStyle(
              color: (enabled ||
                      textEditingController ==
                          _dateOfBirthTextEditingController)
                  ? appThemeColor
                  : Colors.grey,
              fontWeight: FontWeight.w600),
        ),
        Theme(
          data: ThemeData(
            hintColor: lightGrayColor,
            disabledColor: Colors.grey,
          ),
          child: TextFormField(
            enabled: enabled,
            controller: textEditingController,
            focusNode: focusNode,
            validator: validator,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                errorText: null),
            style: TextStyle(
              color: (enabled ||
                      textEditingController ==
                          _dateOfBirthTextEditingController)
                  ? Colors.black
                  : Colors.grey,
            ),
            onFieldSubmitted: onFieldSubmitted,
            textInputAction: focusNode == _phoneNumberFocusNode
                ? TextInputAction.done
                : TextInputAction.next,
          ),
        ),
      ],
    );
  }

  //show date picker
  Future<Null> _showDatePicker() async {
    var userDOB = Utils.convertDateFromString(user?.dob, "yyyy/MM/dd");
    const int yearsDifference = 40;
    const int minumumDate = 17;
//    user.dob != null ? userDOB : DateTime.now()
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(DateTime.now().year - minumumDate),
        firstDate: DateTime(DateTime.now().year - yearsDifference),
        lastDate: DateTime(DateTime.now().year - minumumDate,
            DateTime.now().month, DateTime.now().day));
    if (picked != null) {
      setState(() {
        _dateOfBirthTextEditingController.text =
            Utils.stringDateInFormat("dd/MM/yyyy", picked);
        print("formatted date: ${_dateOfBirthTextEditingController.text}");
      });
    }
  }
}
