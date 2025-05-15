import 'package:equatable/equatable.dart';

/// Enum representing different payment methods
enum PaymentType { cashOnDelivery, creditCard, paypal, applePay, googlePay }

/// A model class representing a payment method
class PaymentMethodModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final PaymentType type;
  final String? cardNumber;
  final String? cardHolderName;
  final String? expiryDate;
  final bool isDefault;
  final String iconPath;

  PaymentMethodModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.isDefault = false,
    required this.iconPath,
  }) : assert(id.isNotEmpty, 'ID cannot be empty'),
       assert(title.isNotEmpty, 'Title cannot be empty'),
       assert(description.isNotEmpty, 'Description cannot be empty'),
       assert(iconPath.isNotEmpty, 'Icon path cannot be empty');

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    cardNumber,
    cardHolderName,
    expiryDate,
    isDefault,
    iconPath,
  ];

  // Create a copy of this PaymentMethodModel with the given fields replaced
  PaymentMethodModel copyWith({
    String? id,
    String? title,
    String? description,
    PaymentType? type,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    bool? isDefault,
    String? iconPath,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      isDefault: isDefault ?? this.isDefault,
      iconPath: iconPath ?? this.iconPath,
    );
  }

  // Get masked card number (e.g., **** **** **** 1234)
  String get maskedCardNumber {
    if (cardNumber == null || cardNumber!.isEmpty) {
      return '';
    }

    final lastFourDigits =
        cardNumber!.length > 4
            ? cardNumber!.substring(cardNumber!.length - 4)
            : cardNumber;

    return '**** **** **** $lastFourDigits';
  }

  // Get predefined payment methods
  static List<PaymentMethodModel> getPredefinedMethods() {
    return [
      PaymentMethodModel(
        id: 'cod',
        title: 'Cash on Delivery',
        description: 'Pay when you receive your order',
        type: PaymentType.cashOnDelivery,
        isDefault: true,
        iconPath: 'assets/icons/cash.png',
      ),
      PaymentMethodModel(
        id: 'card',
        title: 'Credit/Debit Card',
        description: 'Pay with your card',
        type: PaymentType.creditCard,
        iconPath: 'assets/icons/credit_card.png',
      ),
    ];
  }

  // Convert PaymentMethodModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
      'iconPath': iconPath,
    };
  }

  // Create PaymentMethodModel from JSON
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: PaymentType.values[json['type'] as int],
      cardNumber: json['cardNumber'] as String?,
      cardHolderName: json['cardHolderName'] as String?,
      expiryDate: json['expiryDate'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      iconPath: json['iconPath'] as String,
    );
  }
}
