import '../../../core/network/dio_client.dart';
import '../models/event_model.dart';

class EventService {
  Future<List<EventModel>> getApprovedEvents() async {
    final response = await DioClient.dio.get(
      "/events/approved",
    );

    final List<dynamic> events =
        response.data["data"]["events"];

    return events
        .map((e) => EventModel.fromJson(e))
        .toList();
  }
}