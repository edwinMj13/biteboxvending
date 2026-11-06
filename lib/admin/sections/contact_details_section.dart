import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/content/content_providers.dart';
import '../../core/content/site_content_models.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../admin_theme.dart';
import '../widgets/admin_ui.dart';
import '../../shared/widgets/brand_icons.dart';

/// Edits `site_content/contact`. Shown on the public site in the header
/// helpline, footer, Get In Touch page and franchise enquiry flow.
class ContactDetailsSection extends ConsumerStatefulWidget {
  const ContactDetailsSection({super.key});

  @override
  ConsumerState<ContactDetailsSection> createState() =>
      _ContactDetailsSectionState();
}

class _ContactDetailsSectionState extends ConsumerState<ContactDetailsSection> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();
  final _franchiseEmail = TextEditingController();
  final _address = TextEditingController();
  final _instagram = TextEditingController();
  final _facebook = TextEditingController();

  late final _controllers = [
    _phone,
    _whatsapp,
    _email,
    _franchiseEmail,
    _address,
    _instagram,
    _facebook,
  ];

  bool _loaded = false;
  bool _dirty = false;
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _fill(ContactInfo c) {
    _phone.text = c.phone;
    _whatsapp.text = c.whatsappNumber;
    _email.text = c.email;
    _franchiseEmail.text = c.franchiseEmail;
    _address.text = c.address;
    _instagram.text = c.instagramUrl;
    _facebook.text = c.facebookUrl;
    for (final ctrl in _controllers) {
      ctrl.addListener(_markDirty);
    }
  }

  void _discard() {
    for (final ctrl in _controllers) {
      ctrl.removeListener(_markDirty);
    }
    _fill(ref.read(contactProvider));
    setState(() => _dirty = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(contentRepositoryProvider).saveContact(
            ContactInfo(
              phone: _phone.text.trim(),
              whatsappNumber: _whatsapp.text.trim(),
              email: _email.text.trim(),
              franchiseEmail: _franchiseEmail.text.trim(),
              address: _address.text.trim(),
              instagramUrl: _instagram.text.trim(),
              facebookUrl: _facebook.text.trim(),
            ),
          );
      if (mounted) {
        setState(() => _dirty = false);
        showAdminSnack(context, 'Contact details saved');
      }
    } catch (e) {
      if (mounted) showAdminSnack(context, 'Save failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Required' : null;

  String? _validEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v.trim())
        ? null
        : 'Enter a valid email address';
  }

  String? _optionalUrl(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return v.trim().startsWith('http') ? null : 'Must start with https://';
  }

  @override
  Widget build(BuildContext context) {
    final contact = ref.watch(contactInfoProvider);

    // Fill the form once, the first time data arrives.
    if (!_loaded && contact.hasValue) {
      _loaded = true;
      _fill(contact.value!);
    }
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final phoneCard = AdminCard(
      title: 'Phone & WhatsApp',
      subtitle: 'Helpline in the header and footer',
      icon: Icons.phone_in_talk_outlined,
      child: Column(
        children: [
          CustomTextField(
            controller: _phone,
            label: 'Helpline Phone',
            hint: '+91 81290 37133',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: _required,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _whatsapp,
            label: 'WhatsApp Number',
            hint: '918129037133 (country code, digits only)',
            prefix: const BrandLogo(Brand.whatsapp, size: 18),
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              return RegExp(r'^\d{8,15}$').hasMatch(v.trim())
                  ? null
                  : 'Digits only, e.g. 918129037133';
            },
          ),
        ],
      ),
    );

    final emailCard = AdminCard(
      title: 'Email',
      subtitle: 'Support and franchise enquiry inboxes',
      icon: Icons.alternate_email_rounded,
      child: Column(
        children: [
          CustomTextField(
            controller: _email,
            label: 'Support Email',
            hint: 'biteboxkochi@gmail.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validEmail,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _franchiseEmail,
            label: 'Franchise Enquiry Email',
            hint: 'Where franchise enquiries are emailed',
            prefixIcon: Icons.mark_email_unread_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validEmail,
          ),
        ],
      ),
    );

    final addressCard = AdminCard(
      title: 'Address',
      subtitle: 'Footer and Get In Touch page',
      icon: Icons.location_on_outlined,
      child: CustomTextField(
        controller: _address,
        label: 'Headquarters Address',
        hint: 'BiteBox 24/7 Vending, Kochi, Kerala, India',
        prefixIcon: Icons.business_outlined,
        maxLines: 2,
        validator: _required,
      ),
    );

    final socialCard = AdminCard(
      title: 'Social Links',
      subtitle: 'Leave a link empty to hide its button',
      icon: Icons.share_outlined,
      child: Column(
        children: [
          CustomTextField(
            controller: _instagram,
            label: 'Instagram URL',
            hint: 'https://www.instagram.com/biteboxkochi',
            prefix: const BrandLogo(Brand.instagram, size: 18),
            keyboardType: TextInputType.url,
            validator: _optionalUrl,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _facebook,
            label: 'Facebook URL',
            hint: 'https://www.facebook.com/...',
            prefix: const BrandLogo(Brand.facebook, size: 18),
            keyboardType: TextInputType.url,
            validator: _optionalUrl,
          ),
        ],
      ),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    for (final card in [
                      phoneCard,
                      emailCard,
                      addressCard,
                      socialCard,
                    ]) ...[card, const SizedBox(height: 16)],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        phoneCard,
                        const SizedBox(height: 16),
                        addressCard,
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        emailCard,
                        const SizedBox(height: 16),
                        socialCard,
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _SaveBar(
            dirty: _dirty,
            isSaving: _isSaving,
            onSave: _save,
            onDiscard: _discard,
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final bool dirty;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const _SaveBar({
    required this.dirty,
    required this.isSaving,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                dirty ? Icons.edit_note_rounded : Icons.cloud_done_outlined,
                color: dirty ? AdminColors.warning : AdminColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                dirty ? 'You have unsaved changes' : 'All changes saved',
                style: TextStyle(
                  color: dirty ? AdminColors.warning : AdminColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dirty) ...[
                TextButton(
                  onPressed: isSaving ? null : onDiscard,
                  child: const Text('Discard'),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: dirty && !isSaving ? onSave : null,
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
