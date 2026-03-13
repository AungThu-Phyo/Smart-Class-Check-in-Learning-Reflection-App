class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String studentId;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.studentId,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'studentId': studentId,
    };
  }
}
