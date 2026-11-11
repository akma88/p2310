import 'package:flutter_test/flutter_test.dart';
import 'package:p2310/user.dart';

void main() {
  test('User JSON conversion and equality', () {
    const user = User(name: 'Aida', email: 'aida@example.com');
    expect(User.fromJson(user.toJson()), user);
    expect(user.toMap()['name'], 'Aida');
    expect(
      user.copyWith(name: 'Dana'),
      const User(name: 'Dana', email: 'aida@example.com'),
    );
  });

  test('StateNotifier edits a user name', () {
    final notifier = UserNotifier(const User(name: 'Old', email: 'a@b.com'));
    notifier.updateName('New');
    expect(notifier.state.name, 'New');
    notifier.dispose();
  });

  test('ChangeNotifier edits a user name', () {
    final notifier = UserNotifierChange();
    var notifications = 0;
    notifier.addListener(() => notifications++);
    notifier.updateName('Dana');
    expect(notifier.user.name, 'Dana');
    expect(notifications, 1);
    notifier.dispose();
  });
}
