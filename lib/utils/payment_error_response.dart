import 'package:flutter/material.dart';
import 'package:get/get.dart';


showPaymentErrorSheet(BuildContext context, Map? error) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // small drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),

              // Lottie or fallback icon
              SizedBox(
                height: 110,
                //child: Lottie.asset('assets/lottie/Error Occurred!.json'),
              ),

              const SizedBox(height: 10),

              Text(
                "Payment Error",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "An error occurred during payment. Please try again.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // show error
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ),
                  // const SizedBox(width: 8),
                  // Expanded(
                  //   child: FilledButton(
                  //     onPressed: () {
                  //       Get.offAllNamed(MainScreen.routeName);
                  //     },
                  //     child: const Text('Back to Home'),
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}