class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int age;
  final String contactNo;
  final String gender;
  final String image;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.age = 0,
    this.contactNo = '',
    required this.gender,
    required this.image,
  });

  factory User.fromJson(
    Map<String, dynamic> json,
  ) {
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username:
          json['username']?.toString() ?? '',
      email:
          json['email']?.toString() ?? '',
      firstName:
          json['firstName']?.toString() ?? '',
      lastName:
          json['lastName']?.toString() ?? '',
      age:
          (json['age'] as num?)?.toInt() ?? 0,
      contactNo:
          json['contactNo']?.toString() ??
          json['phone']?.toString() ??
          '',
      gender:
          json['gender']?.toString() ?? '',
      image:
          json['image']?.toString() ?? '',
    );
  }
}