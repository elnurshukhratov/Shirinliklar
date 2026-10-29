enum PaymentStatus {
  unpaid('UNPAID'),
  paid('PAID'),
  refunded('REFUNDED');

  const PaymentStatus(this.api);
  final String api;

  static PaymentStatus fromApi(String? v) =>
      PaymentStatus.values.firstWhere((e) => e.api == v, orElse: () => PaymentStatus.unpaid);
}
