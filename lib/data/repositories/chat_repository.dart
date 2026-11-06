import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../models/enums.dart';

/// Persists the assistant conversation locally.
class ChatRepository {
  ChatRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Keep at most this many messages so the table cannot grow unbounded.
  static const maxMessages = 500;

  Stream<List<ChatMessageRecord>> watchAll() => (_db.select(
    _db.chatMessages,
  )..orderBy([(m) => OrderingTerm.asc(m.id)])).watch();

  Future<void> add(
    ChatRole role,
    String body, {
    bool insufficientData = false,
  }) async {
    await _db
        .into(_db.chatMessages)
        .insert(
          ChatMessagesCompanion.insert(
            role: role,
            body: body,
            insufficientData: Value(insufficientData),
            createdAt: _clock(),
          ),
        );
    final count = _db.chatMessages.id.count();
    final r = await (_db.selectOnly(
      _db.chatMessages,
    )..addColumns([count])).getSingle();
    final n = r.read(count) ?? 0;
    if (n > maxMessages) {
      final oldest =
          await (_db.select(_db.chatMessages)
                ..orderBy([(m) => OrderingTerm.asc(m.id)])
                ..limit(n - maxMessages))
              .get();
      await (_db.delete(
        _db.chatMessages,
      )..where((m) => m.id.isIn(oldest.map((e) => e.id)))).go();
    }
  }

  Future<void> clear() => _db.delete(_db.chatMessages).go();
}
