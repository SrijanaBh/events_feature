

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:http/http.dart' as http;

class PayUPaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String productName;
  final String userName;
  final String userEmail;
  final String userPhone;

  const PayUPaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.productName,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<PayUPaymentScreen> createState() => _PayUPaymentScreenState();
}

class _PayUPaymentScreenState extends State<PayUPaymentScreen>
    implements PayUCheckoutProProtocol {
  late PayUCheckoutProFlutter _payu;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // pass `this` so SDK can call protocol callbacks (generateHash, onPaymentSuccess ...)
    _payu = PayUCheckoutProFlutter(this);
  }

  Future<void> _startPayUPayment() async {
    setState(() => _isLoading = true);

    try {
      final resp = await http.post(
        Uri.parse('https://yourserver.com/api/payu/generate-hash'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "txnid": widget.orderId,
          "amount": widget.amount.toString(),
          "productinfo": widget.productName,
          "firstname": widget.userName,
          "email": widget.userEmail,
        }),
      );

      if (resp.statusCode != 200) {
        throw Exception("Failed to get hash from server");
      }

      final jsonResp = jsonDecode(resp.body);
      final merchantKey = jsonResp['merchantKey']?.toString() ?? '';
      final hashFromServer = jsonResp['hash']?.toString() ?? '';
      final isProd = jsonResp['isProduction'] == true;

      if (merchantKey.isEmpty || hashFromServer.isEmpty) {
        throw Exception(
            "Invalid response from hash API (missing merchantKey/hash)");
      }

      // Build payU params as a Map (field names must match what SDK expects)
      final Map<String, dynamic> payUPaymentParams = {
        // required
        "key": merchantKey,
        "amount": widget.amount.toString(),
        "productinfo": widget.productName,
        "firstname": widget.userName,
        "email": widget.userEmail,
        "phone": widget.userPhone,
        "txnid": widget.orderId,
        "surl": "https://yourserver.com/api/payu/success",
        "furl": "https://yourserver.com/api/payu/failure",
        // environment as string (some SDK versions accept "test"/"production")
        "environment": isProd ? "production" : "test",
        // pass the server-generated hash
        "hash": hashFromServer,
        // optional user-defined fields
        "udf1": "PAYU_APP",
        "udf2": "${widget.productName}__${widget.userName}",
        // example additional param (split details)
        "additionalParam": jsonEncode({
          "splitRequest": {
            "type": "absolute",
            "splitInfo": {
              merchantKey: {
                "aggregatorSubTxnId": "${widget.orderId}_split_client",
                "aggregatorSubAmt": widget.amount.toString(),
                "aggregatorCharges": "0"
              }
            }
          }
        }),
      };

      final Map<String, dynamic> payUConfig = {
        "primaryColor": "#000000",
        "secondaryColor": "#FFFFFF",
        "merchantName": "YourMerchant",
        "merchantLogo": "logo",
        "showExitConfirmationOnCheckoutScreen": true,
      };

      _payu.openCheckoutScreen(
        payUPaymentParams: payUPaymentParams,
        payUCheckoutProConfig: payUConfig,
      );
    } catch (e, st) {
      debugPrint("StartPayU Error: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment initialization failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: const Text("PayU Payment"), backgroundColor: Colors.green),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.green)
            : ElevatedButton(
                onPressed: _startPayUPayment,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Proceed to Pay"),
              ),
      ),
    );
  }

  @override
  generateHash(Map response) async {
    try {
      final hashName = response['hashName']?.toString();
      final hashString = response['hashString']?.toString();
      if (hashName == null || hashString == null) {
        _payu.hashGenerated(hash: {});
        return;
      }
      final r = await http.post(
        Uri.parse('https://payment-gateway-router.vercel.app/api/payu/hash'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"hashName": hashName, "hashString": hashString}),
      );
      if (r.statusCode == 200) {
        final jr = jsonDecode(r.body);
        if (jr[hashName] != null) {
          _payu.hashGenerated(hash: {hashName: jr[hashName]});
          return;
        }
      }
      _payu.hashGenerated(hash: {});
    } catch (e) {
      _payu.hashGenerated(hash: {});
    }
  }

  @override
  onPaymentSuccess(dynamic response) {
    debugPrint("PayU Success: $response");
    // handle success navigation / state changes
    Navigator.pop(context, {"status": "success", "response": response});
  }

  @override
  onPaymentFailure(dynamic response) {
    debugPrint("PayU Failure: $response");
    Navigator.pop(context, {"status": "failed", "response": response});
  }

  @override
  onPaymentCancel(Map? response) {
    debugPrint("PayU Cancel: $response");
    Navigator.pop(context, {"status": "cancelled", "response": response});
  }

  @override
  onError(Map? response) {
    debugPrint("PayU Error: $response");
    Navigator.pop(context, {"status": "error", "response": response});
  }
}
*/



