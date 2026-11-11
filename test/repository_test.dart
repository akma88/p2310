import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:p2310/user.dart';

void main() {
  test('UserRepository requests user by ID', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/users/3');
      return http.Response('{"name":"Leila","email":"l@example.com"}', 200);
    });
    final user = await UserRepository(client).fetchUserData('3');
    expect(user.name, 'Leila');
    expect(user.email, 'l@example.com');
    client.close();
  });

  test('UserRepository throws on HTTP error', () async {
    final client = MockClient((_) async => http.Response('Not Found', 404));
    expect(UserRepository(client).fetchUserData('99'), throwsException);
    client.close();
  });
}
