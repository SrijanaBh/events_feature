import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:events_feature/core/constents.dart';
import 'package:events_feature/helper/secure_storage_helper.dart';
import 'package:events_feature/models/deal_models.dart';
import 'package:events_feature/models/loadings/deals_models.dart';
import 'package:events_feature/utils/payment_cancellation_response.dart';
import 'package:events_feature/utils/payment_error_response.dart';
import 'package:events_feature/utils/payment_response_dialog.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';

class DealsCheckOutButton extends StatefulWidget {
  final DealModel deal;
  final DateTime selectedDate;
  final int ticketCount;
  final int amount;

  const DealsCheckOutButton({
    super.key,
    required this.deal,
    required this.selectedDate,
    required this.ticketCount,
    required this.amount,
  });

  @override
  State<DealsCheckOutButton> createState() => _DealsCheckOutButtonState();
}

class _DealsCheckOutButtonState extends State<DealsCheckOutButton>
    implements PayUCheckoutProProtocol {
  late PayUCheckoutProFlutter _checkoutPro;

  @override
  void initState() {
    super.initState();
    _checkoutPro = PayUCheckoutProFlutter(this);
  }

  // final cartService = CartService();
  String sanitizePhone(String phone) {
    // Keep only digits and plus
    String sanitized = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    // Remove leading '+'
    if (sanitized.startsWith('+')) {
      sanitized = sanitized.substring(1);
    }

    return sanitized;
  }

  String getFormattedDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('MMddyyyyHHmm');
    return formatter.format(now);
  }

  Future<int> orderCreate(
    int id,
    String mobile,
    String email,
    String identitydate,
    String ordertype,
    int total,
    String couponCode,
    int couponDiscount,
    List<Map<String, dynamic>> orders,
  ) async {
    final session = SessionManager();
    await session.loadSession();

    final clubId = SecureStorageHelper().clubId;
    final authToken = session.authToken;

    final data = {
      'orders': orders,
      "clubId": clubId,
      "phone": mobile,
      "email": email,
      "identity_date": identitydate,
      "couponCode": couponCode,
      "couponDiscount": couponDiscount,
      "identity_id": id,
      "cart_type": ordertype,
      "cart_data_id": "",
      "is_temp": 1,
      "order_total_with_taxes": total,
    };

    print(total);
    print(jsonEncode(data));

    final response = await http.post(
        Uri.parse('$baseUrl/cartPage/orders/create'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': authToken!,
        });

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final id = responseData["data"]["orderId"];
      print("orderid : $id");

      log('Status code from ordercreate ${response.statusCode}');

      print("total cart value is $total");
      if (total <= 0) {
        final data = {
          // "orderId": 171121,
          "orderId": id,
          "refId":
              getFormattedDateTime(), // for refId: moment().format("MMDDYYYYHHmm"), use like this
          "mobile": responseData["data"]["phone"],
          "orderStatus": "success",
          "identityTitle": responseData["data"]["identityTitle"],
        };
        print(jsonEncode(data));
        var orderUpdateResponse = await http.post(
            Uri.parse("$baseUrl/cartPage/orders/update"),
            body: jsonEncode(data),
            headers: {
              'Content-Type': 'application/json',
              'x-auth-token': authToken,
            });

        log("update order ${orderUpdateResponse.statusCode}");

        var sendEmailResponse =
            await http.post(Uri.parse("$baseUrl/cartPage/orders/sendEmail"),
                body: jsonEncode({
                  "orderId": responseData["data"]["orderId"],
                  "refId":
                      getFormattedDateTime(), // for refId: moment().format("MMDDYYYYHHmm"), use like this
                  "mobile": responseData["data"]["phone"],
                  "orderStatus": "success",
                  "identityTitle": responseData["data"]["identityTitle"],
                }),
                headers: {
              'Content-Type': 'application/json',
              'x-auth-token': authToken,
            });

        if (orderUpdateResponse.statusCode != 200 &&
            sendEmailResponse.statusCode != 200) {
          throw "Something went wrong on bookings";
        }
      }

      return id;
    } else {
      throw "Failed to create Order";
      //////////// Add Payment Integration ///////////////
    }
  }

  List<Map<String, dynamic>> createOrders() {
    final List<Map<String, dynamic>> _createOrderPayload = [];

    List<DealModel> dealList = [widget.deal];

    for (var i in dealList) {
      _createOrderPayload.add({
        "id": i.id,
        "type": 1,
        "numberOfTickets": widget.ticketCount,
        "actualPrice": i.price,
        "discountPrice": i.actualPrice,
        "entryUpto": widget.ticketCount * int.parse(i.entryFreeUpto),
        "endTime": i.endTime,
        "selected_date": widget.selectedDate.toIso8601String(),
        "price_gst": 0,
      });
    }
    return _createOrderPayload;
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        "Start Payment",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        final userId = await SecureStorageHelper().getUserId();

        final email = SessionManager().userEmail ?? "";
        final name = SessionManager().userName ?? "";
        final phone = SessionManager().userPhone ?? "";

        final number = sanitizePhone(phone);
        // number should be like this +91 9948758032 => 919948758032
        // number should be like this +60 19-634 9678 => 60196349678

        log("number is $number");

        final orderId = await orderCreate(
            widget.deal.id,
            phone,
            email,
            DateTime.now().toUtc().toIso8601String(),
            "deals",
            widget.amount.toInt(),
            "",
            0,
            createOrders());

        // final orderId = await cartBookingController.createPaidOrder(
        //   widget.event.id,
        //   number,
        //   widget.email,
        //   DateTime.now().toUtc().toIso8601String(),
        //   "events",
        //   widget.amount.toInt(),
        //   cartController.cartTickets,
        // );

        _checkoutPro.openCheckoutScreen(
          payUPaymentParams: PayUParams.createPayUPaymentParams(
            name: name,
            email: email,
            phone: number,
            amount: widget.amount.toString(),
            transactionId: orderId.toString(),
            productInfo: widget.deal.title,
            userId: userId.toString(),
            orderId: orderId,
          ),
          payUCheckoutProConfig: PayUParams.createPayUConfigParams(),
        );
      },
    );
  }

  showAlertDialog(BuildContext context, String title, String content) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: new Text(content),
          ),
          actions: [okButton],
        );
      },
    );
  }

  @override
  generateHash(Map response) async {
    // // Backend will generate the hash which you need to pass to SDK
    // // hashResponse: is the response which you get from your server

    // Map hashResponse = {};

    // //Keep the salt and hash calculation logic in the backend for security reasons. Don't use local hash logic.
    // //Uncomment following line to test the test hash.
    // hashResponse = HashService.generateHash(response);

    // _checkoutPro.hashGenerated(hash: hashResponse);

    // This method is a callback from the PayU SDK.
    // The 'response' map contains the hashString, hashName, and other details.
    // We will now call your backend to generate the hash.
    try {
      // Extract data required for hash generation from the SDK's response
      String? hashName = response[PayUHashConstantsKeys.hashName];
      String? hashString = response[PayUHashConstantsKeys.hashString];
      String? hashType = response[PayUHashConstantsKeys.hashType];
      String? postSalt = response[PayUHashConstantsKeys.postSalt];

      if (hashName == null || hashString == null) {
        showAlertDialog(
          context,
          "Hash Generation Error",
          "Required hash data is missing from PayU response.",
        );
        return;
      }

      // Prepare the request body for your backend API
      Map<String, dynamic> requestBody = {
        "hashName": hashName,
        "hashString": hashString,
      };

      // Add optional parameters if they exist
      if (hashType != null) {
        requestBody['hashType'] = hashType;
      }
      if (postSalt != null) {
        requestBody['postSalt'] = postSalt;
      }

      // Make the POST request to your backend
      final apiResponse = await Dio().post(
        'https://payment-gateway-router.vercel.app/api/payu/hash',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode(requestBody),
      );

      Map<String, dynamic> hashResponse = {};

      if (apiResponse.statusCode == 200) {
        var jsonResponse = apiResponse.data;
        if (jsonResponse['success'] == true && jsonResponse[hashName] != null) {
          // The backend responded with the hash.
          // Prepare the hash map to be passed back to the PayU SDK.
          String paymentHash = jsonResponse[hashName];
          hashResponse = {hashName: paymentHash};
        } else {
          // Handle cases where the backend call was successful but didn't return a hash.
          print("Backend Error: ${jsonResponse['message']}");
          showAlertDialog(
            context,
            "Hash Generation Error",
            jsonResponse['message'] ??
                "Unknown server error while generating hash.",
          );
          return; // Stop the process
        }
      } else {
        // Handle API call failures
        print('API call failed with status code: ${apiResponse.statusCode}');
        print('Response body: ${apiResponse.data}');
        showAlertDialog(
          context,
          "Hash Generation Error",
          "Failed to communicate with the server. Status: ${apiResponse.statusCode}",
        );
        return; // Stop the process
      }

      // Pass the generated hash back to the PayU SDK to proceed with the payment.
      _checkoutPro.hashGenerated(hash: hashResponse);
    } catch (e) {
      // Handle any other exceptions during the process
      print("An error occurred during hash generation: $e");
      showAlertDialog(context, "Error", "An unexpected error occurred: $e");
    }
  }

  @override
  onPaymentSuccess(dynamic response) {
    try {
      String orderId = "";

      final payuMap = response["payuResponse"] is String
          ? jsonDecode(response["payuResponse"])
          : response["payuResponse"];

      final result = payuMap["result"];
      if (result == null) {
        orderId = payuMap["txnid"]?.toString() ?? "";
      } else {
        orderId = result["txnid"]?.toString() ?? "";
      }

      showPaymentSheet(context);
    } catch (e, s) {
      print(e);
      print(s);
    }
    // showPaymentSuccessSheet(context, int.parse(orderId));
  }

  @override
  onPaymentFailure(dynamic response) {
    showPaymentSheet(context);
  }

  @override
  onPaymentCancel(Map? response) {
    showPaymentCancelledSheet(context);
  }

  @override
  onError(Map? response) {
    showPaymentErrorSheet(context, response);
  }
}

