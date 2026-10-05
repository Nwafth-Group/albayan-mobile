// ============================================
// FILE: lib/fatures/cart/data/models/cart_payment_method.dart
// ============================================
//
// The `payment_method` value `POST /reader/cart/checkout` expects
// (`in:apple_pay,google_pay,credit_card,mada,simulated_payment`).

enum CartPaymentMethod {
  applePay,
  googlePay,
  creditCard,
  mada,
  simulatedPayment,
}

extension CartPaymentMethodApiValue on CartPaymentMethod {
  String get apiValue {
    switch (this) {
      case CartPaymentMethod.applePay:
        return 'apple_pay';
      case CartPaymentMethod.googlePay:
        return 'google_pay';
      case CartPaymentMethod.creditCard:
        return 'credit_card';
      case CartPaymentMethod.mada:
        return 'mada';
      case CartPaymentMethod.simulatedPayment:
        return 'simulated_payment';
    }
  }
}
