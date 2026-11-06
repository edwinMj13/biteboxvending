import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/content/content_providers.dart';
import '../../../../core/content/site_content_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/footer_section.dart';
import '../../../../shared/widgets/screen_title.dart';
import '../../../../shared/widgets/brand_icons.dart';
import '../../../../shared/validators/form_validators.dart';

class FranchiseScreen extends ConsumerStatefulWidget {
  const FranchiseScreen({super.key});

  @override
  ConsumerState<FranchiseScreen> createState() => _FranchiseScreenState();
}

class _FranchiseScreenState extends ConsumerState<FranchiseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;
  bool _submitSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  EnquiryChannel _sentVia = EnquiryChannel.direct;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final channel = await _askEnquiryChannel();
    if (channel == null) return;
    await _sendEnquiry(channel);
  }

  /// Lets the visitor choose how to send: WhatsApp, Email or website only.
  /// Bottom sheet on mobile, dialog on desktop.
  Future<EnquiryChannel?> _askEnquiryChannel() {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    // Pop with the popup's own context: the dialog lives on the root
    // navigator, while this screen sits inside a nested tab navigator.
    // Popping with the screen's context would remove the tab's only page.
    Widget options(BuildContext popupContext) => _EnquiryChannelOptions(
          onSelected: (channel) => Navigator.of(popupContext).pop(channel),
        );

    if (!isDesktop) {
      return showModalBottomSheet<EnquiryChannel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Send your enquiry',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose how you would like to reach us.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                options(context),
              ],
            ),
          ),
        ),
      );
    }

    return showDialog<EnquiryChannel>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('How would you like to send your enquiry?'),
        content: SizedBox(width: 440, child: options(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEnquiry(EnquiryChannel channel) async {
    setState(() {
      _isSubmitting = true;
    });

    final contact = ref.read(contactProvider);
    final enquiry = FranchiseEnquiry(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      // Saved as "+91 98765 43210" so the admin's call/WhatsApp links work
      // whatever format the visitor typed.
      phone: FormValidators.formatIndianMobile(_phoneController.text),
      location: _locationController.text.trim(),
      message: _messageController.text.trim(),
      channel: channel,
    );

    // Open WhatsApp / email first, while the browser still treats this as
    // a user action (pop-up blockers reject delayed window opens).
    var launched = true;
    if (channel == EnquiryChannel.whatsapp) {
      launched = await _tryLaunch(
        Uri.parse(contact.whatsappUrl(enquiry.toMessageText())),
      );
    } else if (channel == EnquiryChannel.email) {
      launched = await _tryLaunch(
        Uri(
          scheme: 'mailto',
          path: contact.franchiseEmail,
          query: _encodeQueryParameters({
            'subject': 'Franchise Enquiry from ${enquiry.name}',
            'body': enquiry.toMessageText(),
          }),
        ),
      );
    }

    // Always store the enquiry so it shows up in the admin portal.
    var saved = true;
    try {
      await ref
          .read(contentRepositoryProvider)
          .submitEnquiry(enquiry)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      saved = false;
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    final succeeded = channel == EnquiryChannel.direct ? saved : launched;
    if (!succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            channel == EnquiryChannel.direct
                ? 'Could not submit your enquiry. Please try WhatsApp or Email.'
                : 'Could not open ${channel.label}. Please try another option.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _sentVia = channel;
      _submitSuccess = true;
    });

    // Reset after a delay
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _submitSuccess = false;
        });
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _locationController.clear();
        _messageController.clear();
      }
    });
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner Section
          _buildBannerSection(context, isDesktop),

          // Main Body
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
                    // Guide Info
                    Expanded(
                      flex: isDesktop ? 5 : 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScreenTitle(
                            title: 'Franchise Partnership',
                            subtitle:
                                'Start a highly profitable, passive automated vending business in your city.',
                          ),
                          const SizedBox(height: 32),
                          !isDesktop
                              ? Column(
                                  children: [
                                    _buildMobilePipelineStep(
                                      context,
                                      number: '1',
                                      title: 'Find a Location',
                                      description: 'Identify high-traffic zones like hospitals, colleges, government offices, transit hubs, or tech parks.',
                                      isLast: false,
                                    ),
                                    _buildMobilePipelineStep(
                                      context,
                                      number: '2',
                                      title: 'Technical Installation',
                                      description: 'BiteBox handles machine logistics, customization wraps, and sets up cashless payment modules.',
                                      isLast: false,
                                    ),
                                    _buildMobilePipelineStep(
                                      context,
                                      number: '3',
                                      title: 'Earn Passive Income',
                                      description: 'Replenish inventory easily with our operator dashboard, tracking sales and stock live via IoT.',
                                      isLast: true,
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildStepTile(
                                      number: '1',
                                      title: 'Find a Location',
                                      description: 'Identify high-traffic zones like hospitals, colleges, government offices, transit hubs, or tech parks.',
                                    ),
                                    _buildStepTile(
                                      number: '2',
                                      title: 'Technical Installation',
                                      description: 'BiteBox handles machine logistics, customization wraps, and sets up cashless payment modules.',
                                    ),
                                    _buildStepTile(
                                      number: '3',
                                      title: 'Earn Passive Income',
                                      description: 'Replenish inventory easily with our operator dashboard, tracking sales and stock live via IoT.',
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primary(context).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppTheme.primary(context).withOpacity(0.35),
                                  width: 1.2),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.black87),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'We provide full support, from machine branding vinyls to training, telemetry dashboards, and 24/7 tech assistance.',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDesktop) const SizedBox(width: 64),
                    if (!isDesktop) const SizedBox(height: 40),

                    // Inquiry Form
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
                              color: AppTheme.primary(context).withOpacity(0.05),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Franchise Inquiry Form',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Fill out the details below and our partnership manager will contact you in 24 hours.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const Divider(height: 32),
                                      CustomTextField(
                                        controller: _nameController,
                                        label: 'Full Name',
                                        hint: 'Enter your name',
                                        prefixIcon: Icons.person_outline,
                                        validator: FormValidators.name,
                                        inputFormatters: FormValidators.nameFormatters,
                                        textCapitalization: TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [AutofillHints.name],
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _emailController,
                                        label: 'Email Address',
                                        hint: 'Enter your email',
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: FormValidators.email,
                                        inputFormatters: FormValidators.emailFormatters,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [AutofillHints.email],
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _phoneController,
                                        label: 'Phone Number',
                                        hint: 'e.g. 98765 43210',
                                        prefixIcon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        validator: FormValidators.indianMobile,
                                        inputFormatters: FormValidators.phoneFormatters,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [AutofillHints.telephoneNumber],
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _locationController,
                                        label: 'Preferred Location / City',
                                        hint: 'e.g., Ernakulam, Infopark',
                                        prefixIcon: Icons.location_on_outlined,
                                        validator: FormValidators.text(
                                          emptyMessage: 'Please specify a preferred location',
                                          fieldName: 'Location',
                                          max: FormValidators.locationMax,
                                        ),
                                        maxLength: FormValidators.locationMax,
                                        textCapitalization: TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _messageController,
                                        label: 'Additional Information',
                                        hint:
                                            'Tell us about your background or location access details...',
                                        prefixIcon: Icons.notes_outlined,
                                        maxLines: 4,
                                        isOptional: true,
                                        maxLength: FormValidators.messageMax,
                                        textCapitalization: TextCapitalization.sentences,
                                        validator: FormValidators.optionalText(
                                          fieldName: 'Additional information',
                                          max: FormValidators.messageMax,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      CustomButton(
                                        text: 'Submit Inquiry',
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

  Widget _buildBannerSection(BuildContext context, bool isDesktop) {
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
                'FRANCHISE OPPORTUNITIES',
                style: TextStyle(
                  color: AppTheme.primary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Grow With BiteBox',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTile({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary(context),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Inquiry Submitted!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _sentVia == EnquiryChannel.direct
              ? 'Thank you for reaching out. We have logged your franchise interest and will connect with you very soon.'
              : 'Thank you! Please press send in ${_sentVia.label} to deliver your message. We will connect with you very soon.',
          style: TextStyle(color: Colors.black54, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMobilePipelineStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
    required bool isLast,
  }) {
    final primaryColor = AppTheme.primary(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: primaryColor.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The three ways to send a franchise enquiry.
class _EnquiryChannelOptions extends StatelessWidget {
  final ValueChanged<EnquiryChannel> onSelected;
  const _EnquiryChannelOptions({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primary(context);

    Widget option({
      required EnquiryChannel channel,
      required Widget logo,
      required Color color,
      required String title,
      required String subtitle,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelected(channel),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: logo,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: color),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        option(
          channel: EnquiryChannel.whatsapp,
          logo: const BrandLogo(Brand.whatsapp, size: 24),
          color: Brand.whatsapp.color,
          title: 'Send via WhatsApp',
          subtitle: 'Opens WhatsApp with your details filled in',
        ),
        option(
          channel: EnquiryChannel.email,
          logo: Icon(Icons.email_rounded, color: Colors.blue.shade600),
          color: Colors.blue.shade600,
          title: 'Send via Email',
          subtitle: 'Opens your email app with your details filled in',
        ),
        option(
          channel: EnquiryChannel.direct,
          logo: Icon(Icons.send_rounded, color: primary),
          color: primary,
          title: 'Submit Enquiry',
          subtitle: 'Send it straight to our team, we will contact you',
        ),
      ],
    );
  }
}
