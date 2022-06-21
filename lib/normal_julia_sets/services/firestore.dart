import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:normal_julia_sets/app/services/auth.dart';
import 'package:normal_julia_sets/normal_julia_sets/models/set_properties.dart';
import 'package:path_provider/path_provider.dart';

abstract class SetsService {
  Future<List<SetProperties>> getSets();
  Future<void> removeSet(SetProperties set);
  Future<SetProperties> updateSet(SetProperties set);
  Future<SetProperties> createSet(SetProperties set);
}

class FirestoreService implements SetsService {
  FirestoreService._();
  factory FirestoreService.getInstance() {
    _instance ??= FirestoreService._();
    return _instance!;
  }
  static FirestoreService? _instance;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseStorage get _store => FirebaseStorage.instance;

  String _getUid() {
    final uid = AuthService.getInstance().user?.uid;
    if (uid == null) throw Exception('User is unauthorized');
    return uid;
  }

  @override
  Future<List<SetProperties>> getSets() async {
    final uid = _getUid();
    final ref = _db.collection('sets').where('author', isEqualTo: uid);
    final snapshot = await ref.orderBy('created', descending: true).get();

    final data = snapshot.docs.map((s) {
      return <String, dynamic>{...s.data(), 'id': s.id};
    });

    final sets = data.map(SetProperties.fromMap);
    return sets.toList();
  }

  Future<SetProperties> _upsertSet(
    String? setId,
    SetProperties set,
  ) async {
    final uid = _getUid();
    final ref = _db.collection('sets').doc(setId);
    final data = <String, dynamic>{
      ...set.toMap(),
      'author': uid,
      'imageSrc': await _uploadImage(set.image!, set.created),
    };
    debugPrint('uploaded');
    if (setId == null) {
      data['created'] = FieldValue.serverTimestamp();
    }
    _getUid();
    await ref.set(data);
    final updated = await ref.get();
    final returnedData = updated.data();
    debugPrint('updated');

    if (returnedData == null) throw Exception('Failed to update');
    final returnedSet = <String, dynamic>{...returnedData, 'id': updated.id};
    return SetProperties.fromMap(returnedSet);
  }

  @override
  Future<void> removeSet(
    SetProperties set,
  ) async {
    _getUid();
    final ref = _db.collection('sets').doc(set.id);
    await ref.delete();
    if (set.imageSrc == null) {
      throw Exception('Deleted file had no imageSrc.');
    }
    await _store.refFromURL(set.imageSrc!).delete();
  }

  @override
  Future<SetProperties> updateSet(SetProperties set) async {
    return _upsertSet(set.id, set);
  }

  @override
  Future<SetProperties> createSet(SetProperties set) async {
    return _upsertSet(null, set);
  }

  Future<String> _uploadImage(Image img, Timestamp timestamp) async {
    final uid = _getUid();
    final imgToData = await img.toByteData(format: ImageByteFormat.png);
    debugPrint('serialized');
    final tmpDir = await getTemporaryDirectory();
    debugPrint('got directory');
    final fileName = '$uid-${timestamp.toDate().toIso8601String()}';
    final file = File('${tmpDir.path}/$fileName.png');
    await file.writeAsBytes(imgToData!.buffer.asInt8List());
    debugPrint('written');
    final task = await _store.ref('uploads/$fileName.png').putFile(file, SettableMetadata(contentType: 'image/png'));
    debugPrint('put');
    return task.ref.getDownloadURL();
  }
}
