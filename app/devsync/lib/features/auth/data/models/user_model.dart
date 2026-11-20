import 'package:devsync/core/services/firebase/firebase_constants.dart';

/// App-level user.
/// `users/{uid}`        -> uid, name, photoUrl, publicId, createdAt, updatedAt
/// `userPrivate/{uid}`  -> email
class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.publicId,
  });

  /// Firebase Auth uid. Unique per user, also the Firestore document id.
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;

  /// Short shareable id, unique per user (reserved in `publicIds/{publicId}`).
  final String? publicId;

  /// Builds the model from a `users/{uid}` document (FirestoreService adds
  /// the document id under `id`) plus the account email.
  factory UserModel.fromJson(Map<String, dynamic> json, {String email = ''}) {
    return UserModel(
      uid: (json[FirebaseConstants.fieldUid] ?? json['id'] ?? '') as String,
      name: (json[FirebaseConstants.fieldName] ?? '') as String,
      email: email,
      photoUrl: json[FirebaseConstants.fieldPhotoUrl] as String?,
      publicId: json[FirebaseConstants.fieldPublicId] as String?,
    );
  }

  /// Fields stored in `users/{uid}` (timestamps and publicId are added by
  /// the repo when the profile is created).
  Map<String, dynamic> toUserJson() => {
        FirebaseConstants.fieldUid: uid,
        FirebaseConstants.fieldName: name,
        FirebaseConstants.fieldPhotoUrl: photoUrl,
      };

  /// Fields stored in `userPrivate/{uid}`.
  Map<String, dynamic> toPrivateJson() => {
        FirebaseConstants.fieldEmail: email,
      };
}
