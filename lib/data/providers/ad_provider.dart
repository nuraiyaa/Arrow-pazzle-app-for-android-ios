import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ads/ad_manager.dart';

final adManagerProvider = Provider<AdManager>((ref) {
  final manager = AdManager.instance;
  // Initialize in background
  manager.initialize();
  ref.onDispose(() {
    manager.dispose();
  });
  return manager;
});
