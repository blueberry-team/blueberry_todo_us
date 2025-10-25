import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/core/themes/app_typography.dart';
import 'package:template/features/home/widgets/create_room_dialog.dart';
import 'package:template/features/home/widgets/join_room_dialog.dart';
import 'package:template/features/todous/screens/shared_todo_list_screen.dart';
import 'package:template/features/user_profile/controllers/user_profile_controller.dart';

/// Home 스크린
class HomeScreen extends ConsumerWidget {
  /// HomeScreen 생성자
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 로고 + 타이틀
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 58,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TODOUS',
                          style: AppTypography.heading.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 27),

                    // 이미지 영역 (임시)
                    Container(
                      width: 384,
                      height: 200,
                      color: colors.background,
                    ),
                    const SizedBox(height: 32),

                    // 제목
                    Text(
                      'Welcome to Your Shared TODO',
                      style: AppTypography.heading.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // 설명
                    Text(
                      'Create or join a TODO to start collaborating with your team.',
                      style: AppTypography.body.copyWith(
                        color: colors.textTertiary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // 사용자 닉네임 표시
                    userProfileAsync.when(
                      data: (profile) => profile != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(profile.avatarColor),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  profile.nickname,
                                  style: AppTypography.body.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text(
                        'Failed to load profile',
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 버튼들
                    SizedBox(
                      width: 320,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                final room = await showCreateRoomDialog(
                                  context,
                                  ref,
                                );
                                if (room != null && context.mounted) {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SharedTodoListScreen(),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Create New Project',
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                  letterSpacing: 0.24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () async {
                                final room = await showJoinRoomDialog(
                                  context,
                                  ref,
                                );
                                if (room != null && context.mounted) {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SharedTodoListScreen(),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.primary,
                                side: BorderSide(color: colors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Join Existing Project',
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                  letterSpacing: 0.24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
