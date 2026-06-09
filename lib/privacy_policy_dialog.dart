import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme.dart';

class PrivacyPolicySheet extends StatelessWidget {
  const PrivacyPolicySheet({super.key});

  /// Displays the privacy policy bottom sheet.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => const PrivacyPolicySheet(),
    );
  }

  Future<void> _openWebVersion() async {
    final url = Uri.parse('https://randomwalk.ai/lifelab/privacy_policy.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

    return Container(
      height: maxHeight,
      decoration: const BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Colors.white10, width: 1.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Column(
          children: [
            // Drag Handle / Header Area
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Dialog Title Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: green.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: green.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.shield_outlined, color: green, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PRIVACY POLICY",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Effective Date: 01-04-2026",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader("1", "Purpose"),
                    _buildSectionBody(
                      "The purpose of this Privacy Policy is to communicate Random Walk's commitment to protecting the personal information of users, customers, employees, and third parties. It ensures compliance with global privacy laws such as GDPR, CCPA, and other applicable data protection regulations."
                    ),
                    const SizedBox(height: 20),

                    _buildSectionHeader("2", "Scope"),
                    _buildBulletList([
                      "All data collected, processed, or stored by the Life Lab mobile application.",
                      "Employees, contractors, and third-party processors handling data for Random Walk AI.",
                      "All systems, applications, and platforms where data resides."
                    ]),
                    const SizedBox(height: 20),

                    _buildSectionHeader("3", "Definitions"),
                    _buildBulletList([
                      "Personal Data: Any information relating to an identified or identifiable individual.",
                      "Data Subject: An individual whose personal data is processed.",
                      "Processing: Any operation performed on data (collection, storage, use, transfer, deletion).",
                      "Controller / Processor: Roles defined under GDPR describing data ownership and processing responsibilities."
                    ]),
                    const SizedBox(height: 20),

                    _buildSectionHeader("4", "Policy Statements"),
                    
                    _buildSubsectionHeader("4.1 Data Collection"),
                    _buildSectionBody(
                      "The Life Lab Android game operates entirely locally. The app does not collect, transmit, or store any personal data (such as names, emails, IP addresses, location data, or device identifiers). Non-personal gameplay progress and high scores are saved locally on your device via shared preferences."
                    ),
                    
                    _buildSubsectionHeader("4.2 Data Usage"),
                    _buildSectionBody(
                      "Local data (high scores, tutorial states) is used solely to enhance your local gaming experience. No personal data is used, analyzed, or compiled, as none is collected."
                    ),
                    
                    _buildSubsectionHeader("4.3 Data Sharing"),
                    _buildSectionBody(
                      "We do not share, sell, rent, or distribute any personal data to third parties. Sharing gameplay stats (e.g., using the in-game share button) is initiated entirely by you and uses standard system share sheets locally on your device."
                    ),
                    
                    _buildSubsectionHeader("4.4 Data Retention"),
                    _buildSectionBody(
                      "Non-personal gameplay progress is stored locally on your device and will be retained until you clear the app cache, uninstall the game, or manually reset the score in settings."
                    ),
                    
                    _buildSubsectionHeader("4.5 Data Security"),
                    _buildSectionBody(
                      "Although no personal data is collected or transmitted, we follow industry best practices to secure local storage configuration and prevent local data tampering."
                    ),
                    
                    _buildSubsectionHeader("4.6 Data Subject Rights"),
                    _buildSectionBody(
                      "As no personal data is collected, stored, or processed by Random Walk AI for Life Lab, rights such as deletion, rectification, or access are fully realized by uninstalling the application or resetting data locally."
                    ),
                    
                    _buildSubsectionHeader("4.7 Children's Privacy"),
                    _buildSectionBody(
                      "Life Lab does not knowingly collect any personal information from children under the age of 13. The simulation is safe and operates fully locally for all age groups."
                    ),
                    
                    _buildSubsectionHeader("4.8 Breach Notification"),
                    _buildSectionBody(
                      "Since the application processes no personal data and has no backend server storing user information, the risk of a personal data breach is non-existent. However, we maintain standard incident response protocols."
                    ),
                    const SizedBox(height: 20),

                    _buildSectionHeader("5", "Roles & Responsibilities"),
                    _buildBulletList([
                      "Data Protection Officer (DPO): Ensures compliance with privacy regulations.",
                      "IT & Security Teams: Maintain security of systems and deployment pipelines.",
                      "Employees: Handle user support inquiries responsibly and report incidents immediately."
                    ]),
                    const SizedBox(height: 20),

                    _buildSectionHeader("6", "Monitoring & Compliance"),
                    _buildSectionBody(
                      "Privacy audits of our software products will be conducted annually to ensure no telemetry or tracking is introduced in future releases."
                    ),
                    const SizedBox(height: 20),

                    _buildSectionHeader("7", "Enforcement"),
                    _buildSectionBody(
                      "Violation of this policy may result in disciplinary action, termination, or legal penalties."
                    ),
                    const SizedBox(height: 20),

                    _buildSectionHeader("8", "Review & Maintenance"),
                    _buildSectionBody(
                      "This Privacy Policy will be reviewed annually and updated to reflect evolving legal, regulatory, and contractual obligations."
                    ),
                    
                    const SizedBox(height: 24),
                    _buildCompanyFooter(),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Area
            const Divider(color: Colors.white10, height: 1),
            Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 24,
                right: 24,
                bottom: mediaQuery.padding.bottom + 16,
              ),
              color: card,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: green,
                        side: const BorderSide(color: green, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.open_in_browser, size: 18),
                      label: const Text("WEB VERSION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      onPressed: _openWebVersion,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: bg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: green, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Privacy First Design",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  "Life Lab runs entirely offline on your device. We do not track you, collect metadata, or upload any personal data to servers.",
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String index, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Row(
        children: [
          Text(
            "$index. ",
            style: const TextStyle(color: green, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0, left: 12.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 12.0),
      padding: const EdgeInsets.only(left: 12.0),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.white10, width: 2)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _buildBulletList(List<String> bullets) {
    return Container(
      margin: const EdgeInsets.only(left: 12.0),
      padding: const EdgeInsets.only(left: 12.0),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.white10, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bullets.map((b) {
          final parts = b.split(':');
          if (parts.length > 1 && parts[0].length < 25) {
            // Bold definitions
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "• ${parts[0]}:",
                      style: const TextStyle(color: green, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: parts.sublist(1).join(':')),
                  ],
                ),
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(color: green, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    b,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompanyFooter() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 16),
      child: const Column(
        children: [
          Text(
            "Random Walk AI Support",
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "support@randomwalk.ai",
            style: TextStyle(color: green, fontSize: 12, decoration: TextDecoration.underline),
          ),
          SizedBox(height: 8),
          Text(
            "© 2026 Random Walk AI. All rights reserved.",
            style: TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
