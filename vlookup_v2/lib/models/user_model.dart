class User {
  final String name;
  final String email;
  final String gender;
  final String phone;
  final String bio;
  final String dob;
  final String location;

  User({
    required this.name,
    required this.email,
    required this.gender,
    required this.phone,
    required this.bio,
    required this.location,
    required this.dob,
  });

  // Factory constructor for instantiating a new User from a map structure
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      gender: json['gender'] as String,
      phone: json['phone'] as String,
      bio: json['bio'] as String,
      location: json['location'] as String,
      dob: json['dob'] as String,
    );
  }

  // Converts a User instance into a map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'phone': phone,
      'bio': bio,
      'location': location,
      'dob': dob,
    };
  }
}