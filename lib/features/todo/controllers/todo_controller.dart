import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/todo/models/todo_item.dart';

/// 할일 기능의 상태를 관리하는 Provider
final todoProvider = NotifierProvider<TodoController, List<TodoItem>>(
  TodoController.new,
);

/// 할일 항목을 관리하는 컨트롤러
///
/// 추가, 삭제, 완료 상태 변경 기능을 제공합니다.
class TodoController extends Notifier<List<TodoItem>> {
  @override
  List<TodoItem> build() {
    // 초기 샘플 데이터
    return [
      const TodoItem(
        id: '1',
        title: 'Design the new onboarding flow',
        isCompleted: true,
        completedBy: User(
          name: 'Sarah',
          avatarColor: 0xFFEF701E,
        ),
      ),
      const TodoItem(
        id: '2',
        title: 'Develop the main feature',
      ),
      const TodoItem(
        id: '3',
        title: 'Write the documentation',
      ),
      const TodoItem(
        id: '4',
        title: 'Review the pull request',
        isCompleted: true,
        completedBy: User(
          name: 'Mike',
          avatarColor: 0xFF33370F,
        ),
      ),
    ];
  }

  /// 새로운 할 일을 추가합니다.
  ///
  /// [title]이 비어있으면 추가하지 않습니다.
  void add(String title) {
    if (title.isEmpty) {
      return;
    }

    final newItem = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );

    state = [...state, newItem];
  }

  /// 할 일의 완료 상태를 토글합니다.
  ///
  /// [id]에 해당하는 항목을 찾아 완료 상태를 변경합니다.
  /// [user]가 제공되면 완료한 사용자 정보를 저장합니다.
  void toggle(String id, {User? user}) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            isCompleted: !item.isCompleted,
            completedBy: !item.isCompleted ? user : null,
          )
        else
          item,
    ];
  }

  /// 할 일을 삭제합니다.
  ///
  /// [id]에 해당하는 항목을 리스트에서 제거합니다.
  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}
