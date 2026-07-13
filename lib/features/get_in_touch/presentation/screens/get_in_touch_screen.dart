import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/footer_section.dart';
import '../../../../shared/widgets/screen_title.dart';

class GetInTouchScreen extends StatefulWidget {
  const GetInTouchScreen({super.key});

  @override
  State<GetInTouchScreen> createState() => _GetInTouchScreenState();
}

class _GetInTouchScreenState extends State<GetInTouchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;
  bool _submitSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final name = _nameController.text;
        final email = _emailController.text;
        final subject = _subjectController.text;
        final message = _messageController.text;

        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: 'biteboxkochi@gmail.com',
          query: _encodeQueryParameters(<String, String>{
            'subject': subject.isNotEmpty
                ? subject
                : 'BiteBox Enquiry from $name',
            'body': 'Name: $name\nEmail: $email\n\nMessage:\n$message',
          }),
        );

        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('No email app found to send the email.');
        }

        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _submitSuccess = true;
          });

          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              setState(() {
                _submitSuccess = false;
              });
              _nameController.clear();
              _emailController.clear();
              _subjectController.clear();
              _messageController.clear();
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open email app: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner
          _buildBannerSection(isDesktop),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64 : 20,
              vertical: 60,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Flex(
                  direction: isDesktop ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Info & Direct Actions
                    Expanded(
                      flex: isDesktop ? 5 : 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScreenTitle(
                            title: 'Contact Us',
                            subtitle:
                                'Have a question about our vending machines, refunds, or operations? Reach out directly.',
                          ),
                          const SizedBox(height: 32),
                          _buildContactInfoTile(
                            context,
                            icon: Icons.location_on_rounded,
                            title: 'Headquarters',
                            content:
                                'BiteBox 24/7 Vending, Kochi, Kerala, India',
                          ),
                          _buildContactInfoTile(
                            context,
                            icon: Icons.phone_rounded,
                            title: 'Call Support',
                            content: '+91 81290 37133',
                            onTap: () => _launchUrl('tel:+918129037133'),
                          ),
                          _buildContactInfoTile(
                            context,
                            icon: Icons.email_rounded,
                            title: 'Email Address',
                            content: 'biteboxkochi@gmail.com',
                            onTap: () =>
                                _launchUrl('mailto:biteboxkochi@gmail.com'),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Quick Chat Channels',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              CustomButton(
                                text: 'Chat on WhatsApp',
                                icon: Icons.chat_bubble_outline_rounded,
                                onPressed: () =>
                                    _launchUrl('https://wa.me/918129037133'),
                              ),
                              CustomButton(
                                text: 'Follow on Instagram',
                                icon: Icons.camera_alt_outlined,
                                isPrimary: false,
                                onPressed: () => _launchUrl(
                                  'https://www.instagram.com/biteboxkochi',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isDesktop) const SizedBox(width: 64),
                    if (!isDesktop) const SizedBox(height: 40),

                    // Contact Form Card
                    Expanded(
                      flex: isDesktop ? 6 : 0,
                      child: Container(
                        decoration: AppTheme.cardDecoration(context).copyWith(
                          border: Border.all(
                            color: AppTheme.primary(context).withOpacity(0.18),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary(
                                context,
                              ).withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 32.0 : 20.0),
                          child: _submitSuccess
                              ? _buildSuccessWidget()
                              : Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Send a Message',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Fill in the contact form below and we will get back to you.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const Divider(height: 32),
                                      CustomTextField(
                                        controller: _nameController,
                                        label: 'Your Name',
                                        hint: 'Enter your name',
                                        prefixIcon: Icons.person_outline,
                                        validator: (val) =>
                                            val == null || val.isEmpty
                                            ? 'Please enter your name'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _emailController,
                                        label: 'Email Address',
                                        hint: 'Enter your email address',
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(val)) {
                                            return 'Enter a valid email address';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _subjectController,
                                        label: 'Subject',
                                        hint: 'Enter subject of message',
                                        prefixIcon: Icons.topic_outlined,
                                        validator: (val) =>
                                            val == null || val.isEmpty
                                            ? 'Please enter a subject'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _messageController,
                                        label: 'Message',
                                        hint:
                                            'Write your message details here...',
                                        prefixIcon: Icons.chat_outlined,
                                        maxLines: 4,
                                        validator: (val) =>
                                            val == null || val.isEmpty
                                            ? 'Please enter a message'
                                            : null,
                                      ),
                                      const SizedBox(height: 32),
                                      CustomButton(
                                        text: 'Send Message',
                                        isLoading: _isSubmitting,
                                        onPressed: _submitForm,
                                        width: double.infinity,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          const FooterSection(),
        ],
      ),
    );
  }

  Widget _buildBannerSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: AppTheme.darkColor(context),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 40,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GET IN TOUCH',
                style: TextStyle(
                  color: AppTheme.primary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect With Us 24/7',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    final primaryColor = AppTheme.primary(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: AppTheme.cardDecoration(context).copyWith(
          border: Border.all(color: primaryColor.withOpacity(0.12), width: 1.2),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 13,
                          color: onTap != null ? primaryColor : Colors.black54,
                          fontWeight: onTap != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                          decoration: onTap != null
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          decorationColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 24),
        const Text(
          'Message Sent Successfully!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Thank you for contacting BiteBox 24/7. We will get in touch with you shortly.',
          style: TextStyle(color: Colors.black54, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
