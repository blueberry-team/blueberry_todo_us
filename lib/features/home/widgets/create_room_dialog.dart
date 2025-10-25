import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/core/themes/app_typography.dart';
import 'package:template/features/home/controllers/room_controller.dart';

/// 방 생성 다이얼로그를 표시합니다.
Future<dynamic> showCreateRoomDialog(BuildContext context, WidgetRef ref) {
  return showDialog(
    context: context,
    builder: (context) => const CreateRoomDialog(),
  );
}

/// 방 생성 다이얼로그
class CreateRoomDialog extends ConsumerStatefulWidget {
  /// CreateRoomDialog 생성자
  const CreateRoomDialog({super.key});

  @override
  ConsumerState<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends ConsumerState<CreateRoomDialog> {
  final _roomNameController = TextEditingController();
  final _memberNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _roomNameController.dispose();
    _memberNameController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final roomName = _roomNameController.text.trim();
    final memberName = _memberNameController.text.trim();

    if (roomName.isEmpty || memberName.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = ref.read(roomControllerProvider);
      final room = await controller.createRoom(
        roomName: roomName,
        memberName: memberName,
      );

      if (mounted) {
        Navigator.of(context).pop(room);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create room: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
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
        'Create New Project',
        style: AppTypography.title.copyWith(color: colors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _roomNameController,
            decoration: InputDecoration(
              labelText: 'Project Name',
              labelStyle: TextStyle(color: colors.textSecondary),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _memberNameController,
            decoration: InputDecoration(
              labelText: 'Your Name',
              labelStyle: TextStyle(color: colors.textSecondary),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
            enabled: !_isLoading,
          ),
        ],
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
          onPressed: _isLoading ? null : _createRoom,
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
              : const Text('Create'),
        ),
      ],
    );
  }
}
