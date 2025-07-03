import 'package:equatable/equatable.dart';

/// A model class representing a course instructor from Tutor LMS
class InstructorModel extends Equatable {
  final String id;
  final String name;
  final String bio;
  final String avatar;
  final String designation;
  final int totalCourses;
  final int totalStudents;
  final double rating;
  final int ratingCount;
  final String email;
  final String phone;
  final String website;
  final Map<String, String> socialLinks;

  const InstructorModel({
    required this.id,
    required this.name,
    this.bio = '',
    this.avatar = '',
    this.designation = '',
    this.totalCourses = 0,
    this.totalStudents = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.email = '',
    this.phone = '',
    this.website = '',
    this.socialLinks = const {},
  });

  /// Create an empty InstructorModel
  factory InstructorModel.empty() {
    return const InstructorModel(
      id: '0',
      name: 'Unknown Instructor',
    );
  }

  /// Create an InstructorModel from a JSON object
  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    // Extract social links if available
    Map<String, String> socialLinks = {};
    if (json['social_links'] != null) {
      final links = json['social_links'] as Map<String, dynamic>;
      links.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          socialLinks[key] = value.toString();
        }
      });
    }

    return InstructorModel(
      id: json['ID']?.toString() ?? '0',
      name: json['display_name'] ?? 'Unknown Instructor',
      bio: json['tutor_profile_bio'] ?? '',
      avatar: json['tutor_avatar'] ?? '',
      designation: json['tutor_job_title'] ?? '',
      totalCourses: json['course_count'] ?? 0,
      totalStudents: json['students_count'] ?? 0,
      rating: json['instructor_rating'] != null 
          ? double.tryParse(json['instructor_rating'].toString()) ?? 0.0 
          : 0.0,
      ratingCount: json['rating_count'] ?? 0,
      email: json['user_email'] ?? '',
      phone: json['phone'] ?? '',
      website: json['user_url'] ?? '',
      socialLinks: socialLinks,
    );
  }

  /// Create a copy of this InstructorModel with the given fields replaced
  InstructorModel copyWith({
    String? id,
    String? name,
    String? bio,
    String? avatar,
    String? designation,
    int? totalCourses,
    int? totalStudents,
    double? rating,
    int? ratingCount,
    String? email,
    String? phone,
    String? website,
    Map<String, String>? socialLinks,
  }) {
    return InstructorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      designation: designation ?? this.designation,
      totalCourses: totalCourses ?? this.totalCourses,
      totalStudents: totalStudents ?? this.totalStudents,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }

  @override
  List<Object> get props => [
    id,
    name,
    bio,
    avatar,
    designation,
    totalCourses,
    totalStudents,
    rating,
    ratingCount,
    email,
    phone,
    website,
    socialLinks,
  ];
}
