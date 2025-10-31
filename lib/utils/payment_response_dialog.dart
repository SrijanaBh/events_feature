import 'package:flutter/material.dart';

showPaymentSheet(BuildContext context) {
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

              const SizedBox(height: 10),

              Text(
                "Dialog title here",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "We could not complete your payment. Please try again.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),
              Text(
                "this is the response of payment",
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
