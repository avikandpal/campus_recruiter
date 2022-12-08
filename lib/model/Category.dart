class Category {
  String? sId;
  String? name;
  int? numberOfQuestion;
  List<SubCategory>? subCategory;
  bool? isSelected = false;
  bool? isExpanded = false;

  Category({this.sId, this.name, this.numberOfQuestion, this.subCategory});

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    numberOfQuestion = json['number_of_question'];
    if (json['sub_category'] != null) {
      subCategory = <SubCategory>[];
      json['sub_category'].forEach((v) {
        subCategory?.add(SubCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['number_of_question'] = this.numberOfQuestion;
    final subCategory = this.subCategory;
    if (subCategory != null) {
      data['sub_category'] = subCategory.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubCategory {
  String? sId;
  String? name;
  int? numberOfQuestion;
  bool? isSelected = false;

  SubCategory({this.sId, this.name, this.numberOfQuestion});

  SubCategory.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    numberOfQuestion = json['number_of_question'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['number_of_question'] = this.numberOfQuestion;
    return data;
  }
}
