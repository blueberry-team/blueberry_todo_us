import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/todo/models/todo_item.dart';
import 'package:template/features/todo/repositories/todo_repository.dart';

/// 할일 기능의 상태를 관리하는 Provider
final todoProvider = StreamProvider<List<TodoItem>>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return repository.watchTodos();
});

/// 할일 항목을 관리하는 컨트롤러 Provider
final todoControllerProvider = Provider<TodoController>((ref) {
  return TodoController(ref);
});

/// 할일 항목을 관리하는 컨트롤러
///
/// Firestore와 연동하여 추가, 삭제, 완료 상태 변경 기능을 제공합니다.
class TodoController {
  /// TodoController 생성자
  TodoController(this._ref);

  final Ref _ref;

  /// Repository 참조
  TodoRepository get _repository => _ref.read(todoRepositoryProvider);

  /// 새로운 할 일을 추가합니다.
  ///
  /// [title]이 비어있으면 추가하지 않습니다.
  Future<void> add(String title) async {
    if (title.isEmpty) {
      return;
    }

    final newItem = TodoItem(
      id: '', // Firestore가 자동 생성
      title: title,
    );

    await _repository.addTodo(newItem);
  }

  /// 할 일의 완료 상태를 토글합니다.
  ///
  /// [id]에 해당하는 항목을 찾아 완료 상태를 변경합니다.
  /// [user]가 제공되면 완료한 사용자 정보를 저장합니다.
  Future<void> toggle(String id, {User? user}) async {
    final todo = await _repository.getTodo(id);
    if (todo == null) {
      return;
    }

    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      completedBy: !todo.isCompleted ? user : null,
    );

    await _repository.updateTodo(id, updated);
  }

  /// 할 일을 삭제합니다.
  ///
  /// [id]에 해당하는 항목을 Firestore에서 삭제합니다.
  Future<void> remove(String id) async {
    await _repository.deleteTodo(id);
  }
}
