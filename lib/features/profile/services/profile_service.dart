import '../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

class ProfileService {
  Future<ProfileModel> getProfile() async {
    final response = await DioClient.dio.get(
      "/profile/me",
    );

    return ProfileModel.fromJson(response.data["data"]);
  }
}