import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String name;
  final String gstNumber;
  final String addressLine1;
  final String addressLine2;
  final String phoneNumber;
  final String upiId;
  final String footerText;

  const Shop({
    this.name = '',
    this.gstNumber = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.phoneNumber = '',
    this.upiId = '',
    this.footerText = '',
  });

  Shop copyWith({
    String? name,
    String? gstNumber,
    String? addressLine1,
    String? addressLine2,
    String? phoneNumber,
    String? upiId,
    String? footerText,
  }) {
    return Shop(
      name: name ?? this.name,
      gstNumber: gstNumber ?? this.gstNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      upiId: upiId ?? this.upiId,
      footerText: footerText ?? this.footerText,
    );
  }

  @override
  List<Object?> get props =>
      [name, gstNumber, addressLine1, addressLine2, phoneNumber, upiId, footerText];
}
