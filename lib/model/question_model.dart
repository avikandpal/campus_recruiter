//  {question: 'Question 1 text', answers: ['answer 1', 'answer 2'], correct: 0},

class Question {
  String? question;
  String? questionId;
  String? image;
  String? categoryId;
  String? subCategoryId;
  int? isFav = 0;
  bool? isSelected = false;
  bool? isAnswered = false;
  int? marked = 0;
  List<Answer?>? answerList = [];

  Question({this.question,
    this.questionId,
    this.image,
    this.categoryId,
    this.subCategoryId});

  Question.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    questionId = json['question_id'];
    image = json['image'];
    categoryId = json['category_id'];
    isAnswered = json['is_answered'] == 0 ? false : true;
    subCategoryId = json['sub_category_id'];
    if (json['is_fav'] != null) {
      isFav = json['is_fav'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['question'] = this.question;
    data['question_id'] = this.questionId;
    data['image'] = this.image;
    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    return data;
  }
}

class Answer {
  int? isCorrect;
  String? option;
  String? questionId;
  bool? isSelected = false;
  int? answered = 0;
  String? id;
  String? answerId;

  Answer({this.isCorrect, this.option, this.questionId});

  Answer.fromJson(Map<String, dynamic> json) {
    isCorrect = json['is_correct'];
    option = json['option'];
    questionId = json['question_id'];
    if (json['is_mark'] != null) {
      answered = json['is_mark'];
    }
    if (json['id'] != null) {
      id = json['id'];
    }
    if (json['answer_id'] != null) {
      answerId = json['answer_id'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['is_correct'] = this.isCorrect;
    data['option'] = this.option;
    data['question_id'] = this.questionId;
    if (this.answered != null) {
      data['is_mark'] = this.answered;
    }
    if (this.id != null) {
      data['id'] = this.id;
    }
    if (this.answerId != null) {
      data['answer_id'] = this.answerId;
    }
    return data;
  }
}
