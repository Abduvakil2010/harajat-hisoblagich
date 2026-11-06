import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Status of the optional Firebase integration.
enum CloudStatus { notConfigured, ready }

class CloudBackupInfo {
  const CloudBackupInfo(this.updatedAt, this.sizeChars);
  final DateTime updatedAt;
  final int sizeChars;
}

class CloudUnavailableException implements Exception {
  const CloudUnavailableException();
}

/// Optional cloud backup using Firebase Anonymous Auth + Firestore.
///
/// * The app never requires this: it works fully offline without Firebase.
/// * Firebase is initialised only if native config files exist
///   (`google-services.json` / `GoogleService-Info.plist`).
/// * Anonymous identities are bound to this installation. Uninstalling the
///   app loses access to that cloud copy – use the JSON file export to move
///   data between devices. (See README › Backup.)
/// * Firestore rules (`firestore.rules`) restrict each user to
///   `users/{uid}/**`.
class CloudBackupService {
  CloudBackupService._(this.status);

  final CloudStatus status;

  static const _chunkSize = 250000; // chars; keeps each doc well under 1 MiB.

  bool get isAvailable => status == CloudStatus.ready;

  /// Tries to initialise Firebase; never throws.
  static Future<CloudBackupService> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp().timeout(const Duration(seconds: 8));
      }
      return CloudBackupService._(CloudStatus.ready);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase not configured; cloud backup disabled.');
      }
      return CloudBackupService._(CloudStatus.notConfigured);
    }
  }

  /// A disabled service (default when Firebase is not initialised, and in tests).
  factory CloudBackupService.unavailable() =>
      CloudBackupService._(CloudStatus.notConfigured);

  Future<String> _uid() async {
    if (!isAvailable) throw const CloudUnavailableException();
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
    if (user == null) throw const CloudUnavailableException();
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _doc(String uid) => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('backups')
      .doc('latest');

  Future<void> upload(String json) async {
    final uid = await _uid();
    final doc = _doc(uid);
    final chunks = <String>[
      for (var i = 0; i < json.length; i += _chunkSize)
        json.substring(
          i,
          i + _chunkSize > json.length ? json.length : i + _chunkSize,
        ),
    ];
    final old = await doc.collection('chunks').get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in old.docs) {
      batch.delete(d.reference);
    }
    for (var i = 0; i < chunks.length; i++) {
      batch.set(doc.collection('chunks').doc(i.toString().padLeft(4, '0')), {
        'i': i,
        'data': chunks[i],
      });
    }
    batch.set(doc, {
      'updatedAt': FieldValue.serverTimestamp(),
      'chunkCount': chunks.length,
      'sizeChars': json.length,
      'format': 'hisobai-backup',
    });
    await batch.commit();
  }

  Future<CloudBackupInfo?> info() async {
    final uid = await _uid();
    final snap = await _doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    final ts = data['updatedAt'];
    return CloudBackupInfo(
      ts is Timestamp ? ts.toDate() : DateTime.now(),
      (data['sizeChars'] as num?)?.toInt() ?? 0,
    );
  }

  Future<String?> download() async {
    final uid = await _uid();
    final doc = _doc(uid);
    final meta = await doc.get();
    final count = (meta.data()?['chunkCount'] as num?)?.toInt();
    if (count == null) return null;
    final chunks = await doc.collection('chunks').orderBy('i').get();
    if (chunks.docs.length != count) {
      throw const FormatException('incomplete backup');
    }
    return chunks.docs.map((d) => d.data()['data'] as String).join();
  }

  Future<void> deleteRemote() async {
    final uid = await _uid();
    final doc = _doc(uid);
    final chunks = await doc.collection('chunks').get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in chunks.docs) {
      batch.delete(d.reference);
    }
    batch.delete(doc);
    await batch.commit();
  }
}
