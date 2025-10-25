import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/home/models/room.dart';
import 'package:template/features/home/repositories/room_repository.dart';

/// 현재 활성화된 방 ID Provider
final currentRoomIdProvider = NotifierProvider<CurrentRoomIdNotifier, String?>(
  CurrentRoomIdNotifier.new,
);

/// 현재 방 ID를 관리하는 Notifier
class CurrentRoomIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// 방 ID 설정
  void setRoomId(String? roomId) {
    state = roomId;
  }

  /// 방 나가기
  void clear() {
    state = null;
  }
}

/// 현재 방 정보 Provider
final currentRoomProvider = StreamProvider<Room?>((ref) {
  final roomId = ref.watch(currentRoomIdProvider);
  if (roomId == null) {
    return Stream.value(null);
  }
  final repository = ref.watch(roomRepositoryProvider);
  return repository.watchRoom(roomId);
});

/// Room Controller Provider
final roomControllerProvider = Provider<RoomController>((ref) {
  return RoomController(ref);
});

/// Room을 관리하는 컨트롤러
///
/// 방 생성, 참가, 조회 기능을 제공합니다.
class RoomController {
  /// RoomController 생성자
  RoomController(this._ref);

  final Ref _ref;

  /// Repository 참조
  RoomRepository get _repository => _ref.read(roomRepositoryProvider);

  /// 새로운 방을 생성합니다.
  ///
  /// [roomName] 방 이름
  /// [memberName] 생성자 이름
  /// [avatarColor] 생성자 아바타 색상
  /// 생성된 방 객체를 반환합니다.
  Future<Room> createRoom({
    required String roomName,
    required String memberName,
    required int avatarColor,
  }) async {
    final room = await _repository.createRoom(
      name: roomName,
      memberName: memberName,
      avatarColor: avatarColor,
    );

    // 생성된 방을 현재 방으로 설정
    _ref.read(currentRoomIdProvider.notifier).setRoomId(room.id);

    return room;
  }

  /// 방 코드로 방에 참가합니다.
  ///
  /// [roomCode] 6자리 방 코드
  /// [memberName] 참가자 이름
  /// [avatarColor] 참가자 아바타 색상
  /// 참가한 방 객체를 반환합니다. 방을 찾지 못하면 null을 반환합니다.
  Future<Room?> joinRoomByCode({
    required String roomCode,
    required String memberName,
    required int avatarColor,
  }) async {
    final room = await _repository.findRoomByCode(roomCode);
    if (room == null) {
      return null;
    }

    await _repository.joinRoom(
      roomId: room.id,
      memberName: memberName,
      avatarColor: avatarColor,
    );

    // 참가한 방을 현재 방으로 설정
    _ref.read(currentRoomIdProvider.notifier).setRoomId(room.id);

    return room;
  }

  /// 현재 방에서 나갑니다.
  void leaveRoom() {
    _ref.read(currentRoomIdProvider.notifier).clear();
  }

  /// 특정 방을 조회합니다.
  ///
  /// [roomId] 방 ID
  Future<Room?> getRoom(String roomId) {
    return _repository.getRoom(roomId);
  }
}
