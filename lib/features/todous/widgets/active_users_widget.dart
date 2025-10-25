import 'package:flutter/material.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/features/home/models/room.dart';

/// 현재 접속중인 사용자를 표시하는 위젯 (최대 3명)
class ActiveUsersWidget extends StatelessWidget {
  /// ActiveUsersWidget 생성자
  const ActiveUsersWidget({
    required this.members,
    super.key,
  });

  /// 방 참가자 목록
  final List<RoomMember> members;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // 최대 3명까지만 표시
    final displayMembers = members.take(3).toList();

    if (displayMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아바타 스택
        SizedBox(
          width: displayMembers.length == 1
              ? 24
              : 24 + (displayMembers.length - 1) * 16.0,
          height: 24,
          child: Stack(
            children: List.generate(
              displayMembers.length,
              (index) {
                final member = displayMembers[index];
                return Positioned(
                  left: index * 16.0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(member.avatarColor),
                      border: Border.all(
                        color: colors.background,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
