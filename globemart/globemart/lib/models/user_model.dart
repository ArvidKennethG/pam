import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String name;

  @HiveField(3)
  String passwordHash;

  // Optional: path to profile image stored locally
  @HiveField(4)
  String? profileImagePath;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.passwordHash,
    this.profileImagePath,
  });
}
