/// TodoItem 데이터 모델
class TodoItem {
  /// TodoItem 생성자
  const TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedBy,
  });

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
}

/// 사용자 데이터 모델
class User {
  /// User 생성자
  const User({
    required this.name,
    required this.avatarColor,
  });

  /// 사용자 이름
  final String name;

  /// 아바타 색상
  final int avatarColor;
}
