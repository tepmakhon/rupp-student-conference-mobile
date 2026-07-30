import '../models/event_model.dart';
import '../services/event_service.dart';

class EventRepository {
  final EventService _service = EventService();

  Future<List<EventModel>> getApprovedEvents() {
    return _service.getApprovedEvents();
  }
}