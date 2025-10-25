import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/core/services/nickname_generator.dart';
import 'package:template/features/user_profile/models/user_profile.dart';
import 'package:template/features/user_profile/repositories/user_profile_repository.dart';

/// 현재 사용자 프로필 Provider
final currentUserProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);

/// 사용자 프로필을 관리하는 Notifier
class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  static const _nicknameGenerator = NicknameGenerator();

  @override
  Future<UserProfile?> build() async {
    // 디바이스 ID 가져오기
    final deviceId = await _getDeviceId();

    // Firestore에서 기존 프로필 찾기
    final repository = ref.read(userProfileRepositoryProvider);
    var profile = await repository.findByDeviceId(deviceId);

    // 프로필이 없으면 새로 생성
    if (profile == null) {
      profile = await _createNewProfile(deviceId, repository);
    }

    return profile;
  }

  /// 디바이스 고유 ID를 가져옵니다.
  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? _generateFallbackId();
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      } else if (Platform.isMacOS) {
        final macosInfo = await deviceInfo.macOsInfo;
        return macosInfo.systemGUID ?? _generateFallbackId();
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.machineId ?? _generateFallbackId();
      } else {
        // 웹 또는 기타 플랫폼
        return _generateFallbackId();
      }
    } on Exception catch (e) {
      // ignore: avoid_print
      print('Error getting device ID: $e');
      return _generateFallbackId();
    }
  }

  /// 폴백 디바이스 ID 생성
  String _generateFallbackId() {
    final random = Random();
    return 'fallback_${random.nextInt(1000000)}';
  }

  /// 랜덤 아바타 색상 생성
  int _generateRandomColor() {
    final random = Random();
    const colors = [
      0xFFE57373, // Red
      0xFFBA68C8, // Purple
      0xFF64B5F6, // Blue
      0xFF4DD0E1, // Cyan
      0xFF81C784, // Green
      0xFFFFD54F, // Amber
      0xFFFF8A65, // Deep Orange
      0xFF90A4AE, // Blue Grey
    ];
    return colors[random.nextInt(colors.length)];
  }

  /// 새로운 사용자 프로필 생성
  Future<UserProfile> _createNewProfile(
    String deviceId,
    UserProfileRepository repository,
  ) async {
    final nickname = _nicknameGenerator.generateFromDeviceId(deviceId);
    final avatarColor = _generateRandomColor();

    final profile = UserProfile(
      deviceId: deviceId,
      nickname: nickname,
      avatarColor: avatarColor,
      createdAt: DateTime.now(),
    );

    await repository.create(profile);
    return profile;
  }

  /// 닉네임 변경
  Future<void> updateNickname(String newNickname) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    state = const AsyncValue.loading();

    try {
      final updatedProfile = currentProfile.copyWith(nickname: newNickname);
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.update(currentProfile.deviceId, updatedProfile);

      state = AsyncValue.data(updatedProfile);
    } on Exception catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 프로필 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
