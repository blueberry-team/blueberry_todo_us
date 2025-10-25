import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/todous/models/shared_todo_item.dart';

/// SharedTodoRepository Provider
final sharedTodoRepositoryProvider = Provider<SharedTodoRepository>((ref) {
  return SharedTodoRepository();
});

/// 공유 Todo 데이터의 Firestore CRUD 작업을 담당하는 Repository
///
/// Firestore의 'shared_todos' 컬렉션과 상호작용합니다.
class SharedTodoRepository {
  /// SharedTodoRepository 생성자
  SharedTodoRepository() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Firestore shared_todos 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _todosCollection =>
      _firestore.collection('shared_todos');

  /// 특정 방의 모든 할일 목록을 실시간으로 스트리밍합니다.
  ///
  /// [roomId] 방 ID
  /// Firestore의 변경사항을 실시간으로 감지하여 반환합니다.
  Stream<List<SharedTodoItem>> watchTodosByRoom(String roomId) {
    return _todosCollection.where('roomId', isEqualTo: roomId).snapshots().map((
      snapshot,
    ) {
      final items = snapshot.docs.map((doc) {
        return SharedTodoItem.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();

      // 클라이언트에서 생성 시간순으로 정렬
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return items;
    });
  }

  /// 새로운 할일을 추가합니다.
  ///
  /// Firestore에 새 문서를 생성하고 생성된 문서의 ID를 반환합니다.
  Future<String> addTodo(SharedTodoItem item) async {
    final docRef = await _todosCollection.add(item.toFirestore());
    return docRef.id;
  }

  /// 할일을 업데이트합니다.
  ///
  /// [id]에 해당하는 문서를 [item]의 데이터로 업데이트합니다.
  Future<void> updateTodo(String id, SharedTodoItem item) async {
    await _todosCollection.doc(id).update(item.toFirestore());
  }

  /// 할일을 삭제합니다.
  ///
  /// [id]에 해당하는 문서를 Firestore에서 삭제합니다.
  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }

  /// 특정 할일을 조회합니다.
  ///
  /// [id]에 해당하는 문서를 조회하여 반환합니다.
  Future<SharedTodoItem?> getTodo(String id) async {
    final doc = await _todosCollection.doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return SharedTodoItem.fromFirestore(doc.data()!, doc.id);
  }
}
