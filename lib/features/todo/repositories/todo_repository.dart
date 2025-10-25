import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/todo/models/todo_item.dart';

/// TodoRepository Provider
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

/// Todo 데이터의 Firestore CRUD 작업을 담당하는 Repository
///
/// Firestore의 'todos' 컬렉션과 상호작용합니다.
class TodoRepository {
  /// TodoRepository 생성자
  TodoRepository() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Firestore todos 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _todosCollection =>
      _firestore.collection('todos');

  /// 모든 할일 목록을 실시간으로 스트리밍합니다.
  ///
  /// Firestore의 변경사항을 실시간으로 감지하여 반환합니다.
  Stream<List<TodoItem>> watchTodos() {
    return _todosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TodoItem.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  /// 새로운 할일을 추가합니다.
  ///
  /// Firestore에 새 문서를 생성하고 생성된 문서의 ID를 반환합니다.
  Future<String> addTodo(TodoItem item) async {
    final docRef = await _todosCollection.add(item.toFirestore());
    return docRef.id;
  }

  /// 할일을 업데이트합니다.
  ///
  /// [id]에 해당하는 문서를 [item]의 데이터로 업데이트합니다.
  Future<void> updateTodo(String id, TodoItem item) async {
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
  Future<TodoItem?> getTodo(String id) async {
    final doc = await _todosCollection.doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return TodoItem.fromFirestore(doc.data()!, doc.id);
  }
}
