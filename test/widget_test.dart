import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2310/main.dart';
import 'package:p2310/providers.dart';
import 'package:p2310/user.dart';

class FakeUserRepository extends UserRepository {
  FakeUserRepository() : super(_UnusedClient());
  @override
  Future<User> fetchUserData(String userId) async =>
      User(name: 'Test $userId', email: 'test$userId@example.com');
}

class _UnusedClient extends FakeClientBase {}

// A no-network client; the repository is overridden in these widget tests.
abstract class FakeClientBase extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      throw UnimplementedError();
}

void main() {
  testWidgets('Search UI updates displayed user', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        ],
        child: const PeoplePulseApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test 1'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('userIdField')), '2');
    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();
    expect(find.text('Test 2'), findsOneWidget);
    expect(find.text('ID 2'), findsOneWidget);
  });
}
