import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/core/themes/app_typography.dart';
import 'package:template/features/home/controllers/room_controller.dart';
import 'package:template/features/todous/controllers/shared_todo_controller.dart';
import 'package:template/features/todous/widgets/active_users_widget.dart';
import 'package:template/features/todous/widgets/shared_todo_item_widget.dart';

/// 공유 TodoList 스크린
class SharedTodoListScreen extends ConsumerWidget {
  /// SharedTodoListScreen 생성자
  const SharedTodoListScreen({super.key});

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
              ref.read(sharedTodoControllerProvider).add(value);
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
                ref.read(sharedTodoControllerProvider).add(title);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// 방 코드 공유 다이얼로그를 표시합니다.
  void _showShareDialog(BuildContext context, String roomCode) {
    final colors = context.colors;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Share Room Code',
          style: AppTypography.title.copyWith(
            color: colors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share this code with your team members:',
              style: AppTypography.body.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    roomCode,
                    style: AppTypography.heading.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: roomCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room code copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final todosAsync = ref.watch(sharedTodoProvider);
    final roomAsync = ref.watch(currentRoomProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: roomAsync.when(
          data: (room) => Text(
            room?.name ?? 'Shared TODO',
            style: AppTypography.title.copyWith(
              color: colors.textPrimary,
            ),
          ),
          loading: () => const Text('Loading...'),
          error: (_, _) => const Text('Error'),
        ),
      ),
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
                Row(
                  children: [
                    // 활성 사용자 표시
                    roomAsync.when(
                      data: (room) => room != null && room.members.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ActiveUsersWidget(members: room.members),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    // 공유 버튼
                    roomAsync.when(
                      data: (room) => OutlinedButton.icon(
                        onPressed: room != null
                            ? () => _showShareDialog(context, room.roomCode)
                            : null,
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
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 할일 리스트
          Expanded(
            child: todosAsync.when(
              data: (todos) {
                if (todos.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks yet. Add one!',
                      style: AppTypography.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  itemCount: todos.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return SharedTodoItemWidget(
                      item: todo,
                      onToggle: () {
                        ref.read(sharedTodoControllerProvider).toggle(todo.id);
                      },
                    );
                  },
                );
              },
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
