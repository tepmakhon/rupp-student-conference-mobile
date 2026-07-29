import '../../../core/network/api_client.dart';
import '../models/event_model.dart';

class EventService {
  Future<List<EventModel>> getApprovedEvents() async {
    final response = await ApiClient.get(
      "/events/approved",
    );

    final List events =
        response.data["data"]["events"];

    return events
        .map(
          (e) => EventModel.fromJson(e),
        )
        .toList();
  }
}