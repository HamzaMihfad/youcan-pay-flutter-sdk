import 'ycpay_response.dart';

class YCPResponseCashPlus extends YCPayResponse {
  String token;

  YCPResponseCashPlus({required super.transactionId, required this.token});

  @override
  String toString() {
    return 'YCPResponseCashPlus{transactionId: $transactionId, token: $token}';
  }
}
