import 'package:equatable/equatable.dart';

/// A model class representing a delivery address
class AddressModel extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;

  AddressModel({
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.zipCode,
    this.isDefault = false,
  }) : assert(fullName.isNotEmpty, 'Full name cannot be empty'),
       assert(phoneNumber.isNotEmpty, 'Phone number cannot be empty'),
       assert(addressLine1.isNotEmpty, 'Address line 1 cannot be empty'),
       assert(city.isNotEmpty, 'City cannot be empty'),
       assert(state.isNotEmpty, 'State cannot be empty'),
       assert(zipCode.isNotEmpty, 'Zip code cannot be empty');

  @override
  List<Object> get props => [
    fullName, 
    phoneNumber, 
    addressLine1, 
    addressLine2, 
    city, 
    state, 
    zipCode,
    isDefault,
  ];
  
  // Create a copy of this AddressModel with the given fields replaced
  AddressModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    bool? isDefault,
  }) {
    return AddressModel(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
  
  // Format the address as a single string
  String get formattedAddress {
    final buffer = StringBuffer();
    buffer.write(addressLine1);
    
    if (addressLine2.isNotEmpty) {
      buffer.write(', $addressLine2');
    }
    
    buffer.write(', $city');
    buffer.write(', $state');
    buffer.write(' $zipCode');
    
    return buffer.toString();
  }
}
