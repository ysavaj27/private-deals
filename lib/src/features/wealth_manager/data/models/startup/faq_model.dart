import 'package:private_deals/src/shared/functions/parse.dart';

class FaqModel {
  String question;
  String answer;

  FaqModel({
    this.question = '',
    this.answer = '',
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
        question: Parse.toStrings(json["question"]),
        answer: Parse.toStrings(json["answer"]),
      );

  Map<String, dynamic> toJson() => {
        "question": question,
        "answer": answer,
      };
}
