import '../models/profile_model.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
}

class ProfileState {
  final ProfileStatus status;
  final ProfileModel? profile;
  final String? error;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.error,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    String? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}