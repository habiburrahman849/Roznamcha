import 'package:roznamcha/core/constants/app_strings.dart';

enum EntryType {
  sale('SALE'),
  purchase('PURCHASE');

  const EntryType(this.storageValue);

  final String storageValue;

  String get label => this == EntryType.sale ? AppStrings.sale : AppStrings.purchase;

  static EntryType fromStorage(String value) {
    return EntryType.values.firstWhere((type) => type.storageValue == value);
  }
}

enum PaymentType {
  cash('CASH'),
  bank('BANK');

  const PaymentType(this.storageValue);

  final String storageValue;

  String get label => this == PaymentType.cash ? AppStrings.cash : AppStrings.bank;

  static PaymentType fromStorage(String value) {
    return PaymentType.values.firstWhere((type) => type.storageValue == value);
  }
}
