import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/event_service.dart';
import 'event_state.dart';

final eventProvider =
    StateNotifierProvider<
        EventNotifier,
        EventState>((ref) {
  return EventNotifier();
});

class EventNotifier
    extends StateNotifier<EventState> {
  EventNotifier()
      : super(const EventState());

  final EventService _service =
      EventService();

  Future<void> loadEvents() async {
    try {
      state = state.copyWith(
        status: EventStatus.loading,
      );

      final events =
          await _service.getApprovedEvents();

      state = state.copyWith(
        status: EventStatus.loaded,
        events: events,
      );
    } catch (e) {
      state = state.copyWith(
        status: EventStatus.error,
        error: e.toString(),
      );
    }
  }
}