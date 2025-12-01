import 'package:flutter/material.dart';
import 'package:glow_and_go/style/app_color.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor().kpurple3.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    const Text(
                      '🔒',
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SALONAPP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColor().kpurple3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'by Hogo Studios',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '📅 Last Updated: December 1, 2025',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Introduction
              _buildSection(
                icon: '👋',
                title: 'Introduction',
                content:
                    'Welcome to SALONAPP, a salon booking application developed by Hogo Studios. '
                    'This Privacy Policy explains how we collect, use, store, and protect your personal information when you use '
                    'our mobile application to book appointments at participating salons.\n\n'
                    'By using SALONAPP, you agree to the collection and use of information in accordance with this policy. '
                    'We are committed to protecting your privacy and ensuring transparency in our data practices.',
              ),

              // 1. Information We Collect
              _buildSection(
                icon: '📊',
                title: '1. Information We Collect',
                content:
                    'We collect the following types of information to provide and improve our services:',
              ),
              _buildSubSection(
                icon: '👤',
                title: 'Personal Information',
                items: [
                  'Account Data: Full name, email address, phone number, and unique user ID (Firebase UID)',
                  'Profile Information: Any additional details you choose to provide',
                ],
              ),
              _buildSubSection(
                icon: '📅',
                title: 'Booking Information',
                items: [
                  'Appointment Details: Date, time, selected services, preferred barber/stylist',
                  'Booking History: Record of past and upcoming appointments',
                  'Service Preferences: Your favorite services and stylists',
                ],
              ),
              _buildSubSection(
                icon: '🔧',
                title: 'Technical Information',
                items: [
                  'Device Information: Device type, operating system version, unique device identifiers',
                  'App Usage Data: App version, crash reports, performance metrics',
                  'Connection Data: IP address, network provider (for security and troubleshooting)',
                ],
              ),
              _buildSubSection(
                icon: '📍',
                title: 'Location Information (Optional)',
                items: [
                  'Location Data: With your permission, we may collect location data to help you find nearby salons',
                ],
              ),

              // 2. How We Use Your Information
              _buildSection(
                icon: '🎯',
                title: '2. How We Use Your Information',
                content:
                    'We use the collected information for the following purposes:',
              ),
              _buildHighlightBox(
                icon: '🛠️',
                title: 'Service Delivery',
                items: [
                  'Creating and managing your account',
                  'Processing and confirming your salon appointments',
                  'Sending booking confirmations and reminders',
                  'Facilitating communication between you and the salon',
                ],
              ),
              _buildHighlightBox(
                icon: '📈',
                title: 'Service Improvement',
                items: [
                  'Analyzing app usage to improve features and user experience',
                  'Identifying and fixing bugs and technical issues',
                  'Developing new features based on user behavior',
                ],
              ),
              _buildHighlightBox(
                icon: '🔐',
                title: 'Security & Safety',
                items: [
                  'Preventing fraud and unauthorized access',
                  'Detecting and preventing abuse of our services',
                  'Ensuring compliance with legal obligations',
                ],
              ),
              _buildHighlightBox(
                icon: '📧',
                title: 'Communication',
                items: [
                  'Sending important updates about your bookings',
                  'Notifying you about app updates and new features',
                  'Responding to your inquiries and support requests',
                ],
              ),
              _buildImportantBox(
                '⚠️ Important: We do NOT sell your personal information to third parties. '
                'We do NOT use your data for unrelated marketing purposes.',
              ),

              // 3. Data Storage & Security
              _buildSection(
                icon: '💾',
                title: '3. Data Storage & Security',
                content:
                    'Your data is stored securely using Firebase (Google Cloud Platform) infrastructure, which provides enterprise-grade security and reliability.',
              ),
              _buildSubSection(
                icon: '🔒',
                title: 'Security Measures',
                items: [
                  'Encryption: All data is encrypted in transit using SSL/TLS protocols',
                  'Authentication: Secure Firebase Authentication with email/password protection',
                  'Access Controls: Strict access controls limiting data access to authorized personnel only',
                  'Regular Backups: Automatic backups to prevent data loss',
                  'Monitoring: Continuous security monitoring and threat detection',
                ],
              ),

              // 4. Third-Party Services
              _buildSection(
                icon: '🤝',
                title: '4. Third-Party Services',
                content:
                    'SALONAPP uses the following third-party services that may access your data:',
              ),
              _buildSubSection(
                icon: '',
                title: '',
                items: [
                  '🔥 Firebase (Google): Authentication, database (Firestore), cloud storage, and crash analytics',
                  '📧 Email Service Providers: For sending booking confirmations and notifications',
                  '📊 Firebase Crashlytics: For monitoring app stability and crash reporting',
                ],
              ),
              _buildImportantBox(
                '🔗 Third-Party Links: Our app may contain links to external websites or services. '
                'We are not responsible for the privacy practices of these external sites. '
                'Please review their privacy policies separately.',
              ),

              // 5. Data Sharing
              _buildSection(
                icon: '👥',
                title: '5. Data Sharing',
                content:
                    'We share your information only in the following limited circumstances:',
              ),
              _buildSubSection(
                icon: '🏢',
                title: 'With Salons',
                items: [
                  'When you book an appointment, we share your name, contact information, and appointment details with the specific salon you\'re booking with. This is necessary to fulfill your booking request.',
                ],
              ),
              _buildSubSection(
                icon: '⚖️',
                title: 'Legal Compliance',
                items: [
                  'We may disclose your information if required by law, court order, or governmental regulation, or to protect the rights, property, or safety of Hogo Studios, our users, or the public.',
                ],
              ),
              _buildImportantBox(
                '✋ We Do NOT: Sell, rent, or trade your personal information to third parties for marketing purposes.',
              ),

              // 6. Your Rights & Choices
              _buildSection(
                icon: '✅',
                title: '6. Your Rights & Choices',
                content:
                    'You have the following rights regarding your personal data:',
              ),
              _buildSubSection(
                icon: '🔍',
                title: 'Access & Portability',
                items: [
                  'Request a copy of all personal data we hold about you',
                  'Export your data in a machine-readable format',
                ],
              ),
              _buildSubSection(
                icon: '✏️',
                title: 'Correction & Update',
                items: [
                  'Update your account information directly in the app',
                  'Request correction of inaccurate or incomplete data',
                ],
              ),
              _buildSubSection(
                icon: '🗑️',
                title: 'Deletion',
                items: [
                  'Delete your account and associated data through the app settings',
                  'Request complete data deletion by contacting us',
                ],
              ),
              _buildSubSection(
                icon: '🚫',
                title: 'Opt-Out',
                items: [
                  'Opt-out of promotional emails (booking confirmations will still be sent)',
                  'Disable location services in your device settings',
                  'Withdraw consent for data processing (may limit app functionality)',
                ],
              ),
              _buildHighlightBox(
                icon: '📧',
                title: 'To Exercise Your Rights',
                items: [
                  'Contact us at: lazarmilosevic2212@gmail.com',
                  'We will respond to your request within 30 days',
                ],
              ),

              // 7. Data Retention
              _buildSection(
                icon: '⏱️',
                title: '7. Data Retention',
                content:
                    'We retain your personal information for as long as necessary to:\n'
                    '→ Provide our services to you\n'
                    '→ Comply with legal obligations (e.g., tax records, dispute resolution)\n'
                    '→ Maintain security and prevent fraud\n\n'
                    'Active Accounts: Data is retained while your account is active and for a reasonable period afterward.\n'
                    'Deleted Accounts: When you delete your account, we will delete or anonymize your personal data within 90 days, except where retention is required by law.',
              ),

              // 8. Children's Privacy
              _buildSection(
                icon: '👶',
                title: '8. Children\'s Privacy',
                content: '',
              ),
              _buildImportantBox(
                '🔞 Age Restriction: SALONAPP is not intended for use by children under the age of 13.\n\n'
                'We do not knowingly collect personal information from children under 13. '
                'If we become aware that we have inadvertently collected such information, we will take immediate steps to delete it.\n\n'
                'If you are a parent or guardian and believe your child has provided us with personal information, '
                'please contact us at lazarmilosevic2212@gmail.com.',
              ),

              // 9. International Data Transfers
              _buildSection(
                icon: '🌍',
                title: '9. International Data Transfers',
                content:
                    'Your information may be transferred to and processed in countries other than your country of residence. '
                    'These countries may have different data protection laws than your jurisdiction.\n\n'
                    'We ensure that such transfers comply with applicable data protection laws through:\n'
                    '→ Using Firebase/Google Cloud, which complies with EU-US Data Privacy Framework\n'
                    '→ Implementing standard contractual clauses approved by regulatory authorities\n'
                    '→ Ensuring equivalent security measures are in place',
              ),

              // 10. Changes to This Privacy Policy
              _buildSection(
                icon: '🔄',
                title: '10. Changes to This Privacy Policy',
                content:
                    'We may update this Privacy Policy from time to time to reflect changes in our practices, technology, legal requirements, or other factors.',
              ),
              _buildHighlightBox(
                icon: '📢',
                title: 'How We Notify You',
                items: [
                  'Significant changes will be announced through in-app notifications',
                  'Updated policy will be posted on our GitHub repository',
                  'The "Last Updated" date at the top will reflect the revision date',
                ],
              ),

              // 11. Governing Law
              _buildSection(
                icon: '⚖️',
                title: '11. Governing Law & Jurisdiction',
                content:
                    'This Privacy Policy is governed by the laws of the Republic of Serbia.\n\n'
                    'Any disputes arising from this policy or your use of SALONAPP shall be subject to the exclusive jurisdiction of the courts in Lazarevac, Serbia.',
              ),

              // 12. Compliance
              _buildSection(
                icon: '🛡️',
                title: '12. Compliance & Certifications',
                content:
                    'SALONAPP and Hogo Studios are committed to complying with:\n'
                    '→ GDPR: General Data Protection Regulation (EU)\n'
                    '→ CCPA: California Consumer Privacy Act (USA)\n'
                    '→ Google Play Store: Data safety requirements\n'
                    '→ Apple App Store: Privacy guidelines and App Tracking Transparency',
              ),

              // Contact Box
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor().kpurple3,
                      AppColor().kpurple3.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      '📞 Contact Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'If you have any questions, concerns, or requests regarding this Privacy Policy or your personal data:',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Developer: Hogo Studios\n'
                      'Project: SALONAPP\n'
                      'Email: lazarmilosevic2212@gmail.com',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'We aim to respond to all inquiries within 48-72 business hours.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Footer
              const SizedBox(height: 30),
              const Center(
                child: Column(
                  children: [
                    Text(
                      '© 2025 Hogo Studios. All rights reserved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'SALONAPP - Salon Booking Application',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon.isNotEmpty) ...[
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor().kpurple3,
                  ),
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubSection({
    required String icon,
    required String title,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Row(
              children: [
                if (icon.isNotEmpty) ...[
                  Text(
                    icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor().kpurple3.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '→ ',
                      style: TextStyle(
                        color: AppColor().kpurple3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildHighlightBox({
    required String icon,
    required String title,
    required List<String> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor().kpurple3.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppColor().kpurple3,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon.isNotEmpty) ...[
                Text(
                  icon,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColor().kpurple3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: AppColor().kpurple3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildImportantBox(String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(
            color: Colors.amber,
            width: 3,
          ),
        ),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 13,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }
}
