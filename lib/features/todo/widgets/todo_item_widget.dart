import 'package:flutter/material.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/core/themes/app_typography.dart';
import 'package:template/features/todo/models/todo_item.dart';

/// 할일 항목을 표시하는 위젯
class TodoItemWidget extends StatelessWidget {
  /// TodoItemWidget 생성자
  const TodoItemWidget({
    required this.item,
    this.onToggle,
    super.key,
  });

  /// 표시할 TodoItem
  final TodoItem item;

  /// 완료 상태 토글 콜백
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 체크박스
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: item.isCompleted ? colors.primary : colors.border,
                width: 2,
              ),
              color: item.isCompleted ? colors.primary : Colors.transparent,
            ),
            child: item.isCompleted
                ? Icon(Icons.check, size: 12, color: colors.textPrimary)
                : null,
          ),
        ),
        const SizedBox(width: 12),

        // 내용
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTypography.body.copyWith(
                  color: colors.textPrimary,
                  height: 1.5,
                ),
              ),
              if (item.isCompleted && item.completedBy != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(item.completedBy!.avatarColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Completed by ${item.completedBy!.name}',
                      style: AppTypography.caption.copyWith(
                        color: colors.textTertiary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
