import 'dart:convert';
import 'package:equatable/equatable.dart';

/// A model class representing a user
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final List<String> favoriteProductIds;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.favoriteProductIds = const [],
    DateTime? createdAt,
    this.lastLoginAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    photoUrl,
    favoriteProductIds,
    createdAt,
    lastLoginAt,
  ];

  /// Convert the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'favoriteProductIds': favoriteProductIds,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  /// Create a model from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      favoriteProductIds: List<String>.from(json['favoriteProductIds'] ?? []),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastLoginAt:
          json['lastLoginAt'] != null
              ? DateTime.parse(json['lastLoginAt'])
              : null,
    );
  }

  /// Convert the model to a JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create a model from a JSON string
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  /// Create a copy of this UserModel with the given fields replaced
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    List<String>? favoriteProductIds,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Create a mock user for testing
  static UserModel mockUser() {
    return UserModel(
      id: '1',
      name: 'Ahmed Mohamed',
      email: 'ahmed@example.com',
      phoneNumber: '+201234567890',
      photoUrl: null,
      favoriteProductIds: ['1', '3', '5'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
    );
  }
}
