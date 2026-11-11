import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'user.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final controller = TextEditingController(text: '1');

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void search([String? chosen]) {
    final id = (chosen ?? controller.text).trim();
    final parsed = int.tryParse(id);
    if (parsed == null || parsed < 1 || parsed > 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите ID от 1 до 10')));
      return;
    }
    controller.text = id;
    ref.read(selectedUserIdProvider.notifier).state = id;
    ref.read(recentSearchesProvider.notifier).add(id);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final id = ref.watch(selectedUserIdProvider);
    final user = ref.watch(fetchUserProvider(id));
    final tick = ref.watch(streamProvider);
    final history = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.watch(nameProvider)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Icon(
              Icons.people_alt_rounded,
              color: Color(0xFF6554D9),
              size: 52,
            ),
            const SizedBox(height: 12),
            const Text(
              'Найди пользователя',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Введите ID, чтобы посмотреть имя и почту.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),
            TextField(
              key: const Key('userIdField'),
              controller: controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'ID пользователя (1–10)',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              onSubmitted: (_) => search(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('searchButton'),
              onPressed: search,
              icon: const Icon(Icons.search),
              label: const Text('Найти'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 22),
            user.when(
              data: (value) => _UserCard(user: value, id: id),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.wifi_off, size: 35),
                      const SizedBox(height: 8),
                      const Text('Не удалось загрузить данные'),
                      const SizedBox(height: 8),
                      Text('$error', textAlign: TextAlign.center),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(fetchUserProvider(id)),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Недавние запросы',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                if (history.isNotEmpty)
                  TextButton(
                    onPressed: () =>
                        ref.read(recentSearchesProvider.notifier).clear(),
                    child: const Text('Очистить'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (history.isEmpty)
              const Text('История пока пуста')
            else
              Wrap(
                spacing: 8,
                children: [
                  for (final item in history)
                    ActionChip(
                      label: Text('ID $item'),
                      onPressed: () => search(item),
                    ),
                ],
              ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Icon(Icons.circle, size: 10, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Live Stream · '),
                Text(
                  tick.when(
                    data: (seconds) => '$seconds сек',
                    loading: () => 'подключение',
                    error: (_, __) => 'ошибка',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final String id;
  const _UserCard({required this.user, required this.id});

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFFEAE6FF),
                child: Text(
                  user.name.isEmpty ? '?' : user.name[0],
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF6554D9),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Пользователь #$id'),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          const Text(
            'EMAIL',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          SelectableText(user.email, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
