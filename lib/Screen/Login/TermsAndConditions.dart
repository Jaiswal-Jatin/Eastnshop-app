import 'package:flutter/material.dart';
import 'package:eastnshop/Constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Terms and Conditions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF9900), Color(0xFFFF9900)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.gavel, color: Colors.white, size: 32),
                  SizedBox(height: 12),
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Last updated: March 2026',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Introduction
            _buildSectionCard(
              title: 'Introduction',
              content:
                  'These Terms and Conditions ("Terms") govern your use of the [EastNShop] mobile application ("the App"), operated by [EASTNSHOPTECH LLP] ("we," "us," or "our"). By accessing or using the App, you agree to comply with and be bound by these Terms. If you do not agree with any part of these Terms, please do not use the App.',
            ),

            // Terms Content
            _buildSectionCard(
              title: '1. Purpose of the Platform',
              content:
                  'Eastnshoptech serves as a digital platform that connects shopkeepers with customers. Shopkeepers can post advertisements for their products or services, and customers can browse these listings and choose to visit the shop or make a purchase directly from the shopkeeper.\n\n⚠ Please note: We do not offer delivery services or handle any payments. All transactions, communication, and arrangements—including delivery—occur directly between the shopkeeper and the customer.',
            ),

            _buildSectionCard(
              title: '2. User Responsibilities',
              content:
                  '2.1 Shopkeepers\n• You are solely responsible for ensuring that all advertisements you post are accurate, lawful, and clearly presented.\n• You must not publish content that is false, misleading, fraudulent, or prohibited by law.\n• Your shop, products, and services must comply with all applicable local laws and regulations.\n\n2.2 Customers\n• You are responsible for verifying the accuracy and reliability of any information found in shopkeeper listings.\n• You acknowledge that any decision to visit a shop or make a purchase is entirely at your own discretion and risk.',
            ),

            _buildSectionCard(
              title: '3. No Involvement in Transactions',
              content:
                  'We act solely as a platform provider and are not a party to any transactions between shopkeepers and customers. Specifically, we do not:\n• Guarantee the quality, safety, legality, or availability of listed items.\n• Confirm the accuracy or truthfulness of any advertisement.\n• Mediate or participate in disputes between users.\n• All risks associated with visiting shops, making purchases, or entering into any agreements lie entirely with the users.',
            ),

            _buildSectionCard(
              title: '4. Content Guidelines',
              content:
                  'Users are strictly prohibited from posting or sharing any content that:\n• Is illegal, misleading, defamatory, obscene, or offensive.\n• Infringes on the intellectual property or rights of others.\n• Contains viruses, malware, or harmful code.\n• We reserve the right to remove any content that violates these guidelines at our sole discretion, without prior notice.',
            ),

            _buildSectionCard(
              title: '5. Limitation of Liability',
              content:
                  'To the fullest extent permitted by law, we disclaim all liability for any direct or indirect damages or losses resulting from:\n• The use or inability to use the App.\n• Any transaction, communication, or dispute between users.\n• Reliance on any advertisement or user-generated content displayed on the App.',
            ),

            _buildSectionCard(
              title: '6. Termination of Access',
              content:
                  'We reserve the right to suspend or permanently terminate your access to the App, without prior notice, if you:\n• Violate these Terms,\n• Engage in unlawful or harmful behavior, or\n• Act in a way that compromises the security or integrity of the platform.',
            ),

            _buildSectionCard(
              title: '7. Updates to Terms',
              content:
                  'We may revise these Terms at any time. If we do, we will update the "last modified" date and provide notice where appropriate. Your continued use of the App after any changes means you accept the revised Terms.',
            ),

            _buildSectionCard(
              title: '8. Governing Law',
              content:
                  'These Terms shall be governed by and interpreted in accordance with the laws of India, without regard to conflict of law principles.',
            ),

            // const SizedBox(height: 24),

            // Contact Information
            _buildSectionCard(
              title: '9. Contact Information',
              content: '', // Empty because we're using customContent
              customContent: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    TextSpan(
                      text:
                          'If you have any questions, feedback, or concerns about these Terms, please reach out to us:\n\nEmail: ',
                      children: [
                        TextSpan(
                          text: 'eastnshoptechsup@gmail.com',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 50, 200),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap =
                                    () => _launchEmail(
                                      'eastnshoptechsup@gmail.com',
                                    ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Accept Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF9900), Color(0xFFFF9900)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'I Understand & Accept',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Query regarding Terms and Conditions'},
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch $emailLaunchUri';
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    Widget? customContent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9900),
            ),
          ),
          const SizedBox(height: 12),
          customContent ??
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
        ],
      ),
    );
  }
}
