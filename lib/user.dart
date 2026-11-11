import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class User {
  final String name;
  final String email;

  const User({required this.name, required this.email});

  User copyWith({String? name, String? email}) =>
      User(name: name ?? this.name, email: email ?? this.email);

  Map<String, dynamic> toMap() => {'name': name, 'email': email};

  factory User.fromMap(Map<String, dynamic> map) => User(
    name: map['name'] as String? ?? '',
    email: map['email'] as String? ?? '',
  );

  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'User(name: $name, email: $email)';

  @override
  bool operator ==(Object other) =>
      other is User && other.name == name && other.email == email;

  @override
  int get hashCode => Object.hash(name, email);
}

class UserRepository {
  final http.Client client;
  UserRepository(this.client);

  Future<User> fetchUserData(String userId) async {
    final response = await client.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users/$userId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Пользователь не найден (HTTP ${response.statusCode})');
    }
    return User.fromJson(response.body);
  }
}

class UserNotifier extends StateNotifier<User> {
  UserNotifier(super.state);
  void updateName(String name) => state = state.copyWith(name: name);
}

class UserNotifierChange extends ChangeNotifier {
  User user = const User(name: '', email: '');
  void updateName(String name) {
    user = user.copyWith(name: name);
    notifyListeners();
  }
}
