import 'dart:convert';

class User {
  final String uid;
  final String name;
  final String profilepic;
  // final List<dynamic> cart;

  User({
    required this.uid,
    required this.name,
    required this.profilepic,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profilepic': profilepic,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      profilepic: map['profilepic'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? uid,
    String? name,
    String? profilepic,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profilepic: profilepic ?? this.profilepic,
    );
  }
}