class PayUTestCredentials {
  //Find the test credentials from dev guide: https://devguide.payu.in/flutter-sdk-integration/getting-started-flutter-sdk/mobile-sdk-test-environment/
  static const merchantKey = "zuU7BF"; // Add you Merchant Key
  static const iosSurl =
      "https://payment-gateway-router.vercel.app/api/payu/success-webhook";
  static const iosFurl =
      "https://payment-gateway-router.vercel.app/api/payu/failed-webhook";
  static const androidSurl =
      "https://payment-gateway-router.vercel.app/api/payu/success-webhook";
  static const androidFurl =
      "https://payment-gateway-router.vercel.app/api/payu/failed-webhook";

  static const merchantAccessKey = ""; //Add Merchant Access Key - Optional
  static const sodexoSourceId = ""; //Add sodexo Source Id - Optional
}

//Pass these values from your app to SDK, this data is only for test purpose
class PayUParams {
  static Map createPayUPaymentParams({
    required String name,
    required String email,
    required String phone,
    required String amount,
    required String transactionId,
    required String productInfo,
    required String userId,
    required int orderId,
  }) {
    var siParams = {
      PayUSIParamsKeys.isFreeTrial: true,
      PayUSIParamsKeys.billingAmount: '1', //Required
      PayUSIParamsKeys.billingInterval: 1, //Required
      PayUSIParamsKeys.paymentStartDate: '2023-04-20', //Required
      PayUSIParamsKeys.paymentEndDate: '2023-04-30', //Required
      PayUSIParamsKeys.billingCycle: //Required
          'daily', //Can be any of 'daily','weekly','yearly','adhoc','once','monthly'
      PayUSIParamsKeys.remarks: 'Test SI transaction',
      PayUSIParamsKeys.billingCurrency: 'INR',
      PayUSIParamsKeys.billingLimit: 'ON', //ON, BEFORE, AFTER
      PayUSIParamsKeys.billingRule: 'MAX', //MAX, EXACT
    };

    var additionalParam = {
      PayUAdditionalParamKeys.udf1:
          "PAYU_PAYMENT_GATEWAY****white_labels_app****$userId",
      PayUAdditionalParamKeys.udf2: "SATURDAY DJ NIGHT****Test Club",
      PayUAdditionalParamKeys.udf3: "udf3",
      PayUAdditionalParamKeys.udf4: "udf4",
      PayUAdditionalParamKeys.udf5: "udf5",
      PayUAdditionalParamKeys.merchantAccessKey:
          PayUTestCredentials.merchantAccessKey,
      PayUAdditionalParamKeys.sourceId: PayUTestCredentials.sodexoSourceId,
    };

    var spitPaymentDetails = {
      "type": "absolute",
      "splitInfo": {
        PayUTestCredentials.merchantKey: {
          "aggregatorSubTxnId": "168612_split_client",
          "aggregatorSubAmt": "1",
        },
      },
    };

    var payUPaymentParams = {
      PayUPaymentParamKey.key: PayUTestCredentials.merchantKey,
      PayUPaymentParamKey.amount: amount,
      PayUPaymentParamKey.productInfo: productInfo,
      // PayUPaymentParamKey.productInfo: "Payment for SATURDAY DJ NIGHT",
      PayUPaymentParamKey.firstName: name,
      PayUPaymentParamKey.email: email,
      PayUPaymentParamKey.phone: phone,
      PayUPaymentParamKey.ios_surl: PayUTestCredentials.iosSurl,
      PayUPaymentParamKey.ios_furl: PayUTestCredentials.iosFurl,
      PayUPaymentParamKey.android_surl: PayUTestCredentials.androidSurl,
      PayUPaymentParamKey.android_furl: PayUTestCredentials.androidFurl,
      PayUPaymentParamKey.environment: "0", //0 => Production 1 => Test
      PayUPaymentParamKey.userCredential: userId,
      PayUPaymentParamKey.transactionId: transactionId,
      PayUPaymentParamKey.additionalParam: additionalParam,
      PayUPaymentParamKey.enableNativeOTP: true,
      PayUPaymentParamKey.splitPaymentDetails: json.encode(spitPaymentDetails),
      PayUPaymentParamKey.userToken:
          "", //Pass a unique token to fetch offers. - Optional
    };

    return payUPaymentParams;
  }

