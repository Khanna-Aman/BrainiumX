import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String displayName;
  
  @HiveField(2)
  DateTime? dob;
  
  @HiveField(3)
  String preferredTheme;
  
  UserProfile({
    required this.id,
    required this.displayName,
    this.dob,
    this.preferredTheme = 'default',
  });
}
