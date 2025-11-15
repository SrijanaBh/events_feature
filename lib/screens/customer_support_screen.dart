import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerSupportPage extends StatelessWidget {
  const CustomerSupportPage({super.key});

  // phone, email, website info
  final String phoneNumber = "+91 9000988068";
  final String email = "support@clubr.in";
  final String website = "www.clubr.in";

  /// Launch phone dialer / Truecaller
  Future<void> _launchPhone(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint("❌ Could not launch dialer");
    }
  }

  // /// Launch mail app (Gmail, Outlook, etc.)
  // Future<void> _launchEmail(String email) async {
  //   final Uri emailUri = Uri(
  //     scheme: 'mailto',
  //     path: email,
  //     query: Uri.encodeFull("subject=Support Request&body=Hi Team,"),
  //   );
  //   if (await canLaunchUrl(emailUri)) {
  //     await launchUrl(emailUri);
  //   } else {
  //     debugPrint("❌ Could not launch email app");
  //   }
  // }

  // /// Launch company website
  // Future<void> _launchWebsite(String url) async {
  //   final Uri webUri = Uri.parse(url);
  //   if (await canLaunchUrl(webUri)) {
  //     await launchUrl(webUri, mode: LaunchMode.externalApplication);
  //   } else {
  //     debugPrint("❌ Could not launch website");
  //   }
  // }

  // Launches a URL (e.g., website)
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // You might want to show a SnackBar or dialog if the URL cannot be launched
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(" Support"),
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black,
        body: ListView(
          children: [
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.greenAccent),
              title: Text(
                phoneNumber,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: const Text(
                "Tap to call our support team",
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () => _launchPhone(phoneNumber),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.orangeAccent),
              title: Text(
                email,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: const Text(
                "Tap to send us an email",
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () => _launchUrl('mailto:support@clubr.in'),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blueAccent),
              title: Text(
                website,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: const Text(
                "Visit our company website",
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () => _launchUrl("https://clubr.in"),
            ),
            const Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
