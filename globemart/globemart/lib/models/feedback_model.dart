import 'package:hive/hive.dart';

part 'feedback_model.g.dart';

@HiveType(typeId: 3)
class FeedbackModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String message;

  @HiveField(3)
  String dateTime;

  FeedbackModel({
    required this.id,
    required this.name,
    required this.message,
    required this.dateTime,
  });
}
