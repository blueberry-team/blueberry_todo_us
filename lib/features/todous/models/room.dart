/// Room 데이터 모델
class Room {
  /// Room 생성자
  const Room({
    required this.id,
    required this.name,
    required this.roomCode,
    required this.createdAt,
    this.members = const [],
  });

  /// Firestore 문서를 Room으로 변환
  factory Room.fromFirestore(Map<String, dynamic> data, String id) {
    return Room(
      id: id,
      name: data['name'] as String,
      roomCode: data['roomCode'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      members:
          (data['members'] as List<dynamic>?)
              ?.map((m) => RoomMember.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 고유 식별자
  final String id;

  /// 방 이름
  final String name;

  /// 6자리 방 코드
  final String roomCode;

  /// 생성 시간
  final DateTime createdAt;

  /// 참가자 목록
  final List<RoomMember> members;

  /// Room 복사본 생성
  Room copyWith({
    String? id,
    String? name,
    String? roomCode,
    DateTime? createdAt,
    List<RoomMember>? members,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      roomCode: roomCode ?? this.roomCode,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }

  /// Room을 Firestore 문서로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'roomCode': roomCode,
      'createdAt': createdAt.toIso8601String(),
      'members': members.map((m) => m.toJson()).toList(),
    };
  }
}

/// 방 참가자 데이터 모델
class RoomMember {
  /// RoomMember 생성자
  const RoomMember({
    required this.name,
    required this.avatarColor,
    required this.joinedAt,
  });

  /// JSON을 RoomMember로 변환
  factory RoomMember.fromJson(Map<String, dynamic> json) {
    return RoomMember(
      name: json['name'] as String,
      avatarColor: json['avatarColor'] as int,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  /// 참가자 이름
  final String name;

  /// 아바타 색상
  final int avatarColor;

  /// 참가 시간
  final DateTime joinedAt;

  /// RoomMember를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarColor': avatarColor,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}
