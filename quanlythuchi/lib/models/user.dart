class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String passwordHash;

  User({required this.id, required this.username, required this.email, required this.fullName, this.passwordHash = ''});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'fullName': fullName,
    'passwordHash': passwordHash,
  };
}
