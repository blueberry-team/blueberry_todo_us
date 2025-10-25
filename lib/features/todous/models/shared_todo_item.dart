import 'package:template/features/todo/models/todo_item.dart';

/// 공유 TodoItem 데이터 모델
class SharedTodoItem {
  /// SharedTodoItem 생성자
  const SharedTodoItem({
    required this.id,
    required this.roomId,
    required this.title,
    this.isCompleted = false,
    this.completedBy,
    required this.createdAt,
    this.createdBy,
  });

  /// Firestore 문서를 SharedTodoItem으로 변환
  factory SharedTodoItem.fromFirestore(Map<String, dynamic> data, String id) {
    return SharedTodoItem(
      id: id,
      roomId: data['roomId'] as String,
      title: data['title'] as String,
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedBy: data['completedBy'] != null
          ? User.fromJson(data['completedBy'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(data['createdAt'] as String),
      createdBy: data['createdBy'] != null
          ? User.fromJson(data['createdBy'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 고유 식별자
  final String id;

  /// 방 ID
  final String roomId;

  /// 할 일 제목
  final String title;

  /// 완료 여부
  final bool isCompleted;

  /// 완료한 사용자
  final User? completedBy;

  /// 생성 시간
  final DateTime createdAt;

  /// 생성한 사용자
  final User? createdBy;

  /// SharedTodoItem 복사본 생성
  SharedTodoItem copyWith({
    String? id,
    String? roomId,
    String? title,
    bool? isCompleted,
    User? completedBy,
    DateTime? createdAt,
    User? createdBy,
  }) {
    return SharedTodoItem(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedBy: completedBy ?? this.completedBy,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// SharedTodoItem을 Firestore 문서로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'roomId': roomId,
      'title': title,
      'isCompleted': isCompleted,
      'completedBy': completedBy?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy?.toJson(),
    };
  }
}
