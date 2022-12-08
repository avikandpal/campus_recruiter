class User {
  String? sId;
  String? name;
  String? rollNo;
  String? fatherName;
  String? qualification;
  String? branch;
  int? batch;
  String? email;
  String? phoneNo;
  String? dob;
  String? instituteName;

  User({this.sId,
    this.name,
    this.rollNo,
    this.fatherName,
    this.qualification,
    this.branch,
    this.batch,
    this.email,
    this.phoneNo,
    this.dob,
    this.instituteName});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    rollNo = json['roll_no'];
    fatherName = json['father_name'];
    qualification = json['qualification'];
    branch = json['branch'];
    batch = json['batch'];
    email = json['email'];
    phoneNo = json['phone_no'];
    dob = json['dob'];
    instituteName = json['institute_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['roll_no'] = this.rollNo;
    data['father_name'] = this.fatherName;
    data['qualification'] = this.qualification;
    data['branch'] = this.branch;
    data['batch'] = this.batch;
    data['email'] = this.email;
    data['phone_no'] = this.phoneNo;
    data['dob'] = this.dob;
    data['institute_name'] = this.instituteName;
    return data;
  }
}
