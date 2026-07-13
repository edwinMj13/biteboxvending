import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/footer_section.dart';
import '../../../../shared/widgets/screen_title.dart';

class FranchiseScreen extends StatefulWidget {
  const FranchiseScreen({super.key});

  @override
  State<FranchiseScreen> createState() => _FranchiseScreenState();
}

class _FranchiseScreenState extends State<FranchiseScreen> {
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate network request
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
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
      });
    }
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
                                        validator: (val) => val == null ||
                                                val.isEmpty
                                            ? 'Please enter your name'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _emailController,
                                        label: 'Email Address',
                                        hint: 'Enter your email',
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                              .hasMatch(val)) {
                                            return 'Enter a valid email address';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _phoneController,
                                        label: 'Phone Number',
                                        hint: 'Enter your mobile number',
                                        prefixIcon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        validator: (val) => val == null ||
                                                val.isEmpty
                                            ? 'Please enter your phone number'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _locationController,
                                        label: 'Preferred Location / City',
                                        hint: 'e.g., Ernakulam, Infopark',
                                        prefixIcon: Icons.location_on_outlined,
                                        validator: (val) => val == null ||
                                                val.isEmpty
                                            ? 'Please specify a preferred location'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _messageController,
                                        label: 'Additional Information',
                                        hint:
                                            'Tell us about your background or location access details...',
                                        prefixIcon: Icons.notes_outlined,
                                        maxLines: 4,
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
        const Text(
          'Thank you for reaching out. We have logged your franchise interest and will connect with you very soon.',
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
