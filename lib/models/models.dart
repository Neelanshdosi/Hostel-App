
// User Model
class User {
  final int id;
  final String username;
  final String name;
  final String role;
  final String roomNumber;
  // hostelBlock removed from UI usage but kept for backward compatibility
  String? hostelBlock;
  final String phoneNumber;
  final String emergencyContact;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    required this.roomNumber,
    this.hostelBlock,
    required this.phoneNumber,
    required this.emergencyContact,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      role: json['role'],
      roomNumber: json['roomNumber'] ?? '',
      hostelBlock: json['hostelBlock'],
      phoneNumber: json['phoneNumber'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
      'roomNumber': roomNumber,
      'hostelBlock': hostelBlock,
      'phoneNumber': phoneNumber,
      'emergencyContact': emergencyContact,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? name,
    String? role,
    String? roomNumber,
    String? hostelBlock,
    String? phoneNumber,
    String? emergencyContact,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      role: role ?? this.role,
      roomNumber: roomNumber ?? this.roomNumber,
      hostelBlock: hostelBlock ?? this.hostelBlock,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }
}

// Complaint Model
class Complaint {
  final String id;
  final int userId;
  final String userName;
  final String title;
  final String description;
  final ComplaintCategory category;
  final ComplaintStatus status;
  final DateTime createdAt;
  final String? imagePath;
  final String? wardenComment;

  Complaint({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.imagePath,
    this.wardenComment,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      title: json['title'],
      description: json['description'],
      category: ComplaintCategory.values.firstWhere(
        (e) => e.toString() == 'ComplaintCategory.${json['category']}',
        orElse: () => ComplaintCategory.other,
      ),
      status: ComplaintStatus.values.firstWhere(
        (e) => e.toString() == 'ComplaintStatus.${json['status']}',
        orElse: () => ComplaintStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      imagePath: json['imagePath'],
      wardenComment: json['wardenComment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'wardenComment': wardenComment,
    };
  }

  Complaint copyWith({
    String? id,
    int? userId,
    String? userName,
    String? title,
    String? description,
    ComplaintCategory? category,
    ComplaintStatus? status,
    DateTime? createdAt,
    String? imagePath,
    String? wardenComment,
  }) {
    return Complaint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      wardenComment: wardenComment ?? this.wardenComment,
    );
  }
}

// Complaint Category Enum
enum ComplaintCategory {
  electrical,
  plumbing,
  cleanliness,
  menuRelated,
  other,
}

// Complaint Status Enum
enum ComplaintStatus {
  pending,
  resolved,
}

// Extension for category display
extension ComplaintCategoryExtension on ComplaintCategory {
  String get displayName {
    switch (this) {
      case ComplaintCategory.electrical:
        return 'Electrical';
      case ComplaintCategory.plumbing:
        return 'Plumbing';
      case ComplaintCategory.cleanliness:
        return 'Cleanliness';
      case ComplaintCategory.menuRelated:
        return 'Menu Related Issue';
      case ComplaintCategory.other:
        return 'Other';
    }
  }
}

// Lost & Found Item Model
class LostFoundItem {
  final String id;
  final int userId;
  final String userName;
  final String caption;
  final String imagePath;
  final DateTime createdAt;

  LostFoundItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.caption,
    required this.imagePath,
    required this.createdAt,
  });

  factory LostFoundItem.fromJson(Map<String, dynamic> json) {
    return LostFoundItem(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      caption: json['caption'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'caption': caption,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Daily Menu Model
class DailyMenu {
  final String dateKey; // yyyy-MM-dd
  final String breakfast;
  final String lunch;
  final String snacks;
  final String dinner;
  final String todaysUpdate;
  final String? imagePath;

  DailyMenu({
    required this.dateKey,
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
    required this.todaysUpdate,
    this.imagePath,
  });

  factory DailyMenu.fromJson(Map<String, dynamic> json) {
    return DailyMenu(
      dateKey: json['dateKey'],
      breakfast: json['breakfast'] ?? '',
      lunch: json['lunch'] ?? '',
      snacks: json['snacks'] ?? '',
      dinner: json['dinner'] ?? '',
      todaysUpdate: json['todaysUpdate'] ?? '',
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'breakfast': breakfast,
      'lunch': lunch,
      'snacks': snacks,
      'dinner': dinner,
      'todaysUpdate': todaysUpdate,
      'imagePath': imagePath,
    };
  }

  DailyMenu copyWith({
    String? breakfast,
    String? lunch,
    String? snacks,
    String? dinner,
    String? todaysUpdate,
    String? imagePath,
  }) {
    return DailyMenu(
      dateKey: dateKey,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      snacks: snacks ?? this.snacks,
      dinner: dinner ?? this.dinner,
      todaysUpdate: todaysUpdate ?? this.todaysUpdate,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

// Extension for status display
extension ComplaintStatusExtension on ComplaintStatus {
  String get displayName {
    switch (this) {
      case ComplaintStatus.pending:
        return 'Pending';
      case ComplaintStatus.resolved:
        return 'Resolved';
    }
  }
}