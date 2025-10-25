import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/home/models/room.dart';

/// RoomRepository Provider
final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepository();
});

/// Room 데이터의 Firestore CRUD 작업을 담당하는 Repository
///
/// Firestore의 'rooms' 컬렉션과 상호작용합니다.
class RoomRepository {
  /// RoomRepository 생성자
  RoomRepository() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Firestore rooms 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _roomsCollection =>
      _firestore.collection('rooms');

  /// 6자리 랜덤 방 코드 생성
  String _generateRoomCode() {
    final random = Random();
    final code = List.generate(6, (_) => random.nextInt(10)).join();
    return code;
  }

  /// 새로운 방을 생성합니다.
  ///
  /// [name] 방 이름
  /// [memberName] 생성자 이름
  /// [avatarColor] 생성자 아바타 색상
  /// 생성된 방의 ID를 반환합니다.
  Future<Room> createRoom({
    required String name,
    required String memberName,
    required int avatarColor,
  }) async {
    try {
      final roomCode = _generateRoomCode();
      final now = DateTime.now();

      final room = Room(
        id: '', // Firestore가 자동 생성
        name: name,
        roomCode: roomCode,
        createdAt: now,
        members: [
          RoomMember(
            name: memberName,
            avatarColor: avatarColor,
            joinedAt: now,
          ),
        ],
      );

      final data = room.toFirestore();
      // ignore: avoid_print
      print('Creating room with data: $data');

      final docRef = await _roomsCollection.add(data);
      // ignore: avoid_print
      print('Room created with ID: ${docRef.id}');

      return room.copyWith(id: docRef.id);
    } catch (e) {
      // ignore: avoid_print
      print('Error creating room: $e');
      rethrow;
    }
  }

  /// 방 코드로 방을 찾습니다.
  ///
  /// [roomCode] 6자리 방 코드
  /// 방을 찾으면 Room 객체를, 찾지 못하면 null을 반환합니다.
  Future<Room?> findRoomByCode(String roomCode) async {
    final querySnapshot = await _roomsCollection
        .where('roomCode', isEqualTo: roomCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final doc = querySnapshot.docs.first;
    return Room.fromFirestore(doc.data(), doc.id);
  }

  /// 방에 참가합니다.
  ///
  /// [roomId] 방 ID
  /// [memberName] 참가자 이름
  /// [avatarColor] 참가자 아바타 색상
  Future<void> joinRoom({
    required String roomId,
    required String memberName,
    required int avatarColor,
  }) async {
    final roomDoc = await _roomsCollection.doc(roomId).get();
    if (!roomDoc.exists) {
      throw Exception('Room not found');
    }

    final room = Room.fromFirestore(roomDoc.data()!, roomId);
    final newMember = RoomMember(
      name: memberName,
      avatarColor: avatarColor,
      joinedAt: DateTime.now(),
    );

    final updatedMembers = [...room.members, newMember];
    await _roomsCollection.doc(roomId).update({
      'members': updatedMembers.map((m) => m.toJson()).toList(),
    });
  }

  /// 특정 방을 조회합니다.
  ///
  /// [roomId] 방 ID
  Future<Room?> getRoom(String roomId) async {
    final doc = await _roomsCollection.doc(roomId).get();
    if (!doc.exists) {
      return null;
    }
    return Room.fromFirestore(doc.data()!, doc.id);
  }

  /// 방을 실시간으로 스트리밍합니다.
  ///
  /// [roomId] 방 ID
  Stream<Room?> watchRoom(String roomId) {
    return _roomsCollection.doc(roomId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return Room.fromFirestore(doc.data()!, doc.id);
    });
  }
}
