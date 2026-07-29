class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime eventDate;
  final int? capacity;
  final String? bannerImageUrl;
  final String status;

  final String organizationName;
  final String categoryName;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDate,
    required this.capacity,
    required this.bannerImageUrl,
    required this.status,
    required this.organizationName,
    required this.categoryName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      location: json["location"],
      eventDate: DateTime.parse(json["eventDate"]),
      capacity: json["capacity"],
      bannerImageUrl: json["bannerImageUrl"],
      status: json["status"],
      organizationName: json["organization"]["organizationName"],
      categoryName: json["category"]["categoryName"],
    );
  }
}