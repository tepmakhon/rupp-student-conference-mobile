import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/event_repository.dart';
import 'event_state.dart';

final eventProvider =
    StateNotifierProvider<EventNotifier, EventState>(
  (ref) => EventNotifier(),
);

class EventNotifier extends StateNotifier<EventState> {
  EventNotifier() : super(const EventState());

  final EventRepository _repository =
      EventRepository();

  Future<void> loadEvents() async {
    try {
      state = state.copyWith(
        status: EventStatus.loading,
      );

      final events =
          await _repository.getApprovedEvents();

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