  static Map createPayUConfigParams() {
    var paymentModesOrder = [
      {"UPI": "TEZ"}, // Google Pay
      {"UPI": "PHONEPE"}, // PhonePe
      {"UPI": "PAYTM"}, // Paytm UPI
      {"UPI": "BHIMUPI"}, // BHIM
    ];

    // var cartDetails = [
    //   {"GST": "5%"},
    //   {"Delivery Date": "25 Dec"},
    //   {"Status": "In Progress"},
    // ];
    var enforcePaymentList = [
      {"payment_type": "UPI", "enforce_ibiboCode": "TEZ"}, // Force GPay
      {"payment_type": "UPI", "enforce_ibiboCode": "PHONEPE"}, // Force PhonePe
      {"payment_type": "UPI", "enforce_ibiboCode": "PAYTM"}, // Force Paytm
    ];

    // var customNotes = [
    //   {
    //     "custom_note": "Its Common custom note for testing purpose",
    //     "custom_note_category": [
    //       PayUPaymentTypeKeys.emi,
    //       PayUPaymentTypeKeys.card,
    //     ],
    //   },
    //   {
    //     "custom_note": "Payment options custom note",
    //     "custom_note_category": null,
    //   },
    // ];
    var payUCheckoutProConfig = {
      PayUCheckoutProConfigKeys.primaryColor: "#000000",
      PayUCheckoutProConfigKeys.secondaryColor: "#FFFFFF",
      PayUCheckoutProConfigKeys.baseTextColor: "#FFFFFF",

      PayUCheckoutProConfigKeys.merchantName: "PayU",
      PayUCheckoutProConfigKeys.merchantLogo: "logo",
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
      //      PayUCheckoutProConfigKeys.cartDetails: cartDetails,
      PayUCheckoutProConfigKeys.paymentModesOrder: paymentModesOrder,
      PayUCheckoutProConfigKeys.merchantResponseTimeout: 30000,
      //      PayUCheckoutProConfigKeys.customNotes: customNotes,
      PayUCheckoutProConfigKeys.autoSelectOtp: true,
      PayUCheckoutProConfigKeys.enforcePaymentList: enforcePaymentList,
      PayUCheckoutProConfigKeys.waitingTime: 30000,
      PayUCheckoutProConfigKeys.autoApprove: true,
      PayUCheckoutProConfigKeys.merchantSMSPermission: true,
      PayUCheckoutProConfigKeys.showCbToolbar: true,
    };
    return payUCheckoutProConfig;
  }
}
