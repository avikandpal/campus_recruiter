import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_geek_test/model/question_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();

  factory DatabaseManager() => _instance;

  DatabaseManager._internal();

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  initDb() async {
    io.Directory docDirectory = await getApplicationDocumentsDirectory();
    String path = join(docDirectory.path, "CampusRecuriter.db");
    print("DATABASE PATH: $path");
    var db = await openDatabase(path, version: 1, onCreate: _createDatabase);
    return db;
  }

  void _createDatabase(Database db, int version) async {
    await db.execute("CREATE TABLE Question("
        "question_id TEXT PRIMARY KEY,"
        "question TEXT,"
        "category_id TEXT,"
        "sub_category_id TEXT,"
        "is_answered INTEGER,"
        "is_fav INTEGER,"
        "image TEXT)");

    await db.execute("CREATE TABLE Answer("
        "answer_id TEXT PRIMARY KEY,"
        "id TEXT,"
        "question_id TEXT,"
        "is_correct INTEGER,"
        "is_mark INTEGER,"
        "option TEXT,"
        "FOREIGN KEY(question_id) REFERENCES Question(question_id));");
    // When creating the db, create the table
  }

  /// INSERTS RECORDS INTO THE TABLE (ALT: rawInsert)
  saveQuestionAndAnswerLocal(List questionList, List answerList) async {
    Database? dbClient = await db;
    questionList.forEach((question) {
      dbClient?.transaction((txn) async {
        question["is_answered"] = 0;
        await txn.insert("Question", question);
      });
    });

    answerList.asMap().forEach((i, answer) {
      dbClient?.transaction((txn) async {
        answer["answer_id"] = "${i + 1}";
        await txn.insert("Answer", answer);
      });
    });
  }

  Future<List<Question?>?> getQuestionList() async {
    Database? dbClient = await db;
    List<Question?>? questionList = [];
    List<Map<String, dynamic>?>? list =
        await dbClient?.rawQuery('SELECT * FROM Question');
    list?.forEach((json) {
      questionList.add(Question.fromJson(json ?? {}));
    });
    return questionList;
  }

  markQuestionFav(Question? question) async {
    Database? dbClient = await db;
    await dbClient?.update('Question', {'is_fav': question?.isFav},
        where: 'question_id = ?', whereArgs: [question?.questionId]);
  }

  /////////////////////////////

  answered(Question? question, bool? isAnswered) async {
    Database? dbClient = await db;
    await dbClient?.update(
        'Question', {'is_answered': (isAnswered ?? false) ? 1 : 0},
        where: 'question_id = ?', whereArgs: [question?.questionId]);
  }

  selectAnswer(Answer? answer, bool? isSelected) async {
    Database? dbClient = await db;
    await dbClient?.update('Answer', {'is_mark': (isSelected ?? false) ? 1 : 0},
        where: 'answer_id = ?', whereArgs: [answer?.answerId]);
  }

  //////////////////////////////////

  deleteAllQuestionsAndAnswer() async {
    // Delete a record
    Database? dbClient = await db;
    await dbClient?.delete("Question");
    await dbClient?.delete("Answer");
  }

//This Function will get the all order History.....
  Future<List<Question?>?> getAllQuestionList() async {
    var dbClient = await db;
    List<Question?> questionList = [];
    List<Map<String, dynamic>?>? list =
        await dbClient?.rawQuery('SELECT * FROM Question');
    list?.forEach((v) {
      questionList.add(Question.fromJson(v ?? {}));
    });
    return questionList;
  }

  Future<List<Answer?>?> getAnswerList() async {
    Database? dbClient = await db;
    List<Answer?> answerList = [];
    List<Map<String, dynamic>?>? list =
        await dbClient?.rawQuery('SELECT * FROM Answer');
    list?.forEach((v) {
      answerList.add(Answer.fromJson(v ?? {}));
    });
    return answerList;
  }
} //Class........
