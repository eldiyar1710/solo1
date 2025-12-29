import 'package:flutter/widgets.dart';
import 'package:solo1/core/sync/sync_service.dart';

class LifecycleSyncObserver with WidgetsBindingObserver {
  final SyncService sync;
  LifecycleSyncObserver(this.sync);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      sync.processQueue();
    }
  }
}