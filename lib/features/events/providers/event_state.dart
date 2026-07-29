import '../models/event_model.dart';

enum EventStatus {
  initial,
  loading,
  loaded,
  error,
}

class EventState {
  final EventStatus status;
  final List<EventModel> events;
  final String? error;

  const EventState({
    this.status = EventStatus.initial,
    this.events = const [],
    this.error,
  });

  EventState copyWith({
    EventStatus? status,
    List<EventModel>? events,
    String? error,
  }) {
    return EventState(
      status: status ?? this.status,
      events: events ?? this.events,
      error: error,
    );
  }
}