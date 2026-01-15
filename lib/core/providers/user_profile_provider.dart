import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/models.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) {
    _loadProfile();
  }

  void _loadProfile() {
    final box = Hive.box<UserProfile>('user_profile');
    if (box.isNotEmpty) {
      state = box.values.first;
    }
  }

  Future<void> createProfile({
    required String displayName,
  }) async {
    final profile = UserProfile(
      id: const Uuid().v4(),
      displayName: displayName,
      dob: null,
      preferredTheme: 'default',
    );

    final box = Hive.box<UserProfile>('user_profile');
    await box.clear();
    await box.add(profile);

    state = profile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await profile.save();
    state = profile;
  }

  Future<void> updateTheme(String theme) async {
    if (state != null) {
      final updatedProfile = UserProfile(
        id: state!.id,
        displayName: state!.displayName,
        dob: state!.dob,
        preferredTheme: theme,
      );

      // Clear the old profile and save the new one
      final box = Hive.box<UserProfile>('user_profile');
      await box.clear();
      await box.add(updatedProfile);

      state = updatedProfile;
    }
  }
}
