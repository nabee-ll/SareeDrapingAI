import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Razorpay payment service for handling UPI and card payments securely.
/// Replace [kRazorpayKeyId] with your actual Razorpay key from the dashboard.
/// NOTE: Razorpay is not supported on web — payments are disabled on web.
class PaymentService {
  static const String kRazorpayKeyId = 'rzp_test_XXXXXXXXXXXXXXXX'; // 🔐 Replace with live key in production

  Razorpay? _razorpay;

  /// Callbacks provided by the caller
  final void Function(PaymentSuccessResponse) onSuccess;
  final void Function(PaymentFailureResponse) onFailure;
  final void Function(ExternalWalletResponse) onExternalWallet;

  PaymentService({
    required this.onSuccess,
    required this.onFailure,
    required this.onExternalWallet,
  }) {
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    }
  }

  /// Opens the Razorpay checkout for purchasing credit packs.
  ///
  /// [amountInPaise] — total amount in paise (₹1 = 100 paise).
  /// [description]   — shown on the payment sheet.
  /// [userName]      — pre-fill the customer name.
  /// [userEmail]     — pre-fill the customer email.
  /// [userPhone]     — pre-fill the customer phone (with country code).
  /// [orderId]       — optional server-generated Razorpay order ID for signature
  ///                   verification (strongly recommended in production).
  void openCreditCheckout({
    required int amountInPaise,
    required String description,
    String userName = '',
    String userEmail = '',
    String userPhone = '',
    String? orderId,
  }) {
    final options = <String, dynamic>{
      'key': kRazorpayKeyId,
      'amount': amountInPaise,
      'name': 'SareeDraping AI',
      'description': description,
      'currency': 'INR',
      'prefill': {
        'name': userName,
        'email': userEmail,
        'contact': userPhone,
      },
      'method': {
        'upi': true,
        'netbanking': true,
        'card': true,
        'wallet': true,
      },
      // UPI intent apps displayed on the sheet
      'config': {
        'display': {
          'blocks': {
            'utib': {
              'name': 'Pay via UPI',
              'instruments': [
                {'method': 'upi'},
              ],
            },
          },
          'sequence': ['block.utib'],
          'preferences': {'show_default_blocks': true},
        },
      },
      'theme': {'color': '#8B2252'}, // Burgundy brand colour
    };
    if (orderId != null) options['order_id'] = orderId;

    if (kIsWeb) {
      debugPrint('PaymentService: Razorpay is not supported on web.');
      return;
    }

    try {
      _razorpay!.open(options);
    } catch (e) {
      debugPrint('PaymentService error: $e');
    }
  }

  /// Must be called when the hosting widget is disposed.
  void dispose() {
    _razorpay?.clear();
  }
}
