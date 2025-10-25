import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/home/controllers/room_controller.dart';
import 'package:template/features/todo/models/todo_item.dart';
import 'package:template/features/todous/models/shared_todo_item.dart';
import 'package:template/features/todous/repositories/shared_todo_repository.dart';

/// 현재 방의 공유 할일 목록 Provider
final sharedTodoProvider = StreamProvider<List<SharedTodoItem>>((ref) {
  final roomId = ref.watch(currentRoomIdProvider);
  if (roomId == null) {
    return Stream.value([]);
  }
  final repository = ref.watch(sharedTodoRepositoryProvider);
  return repository.watchTodosByRoom(roomId);
});

/// SharedTodoController Provider
final sharedTodoControllerProvider = Provider<SharedTodoController>((ref) {
  return SharedTodoController(ref);
});

/// 공유 할일 항목을 관리하는 컨트롤러
///
/// Firestore와 연동하여 추가, 삭제, 완료 상태 변경 기능을 제공합니다.
class SharedTodoController {
  /// SharedTodoController 생성자
  SharedTodoController(this._ref);

  final Ref _ref;

  /// Repository 참조
  SharedTodoRepository get _repository =>
      _ref.read(sharedTodoRepositoryProvider);

  /// 새로운 할 일을 추가합니다.
  ///
  /// [title] 할 일 제목
  /// [user] 생성자 정보 (선택사항)
  /// [title]이 비어있으면 추가하지 않습니다.
  Future<void> add(String title, {User? user}) async {
    final roomId = _ref.read(currentRoomIdProvider);
    if (roomId == null) {
      throw Exception('No active room');
    }

    if (title.isEmpty) {
      return;
    }

    final newItem = SharedTodoItem(
      id: '', // Firestore가 자동 생성
      roomId: roomId,
      title: title,
      createdAt: DateTime.now(),
      createdBy: user,
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
