import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/core/themes/app_typography.dart';
import 'package:template/features/todo/controllers/todo_controller.dart';
import 'package:template/features/todo/widgets/todo_item_widget.dart';

/// TodoList 스크린
class TodoListScreen extends ConsumerWidget {
  /// TodoListScreen 생성자
  const TodoListScreen({super.key});

  /// 할일 추가 다이얼로그를 표시합니다.
  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final colors = context.colors;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Task',
          style: AppTypography.title.copyWith(
            color: colors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter task title',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              ref.read(todoControllerProvider).add(value);
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                ref.read(todoControllerProvider).add(title);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final todosAsync = ref.watch(todoProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          // 헤더
          Container(
            color: colors.background,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Team Projects',
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: -0.27,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share, size: 16),
                  label: Text(
                    'Share Link',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      letterSpacing: 0.21,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 할일 리스트
          Expanded(
            child: todosAsync.when(
              data: (todos) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                itemCount: todos.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return TodoItemWidget(
                    item: todo,
                    onToggle: () {
                      ref.read(todoControllerProvider).toggle(todo.id);
                    },
                  );
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(color: colors.error),
                ),
              ),
            ),
          ),

          // FAB 영역
          Padding(
            padding: const EdgeInsets.all(20),
            child: FloatingActionButton(
              onPressed: () => _showAddTodoDialog(context, ref),
              backgroundColor: colors.primary,
              child: const Icon(Icons.add, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
