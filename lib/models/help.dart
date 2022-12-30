import 'model.dart';

class Help extends Model {
  String question;
  String answer;

  Help({
    int id = 0,
    required this.question,
    required this.answer,
  }) : super(id: id);

  @override
  Map<String, dynamic> toUpdateMap() {
    return {
      "question": question,
      "answer": answer,
    };
  }
  @override
  Map<String, dynamic> toCreateMap() {
    return {
      "question": question,
      "answer": answer,
    };
  }

  factory Help.fromMap(Map<String, dynamic> data) {
    return Help(
      id: data["id"],
      question: data["question"],
      answer: data["answer"],
    );
  }
}
