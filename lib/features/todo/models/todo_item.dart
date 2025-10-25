/// TodoItem 데이터 모델
class TodoItem {
  /// TodoItem 생성자
  const TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedBy,
  });

  /// Firestore 문서를 TodoItem으로 변환
  factory TodoItem.fromFirestore(Map<String, dynamic> data, String id) {
    return TodoItem(
      id: id,
      title: data['title'] as String,
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedBy: data['completedBy'] != null
          ? User.fromJson(data['completedBy'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 고유 식별자
  final String id;

  /// 할 일 제목
  final String title;

  /// 완료 여부
  final bool isCompleted;

  /// 완료한 사용자
  final User? completedBy;

  /// TodoItem 복사본 생성
  TodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    User? completedBy,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedBy: completedBy ?? this.completedBy,
    );
  }

  /// TodoItem을 Firestore 문서로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'completedBy': completedBy?.toJson(),
    };
  }
}

/// 사용자 데이터 모델
class User {
  /// User 생성자
  const User({
    required this.name,
    required this.avatarColor,
  });

  /// JSON을 User로 변환
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      avatarColor: json['avatarColor'] as int,
    );
  }

  /// 사용자 이름
  final String name;

  /// 아바타 색상
  final int avatarColor;

  /// User를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarColor': avatarColor,
    };
  }
}
