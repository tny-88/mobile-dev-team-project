class User {
  final String name;
  final String email;
  final String gender;
  final String phone;
  final String bio;
  final String dob;
  final String location;
  final String image;

  User({
    required this.name,
    required this.email,
    required this.gender,
    required this.phone,
    required this.bio,
    required this.location,
    required this.dob,
    required this.image,
  });

  // Factory constructor for instantiating a new User from a map structure
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      gender: json['gender'] as String,
      phone: json['phone'] as String,
      bio: json['bio'] as String,
      location: json['location'],
      image: json['image'] as String,
      dob: json['dob'] as String
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
      'image': image,
    };
  }

  // Creates a copy of the current user with updated fields
  User copyWith({
    String? name,
    String? email,
    String? gender,
    String? phone,
    String? bio,
    String? location,
    String? dob,
    String? image,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      dob: dob ?? this.dob,
      image: image ?? this.image,
    );
  }
}
