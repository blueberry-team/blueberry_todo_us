/// 사용자 프로필 데이터 모델
class UserProfile {
  /// UserProfile 생성자
  const UserProfile({
    required this.deviceId,
    required this.nickname,
    required this.avatarColor,
    required this.createdAt,
  });

  /// Firestore 문서를 UserProfile로 변환
  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      deviceId: data['deviceId'] as String,
      nickname: data['nickname'] as String,
      avatarColor: data['avatarColor'] as int,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }

  /// 디바이스 ID
  final String deviceId;

  /// 닉네임 (형용사 + 동물)
  final String nickname;

  /// 아바타 색상
  final int avatarColor;

  /// 생성 시간
  final DateTime createdAt;

  /// UserProfile 복사본 생성
  UserProfile copyWith({
    String? deviceId,
    String? nickname,
    int? avatarColor,
    DateTime? createdAt,
  }) {
    return UserProfile(
      deviceId: deviceId ?? this.deviceId,
      nickname: nickname ?? this.nickname,
      avatarColor: avatarColor ?? this.avatarColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// UserProfile을 Firestore 문서로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'deviceId': deviceId,
      'nickname': nickname,
      'avatarColor': avatarColor,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
