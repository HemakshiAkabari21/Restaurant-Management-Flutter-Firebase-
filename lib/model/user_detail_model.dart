class UserDetail {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String userType;
  final String createdAt;

  UserDetail({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.userType,
    required this.createdAt,
  });

  /// Convert Firebase map → Model
  factory UserDetail.fromMap(String id, Map<dynamic, dynamic> map) {
    return UserDetail(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      password: map['password'] ?? '',
      userType: map['user_type'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  /// Convert Model → Firebase map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
      'user_type': userType,
      'createdAt': createdAt,
    };
  }

  UserDetail copyWith({String? id}) {
    return UserDetail(
      id: id ?? this.id,
      name: name,
      email: email,
      mobile: mobile,
      password: password,
      userType: userType,
      createdAt: createdAt,
    );
  }
}
