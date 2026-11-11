import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user.dart';

class LoggerRiverpod extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (newValue is AsyncData<User>) {
      log(
        'User updated: ${provider.name ?? provider.runtimeType}: ${newValue.value.name}',
      );
    }
  }
}
