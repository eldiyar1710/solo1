import 'package:hive/hive.dart';
import 'package:solo1/core/data/remote/firebase_remote_datasource.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  final FirebaseRemoteDataSource remote;
  SyncService({FirebaseRemoteDataSource? remote}) : remote = remote ?? FirebaseRemoteDataSource();

  Future<void> enqueueSale(Map<String, dynamic> sale, {required String idempotencyKey}) async {
    final box = Hive.box('sync_queue');
    final list = (box.get('items') as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    list.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'opType': 'create_sale',
      'payload': sale,
      'idempotencyKey': idempotencyKey,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'retries': 0,
      'status': 'pending',
    });
    await box.put('items', list);
  }

  Future<void> enqueueNotificationCreate({required String title, required String message, required int date}) async {
    final box = Hive.box('sync_queue');
    final list = (box.get('items') as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    list.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'opType': 'create_notification',
      'payload': {
        'title': title,
        'message': message,
        'date': date,
      },
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'retries': 0,
      'status': 'pending',
    });
    await box.put('items', list);
  }

  Future<void> enqueueNotificationUpdate({required String id, required String title, required String message, required int date}) async {
    final box = Hive.box('sync_queue');
    final list = (box.get('items') as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    list.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'opType': 'update_notification',
      'payload': {
        'id': id,
        'title': title,
        'message': message,
        'date': date,
      },
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'retries': 0,
      'status': 'pending',
    });
    await box.put('items', list);
  }

  Future<void> enqueueNotificationDelete({required String id}) async {
    final box = Hive.box('sync_queue');
    final list = (box.get('items') as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    list.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'opType': 'delete_notification',
      'payload': {
        'id': id,
      },
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'retries': 0,
      'status': 'pending',
    });
    await box.put('items', list);
  }

  Future<void> enqueueBannerCreate({required String title, required String imageUrl, required bool active, required int priority}) async {
    final box = Hive.box('sync_queue');
    final list = (box.get('items') as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    list.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'opType': 'create_banner',
      'payload': {
        'title': title,
        'imageUrl': imageUrl,
        'active': active,
        'priority': priority,
      },
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'retries': 0,
      'status': 'pending',
    });
    await box.put('items', list);
  }

  Future<void> enqueueBannerUpdate({required String id, required String title, required String imageUrl, required bool active, required int priority}) async {
    final box = Hive.box('sync_queue');
    final list = (box.get('items') as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    list.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'opType': 'update_banner',
      'payload': {
        'id': id,
        'title': title,
        'imageUrl': imageUrl,
        'active': active,
        'priority': priority,
      },
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'retries': 0,
      'status': 'pending',
    });
    await box.put('items', list);
  }

  Future<void> enqueueBannerDelete({required String id}) async {
    final box = Hive.box('sync_queue');
    final list = (box.get('items') as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    list.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'opType': 'delete_banner',
      'payload': {
        'id': id,
      },
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'retries': 0,
      'status': 'pending',
    });
    await box.put('items', list);
  }

  Future<void> processQueue() async {
    try {
      final boxUser = Hive.box('userBox');
      final raw = boxUser.get('agent');
      final isTest = raw is Map && ((raw['status'] as String?) == 'test' || (raw['email'] as String?)?.toLowerCase() == 'test@solo1.app');
      if (!kReleaseMode && isTest) {
        return;
      }
    } catch (_) {}
    final box = Hive.box('sync_queue');
    final list = (box.get('items') as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    bool changed = false;
    for (final item in list) {
      if (item['status'] != 'pending') continue;
      try {
        switch (item['opType']) {
          case 'create_sale':
            await remote.createSale(Map<String, dynamic>.from(item['payload'] as Map));
            item['status'] = 'done';
            changed = true;
            break;
          case 'create_notification': {
            final p = Map<String, dynamic>.from(item['payload'] as Map);
            await remote.addNotification(title: p['title'] as String, message: p['message'] as String, date: (p['date'] as int));
            item['status'] = 'done';
            changed = true;
            break;
          }
          case 'update_notification': {
            final p = Map<String, dynamic>.from(item['payload'] as Map);
            await remote.updateNotification(
              p['id'] as String,
              title: p['title'] as String,
              message: p['message'] as String,
              date: (p['date'] as int),
            );
            item['status'] = 'done';
            changed = true;
            break;
          }
          case 'delete_notification': {
            final p = Map<String, dynamic>.from(item['payload'] as Map);
            await remote.deleteNotification(p['id'] as String);
            item['status'] = 'done';
            changed = true;
            break;
          }
          case 'create_banner': {
            final p = Map<String, dynamic>.from(item['payload'] as Map);
            await remote.addBanner(title: p['title'] as String, imageUrl: (p['imageUrl'] ?? '') as String, active: (p['active'] as bool), priority: (p['priority'] as int));
            item['status'] = 'done';
            changed = true;
            break;
          }
          case 'update_banner': {
            final p = Map<String, dynamic>.from(item['payload'] as Map);
            await remote.updateBanner(p['id'] as String, title: p['title'] as String, imageUrl: (p['imageUrl'] ?? '') as String, active: (p['active'] as bool), priority: (p['priority'] as int));
            item['status'] = 'done';
            changed = true;
            break;
          }
          case 'delete_banner': {
            final p = Map<String, dynamic>.from(item['payload'] as Map);
            await remote.deleteBanner(p['id'] as String);
            item['status'] = 'done';
            changed = true;
            break;
          }
        }
      } catch (_) {
        final retries = (item['retries'] as int?) ?? 0;
        item['retries'] = retries + 1;
        item['status'] = retries > 3 ? 'failed' : 'pending';
        changed = true;
      }
    }
    if (changed) {
      await box.put('items', list);
    }
  }
}