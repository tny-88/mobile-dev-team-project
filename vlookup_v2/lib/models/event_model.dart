class AppEvent {
  final String event_id;
  final String title;
  final String email;
  final String description;
  final String date;
  final String image;
  final String location;
  final String phone;

  AppEvent({
    required this.event_id,
    required this.title,
    required this.email,
    required this.description,
    required this.date,
    required this.image,
    required this.location,
    required this.phone,
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
      phone: json['phone_number'] as String,
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
      'phone_number': phone,
    };
  }

  // Creates a copy of the current event with updated fields
  AppEvent copyWith({
    String? event_id,
    String? title,
    String? email,
    String? description,
    String? date,
    String? image,
    String? location,
    String? phone,
  }) {
    return AppEvent(
      event_id: event_id ?? this.event_id,
      title: title ?? this.title,
      email: email ?? this.email,
      description: description ?? this.description,
      date: date ?? this.date,
      image: image ?? this.image,
      location: location ?? this.location,
      phone: phone ?? this.phone,
    );
  }
}
