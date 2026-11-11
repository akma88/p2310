import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'user.dart';

final nameProvider = Provider<String>((ref) => 'People Pulse');

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return UserRepository(client);
});

// The family separates cache entries for individual user IDs.
final fetchUserProvider = FutureProvider.autoDispose.family<User, String>((
  ref,
  userId,
) {
  log('Init: fetchUser($userId)');
  final link = ref.keepAlive();
  Timer? timer;
  ref.onCancel(() {
    log('Cancel: fetchUser($userId)');
    timer = Timer(const Duration(seconds: 10), link.close);
  });
  ref.onResume(() {
    log('Resume: fetchUser($userId)');
    timer?.cancel();
    timer = null;
  });
  ref.onDispose(() {
    log('Dispose: fetchUser($userId)');
    timer?.cancel();
  });
  return ref.watch(userRepositoryProvider).fetchUserData(userId);
});

final streamProvider = StreamProvider<int>(
  (ref) => Stream.periodic(const Duration(seconds: 1), (count) => count + 1),
);

final selectedUserIdProvider = StateProvider<String>((ref) => '1');
final recentSearchesProvider =
    StateNotifierProvider<SearchHistory, List<String>>(
      (ref) => SearchHistory(),
    );

class SearchHistory extends StateNotifier<List<String>> {
  SearchHistory() : super(const []);
  void add(String id) {
    state = [id, ...state.where((item) => item != id)].take(5).toList();
  }

  void clear() => state = [];
}
