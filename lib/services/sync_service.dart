import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/db_helper.dart';

class SyncService {
  static Future<String> syncToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'Not logged in';

      final unsynced = await DBHelper.getUnsyncedTasks();
      if (unsynced.isEmpty) return 'Nothing to sync';

      final col = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');

      for (final task in unsynced) {
        await col.add({
          'title':       task.title,
          'description': task.description,
          'createdAt':   task.createdAt,
          'syncedAt':    DateTime.now().toIso8601String(),
        });
        await DBHelper.markAsSynced(task.id!);
      }
      return 'Synced ${unsynced.length} task(s) successfully!';
    } catch (e) {
      return 'Sync failed: $e';
    }
  }
}