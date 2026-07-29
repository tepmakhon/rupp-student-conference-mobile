import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/profile_repository.dart';
import 'profile_state.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  final ProfileRepository _repository = ProfileRepository();

  Future<void> loadProfile() async {
    try {
      state = state.copyWith(
        status: ProfileStatus.loading,
      );

      final profile = await _repository.getProfile();

      state = state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      );
    }
  }
}