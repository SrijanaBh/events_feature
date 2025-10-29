import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayUPaymentWebView extends StatefulWidget {
  final String paymentUrl;

  const PayUPaymentWebView({super.key, required this.paymentUrl});

  @override
  State<PayUPaymentWebView> createState() => _PayUPaymentWebViewState();
}

class _PayUPaymentWebViewState extends State<PayUPaymentWebView> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize the controller properly for modern webview_flutter
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => isLoading = false);

            // ✅ Detect success or failure redirects (customize for your PayU URLs)
            if (url.contains("payment-success")) {
              _showResultDialog("Payment Successful ✅");
            } else if (url.contains("payment-failure")) {
              _showResultDialog("Payment Failed ❌");
            }
          },
          onWebResourceError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Web error: ${error.description}")),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _showResultDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Status"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to summary screen
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }
}




/*
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayUPaymentWebView extends StatefulWidget {
  final String paymentUrl;

  const PayUPaymentWebView({super.key, required this.paymentUrl});

  @override
  State<PayUPaymentWebView> createState() => _PayUPaymentWebViewState();
}

class _PayUPaymentWebViewState extends State<PayUPaymentWebView> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.paymentUrl,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (_) {
              setState(() => isLoading = false);
            },
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }
}
*/