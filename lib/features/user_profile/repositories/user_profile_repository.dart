import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/user_profile/models/user_profile.dart';

/// UserProfileRepository Provider
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

/// 사용자 프로필 데이터의 Firestore CRUD 작업을 담당하는 Repository
///
/// Firestore의 'user_profiles' 컬렉션과 상호작용합니다.
class UserProfileRepository {
  /// UserProfileRepository 생성자
  UserProfileRepository() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Firestore user_profiles 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _profilesCollection =>
      _firestore.collection('user_profiles');

  /// 디바이스 ID로 사용자 프로필을 찾습니다.
  ///
  /// [deviceId] 디바이스 고유 ID
  /// 프로필을 찾으면 UserProfile 객체를, 찾지 못하면 null을 반환합니다.
  Future<UserProfile?> findByDeviceId(String deviceId) async {
    try {
      final querySnapshot = await _profilesCollection
          .where('deviceId', isEqualTo: deviceId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return UserProfile.fromFirestore(doc.data());
    } on Exception catch (e) {
      // ignore: avoid_print
      print('Error finding user profile: $e');
      return null;
    }
  }

  /// 새로운 사용자 프로필을 생성합니다.
  ///
  /// [profile] 생성할 사용자 프로필
  /// 생성된 문서의 ID를 반환합니다.
  Future<String> create(UserProfile profile) async {
    try {
      final data = profile.toFirestore();
      // ignore: avoid_print
      print('Creating user profile: $data');

      final docRef = await _profilesCollection.add(data);
      // ignore: avoid_print
      print('User profile created with ID: ${docRef.id}');

      return docRef.id;
    } on Exception catch (e) {
      // ignore: avoid_print
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  /// 사용자 프로필을 업데이트합니다.
  ///
  /// [deviceId] 디바이스 ID
  /// [profile] 업데이트할 프로필 데이터
  Future<void> update(String deviceId, UserProfile profile) async {
    try {
      final querySnapshot = await _profilesCollection
          .where('deviceId', isEqualTo: deviceId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User profile not found');
      }

      final docId = querySnapshot.docs.first.id;
      await _profilesCollection.doc(docId).update(profile.toFirestore());
    } on Exception catch (e) {
      // ignore: avoid_print
      print('Error updating user profile: $e');
      rethrow;
    }
  }
}
