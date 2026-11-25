import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:equatable/equatable.dart';

// Authenticated user model mapped to users/{uid} and userPrivate/{uid}.
class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.publicId,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? publicId;

  // Build from Firestore users/{uid} document.
  factory UserModel.fromJson(Map<String, dynamic> json, {String email = ''}) {
    return UserModel(
      uid: (json[FirebaseConstants.fieldUid] ?? json['id'] ?? '').toString(),
      name: (json[FirebaseConstants.fieldName] ?? '').toString(),
      email: email,
      photoUrl: json[FirebaseConstants.fieldPhotoUrl]?.toString(),
      publicId: json[FirebaseConstants.fieldPublicId]?.toString(),
    );
  }

  // Public profile fields stored in users/{uid}.
  Map<String, dynamic> toUserJson() => {
        FirebaseConstants.fieldUid: uid,
        FirebaseConstants.fieldName: name,
        FirebaseConstants.fieldPhotoUrl: photoUrl,
      };

  // Private fields stored in userPrivate/{uid}.
  Map<String, dynamic> toPrivateJson() => {
        FirebaseConstants.fieldEmail: email,
      };

  @override
  List<Object?> get props => [uid, name, email, photoUrl, publicId];
}
