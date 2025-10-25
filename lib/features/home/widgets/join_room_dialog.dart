import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/core/themes/app_typography.dart';
import 'package:template/features/home/controllers/room_controller.dart';
import 'package:template/features/user_profile/controllers/user_profile_controller.dart';

/// 방 참가 다이얼로그를 표시합니다.
Future<dynamic> showJoinRoomDialog(BuildContext context, WidgetRef ref) {
  return showDialog(
    context: context,
    builder: (context) => const JoinRoomDialog(),
  );
}

/// 방 참가 다이얼로그
class JoinRoomDialog extends ConsumerStatefulWidget {
  /// JoinRoomDialog 생성자
  const JoinRoomDialog({super.key});

  @override
  ConsumerState<JoinRoomDialog> createState() => _JoinRoomDialogState();
}

class _JoinRoomDialogState extends ConsumerState<JoinRoomDialog> {
  final _roomCodeController = TextEditingController();
  var _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text.trim();

    if (roomCode.isEmpty) {
      return;
    }

    // 사용자 프로필 가져오기
    final userProfile = ref.read(currentUserProfileProvider).value;
    if (userProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading user profile...')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(roomControllerProvider);
      final room = await controller.joinRoomByCode(
        roomCode: roomCode,
        memberName: userProfile.nickname,
        avatarColor: userProfile.avatarColor,
      );

      if (room == null) {
        setState(() {
          _errorMessage = 'Room not found. Please check the room code.';
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        Navigator.of(context).pop(room);
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to join room: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      title: Text(
        'Join Existing Project',
        style: AppTypography.title.copyWith(color: colors.textPrimary),
      ),
      content: TextField(
        controller: _roomCodeController,
        decoration: InputDecoration(
          labelText: 'Room Code (6 digits)',
          labelStyle: TextStyle(color: colors.textSecondary),
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
          ),
          errorText: _errorMessage,
        ),
        keyboardType: TextInputType.number,
        maxLength: 6,
        enabled: !_isLoading,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _joinRoom,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.textPrimary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Join'),
        ),
      ],
    );
  }
}
