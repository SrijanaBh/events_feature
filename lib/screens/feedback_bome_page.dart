import 'package:events_feature/utils/session_manager.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/utils/auth_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    final feedbackText = _feedbackController.text;

    if (_rating == 0 || feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rating and feedback")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userData = await AuthManager.getUserInfo();
      final String? userId = userData['userId'];
      final String? clubId = userData['clubId'];

      if (userId == null || clubId == null) {
        throw Exception("Missing user or club info");
      }

      final body = jsonEncode({
        "club_id": clubId,
        "user_id": userId,
        "ratings": _rating,
        "message": feedbackText,
      });

      final session = SessionManager();
      await session.loadSession();

      final response = await http.post(
        Uri.parse(
          "https://white-labels-app-server.vercel.app/api/feedback/insert",
        ),
        headers: {
          'Content-Type': 'application/json',
          "x-auth-token": session.authToken ?? " ",
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Feedback submitted successfully!"),
          ),
        );
        _feedbackController.clear();
        setState(() => _rating = 0);
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${error['message'] ?? 'Try again'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

/*
  Widget _buildStar(int index) {
    bool isSelected = index < _rating;

    return GestureDetector(
      onTap: () => setState(() => _rating = index + 1),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                // color: Colors.amber.withOpacity(0.7),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: isSelected
                  ? [Colors.amberAccent, Colors.orangeAccent, Colors.yellow]
                  : [Colors.grey.shade400, Colors.grey.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: const Icon(
            Icons.star_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
*/
  Widget _buildStar(int index) {
    return IconButton(
      highlightColor: Colors.amber.shade400,
      splashColor: Colors.amber.shade200,
      icon: Icon(
        Icons.star,
        color: index < _rating ? Colors.amber : Colors.grey[300],
        size: 48,
      ),
      onPressed: () => setState(() => _rating = index + 1),
    );
  }
  /* Widget _buildStar(int index) {
    final bool isSelected = index < _rating;

    return GestureDetector(
      onTap: () => setState(() => _rating = index + 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey[600]!,
            width: isSelected ? 2.5 : 1.2,
          ),
          color: isSelected ? Colors.amber.withOpacity(0.15) : Colors.grey[850],
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amberAccent.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Icon(
          Icons.star,
          color: isSelected ? Colors.amberAccent : Colors.grey[400],
          size: 36,
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Share Your Valuable Feedback !",
          style: TextStyle(color: Colors.green),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Tap to rate your experience",
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildStar(index)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: "Please share your feedback",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 116,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Submit feedback",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse("https://support@clubr.in");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                "Review us on our Website",
                style: TextStyle(
                  color: Colors.green,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  void _submitFeedback() {
    final feedbackText = _feedbackController.text;
    if (_rating == 0 || feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please provide a rating and feedback",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    // TODO: Send feedback to server or process it
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Feedback submitted !"),
      ),
    );
    FocusScope.of(context).unfocus();
    // Clear fields
    setState(() {
      _rating = 0;
      _feedbackController.clear();
    });
  }

  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: index < _rating ? Colors.amber : Colors.grey[300],
        size: 48,
      ),
      onPressed: () {
        setState(() {
          _rating = index + 1;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Share Your Valuable Feedback",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Rate our app",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildStar(index)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                hintText: "Please share your feedback",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 12,
                ),
              ),
              child: const Text("Submit Feedback"),
            ),
            SizedBox(height: 30),

            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse("www.google.com");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Couldn't launch the Website"),
                    ),
                  );
                }
              },

              child: const Text(
                "Review us on Google",
                style: TextStyle(
                  color: Colors.greenAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
