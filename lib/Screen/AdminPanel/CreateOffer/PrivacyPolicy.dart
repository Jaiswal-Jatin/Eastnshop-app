import 'package:eastnshop/Screen/DrawerScreen.dart';
import 'package:eastnshop/Screen/Userpanel/Customappbar.dart';
import 'package:eastnshop/Screen/AdminPanel/AdminDashboard/HomePage.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final bool showAppBar;
  const PrivacyPolicyPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: showAppBar ? const CustomAppBarWithDrawer() : null,
      drawer: showAppBar ? const DrawerScreen() : null,
      body: SafeArea(
        top: !showAppBar,
        bottom: !showAppBar,
        child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operated By :  Eastnshoptech',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Introduction
                  Text(
                    'Introduction',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'This Privacy Policy outlines how Eastnshoptech  ("we", "us", or "our") collects, uses, and protects the personal information of users who access and use our mobile application ("the App").\n\nBy using the App, you agree to the collection and use of your information in accordance with this policy.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Section 1: Information We Collect
                  Text(
                    '1. Information We Collect',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'We may collect the following types of information:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 16),

                  // 1.1 Personal Information
                  Text(
                    '1.1 Personal Information (Provided by You)',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        BulletText('Name'),
                        BulletText('Mobile number'),
                        BulletText('Email address (if provided)'),
                        BulletText('Shop details (for shopkeepers)'),
                        BulletText('Product or advertisement content'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // 1.2 Non-Personal Information
                  Text(
                    '1.2 Non-Personal Information (Automatically Collected)',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        BulletText('Device type and operating system'),
                        BulletText(
                          'App usage data (e.g., pages viewed, clicks, etc.)',
                        ),
                        BulletText('Location data (if permission is granted)'),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Section 2: How We Use Your Information
                  Text(
                    '2. How We Use Your Information',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'We use the information we collect to:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        BulletText(
                          'Enable shopkeepers to post ads and manage their listings',
                        ),
                        BulletText(
                          'Help customers discover nearby shops, offers, and deals',
                        ),
                        BulletText(
                          'Improve app functionality and user experience',
                        ),
                        BulletText(
                          'Personalize content and recommendations based on your preferences and location',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;
  const BulletText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18, height: 1.5)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
