import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'app_user.freezed.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    required String fullName,
    required String phone,
    required String community,
    required UserStatus status,
    required DateTime createdAt,
  }) = _AppUser;

  /// Cria um [AppUser] a partir de um documento Firestore.
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: data['uid'] as String,
      email: data['email'] as String,
      fullName: data['fullName'] as String,
      phone: data['phone'] as String,
      community: data['community'] as String,
      status: UserStatus.values.byName(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

extension AppUserFirestore on AppUser {
  /// Converte o [AppUser] para um mapa compatível com Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'community': community,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
