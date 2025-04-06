// lib/models/user_model.dart
import 'package:flutter/foundation.dart' show immutable; // For @immutable

@immutable
class UserModel {
  final String name;
  final String contactNumber;
  final String address;
  final String uid;
  final String email;

  const UserModel({
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.uid,
    required this.email,
  });

  // Creates a copy with potentially updated fields
  UserModel copyWith({
    String? name,
    String? contactNumber,
    String? address,
    String? uid,
    String? email,
  }) {
    return UserModel(
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      uid: uid ?? this.uid,
      email: email ?? this.email,
    );
  }

  // Converts UserModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'contactNumber': contactNumber,
      'address': address,
      'uid': uid,
      'email': email,
    };
  }

  // Creates a UserModel instance from a Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String? ?? '', // Provide default if null
      contactNumber: map['contactNumber'] as String? ?? '',
      address: map['address'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, contactNumber: $contactNumber, address: $address, uid: $uid, email: $email)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
    return other.name == name &&
        other.contactNumber == contactNumber &&
        other.address == address &&
        other.uid == uid &&
        other.email == email;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        contactNumber.hashCode ^
        address.hashCode ^
        uid.hashCode ^
        email.hashCode;
  }
}
