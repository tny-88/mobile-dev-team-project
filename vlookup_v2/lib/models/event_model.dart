class AppEvent {
  final String event_id;
  final String title;
  final String email;
  final String description;
  final String date;
  final String image;
  final String location;

  AppEvent({
    required this.event_id,
    required this.title,
    required this.email,
    required this.description,
    required this.date,
    required this.image,
    required this.location,
  });

  // Factory constructor for instantiating a new Event from a map structure
  factory AppEvent.fromJson(Map<String, dynamic> json) {
    return AppEvent(
      event_id: json['event_id'] as String,
      title: json['title'] as String,
      email: json['email'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
      image: json['image'] as String,
      location: json['location'] as String,
    );
  }

  // Converts a Event instance into a map
  Map<String, dynamic> toJson() {
    return {
      'event_id': event_id,
      'title': title,
      'email': email,
      'description': description,
      'date': date,
      'image': image,
      'location': location,
    };
  }
}