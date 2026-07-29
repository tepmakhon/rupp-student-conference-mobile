class ProfileModel {
  final String id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final DateTime? dateOfBirth;
  final String bio;
  final String profileImageUrl;

  const ProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.bio,
    required this.profileImageUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json["id"].toString(),
      userId: json["userId"].toString(),
      fullName: json["fullName"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      gender: json["gender"] ?? "",
      dateOfBirth: json["dateOfBirth"] != null
          ? DateTime.parse(json["dateOfBirth"])
          : null,
      bio: json["bio"] ?? "",
      profileImageUrl: json["profileImageUrl"] ?? "",
    );
  }
}