/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:http/http.dart' as http;

class PayUPaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String productName;
  final String userName;
  final String userEmail;
  final String userPhone;

  const PayUPaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.productName,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<PayUPaymentScreen> createState() => _PayUPaymentScreenState();
}

class _PayUPaymentScreenState extends State<PayUPaymentScreen> {
  final PayUCheckoutProFlutter _payUCheckoutProFlutter = PayUCheckoutProFlutter();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('PayU Payment'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.green)
            : ElevatedButton(
                onPressed: _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                child: const Text("Proceed to Pay"),
              ),
      ),
    );
  }

  Future<void> _startPayment() async {
    setState(() => _isLoading = true);

    try {
      // 🔹 Step 1: Get hash & keys from your server (for security)
      final response = await http.post(
        Uri.parse('https://yourserver.com/api/generatePayUHash'), // <-- your backend endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "txnid": widget.orderId,
          "amount": widget.amount,
          "productinfo": widget.productName,
          "firstname": widget.userName,
          "email": widget.userEmail,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to generate hash");
      }

      final data = jsonDecode(response.body);

      // 🔑 Replace these with your actual keys or from response
      final payuConstKeys = {
        "merchantKey": data["merchantKey"], // e.g. "gtKFFx"
        "merchantSalt": data["merchantSalt"], // e.g. "eCwWELxi"
        "isProduction": false, // true for live
      };

      final txnDetails = {
        "amount": widget.amount.toString(),
        "txnid": widget.orderId,
        "productinfo": widget.productName,
        "firstname": widget.userName,
        "email": widget.userEmail,
        "phone": widget.userPhone,
        "surl": "https://yourserver.com/success",
        "furl": "https://yourserver.com/failure",
        "udf1": "PAYU_PAYMENT_GATEWAY****white_labels",
        "udf2": "${widget.productName}****${widget.userName}",
        "splitRequest": {
          "type": "absolute",
          "splitInfo": {
            "Xl4ay9": {
              "aggregatorSubTxnId": "${widget.orderId}_split_client",
              "aggregatorSubAmt": widget.amount.toString(),
              "aggregatorCharges": "0",
            }
          }
        },
      };

      final payUPaymentParams = PayUPaymentParams(
        key: payuConstKeys["merchantKey"],
        amount: txnDetails["amount"],
        productInfo: txnDetails["productinfo"],
        firstName: txnDetails["firstname"],
        email: txnDetails["email"],
        phone: txnDetails["phone"],
        transactionId: txnDetails["txnid"],
        surl: txnDetails["surl"],
        furl: txnDetails["furl"],
        environment: payuConstKeys["isProduction"] ? Environment.production : Environment.test,
        hash: data["hash"], // ✅ from your backend
        udf1: txnDetails["udf1"],
        udf2: txnDetails["udf2"],
        additionalParams: {"splitRequest": txnDetails["splitRequest"]},
      );

      // 🔹 Step 2: Start PayU Checkout
      _payUCheckoutProFlutter.openCheckoutScreen(
        payUPaymentParams,
        (response) {
          debugPrint("Payment Success: $response");
          Navigator.pop(context, {"status": "success", "response": response});
        },
        (response) {
          debugPrint("Payment Failure: $response");
          Navigator.pop(context, {"status": "failed", "response": response});
        },
      );
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment initialization failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
*/


/*
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiIntentPayment extends StatelessWidget {
  final String upiId = "test@upi";
  final String name = "Test Receiver";
  final double amount = 01.0;

  const UpiIntentPayment({super.key});

  Future<void> _payViaUpi() async {
    final uri = Uri.parse(
      "upi://pay?pa=$upiId&pn=$name&mc=0000&tid=123456789&tn=Event+Booking&am=$amount&cu=INR",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw "UPI not available!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("UPI Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: _payViaUpi,
          child: const Text("Proceed to Pay"),
        ),
      ),
    );
  }
}
*/
