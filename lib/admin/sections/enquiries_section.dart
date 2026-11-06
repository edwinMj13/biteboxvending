import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/content/content_providers.dart';
import '../../core/content/site_content_models.dart';
import '../admin_theme.dart';
import '../widgets/admin_ui.dart';
import '../../shared/widgets/brand_icons.dart';

/// Lists franchise enquiries submitted from the public Franchise page.
class EnquiriesSection extends ConsumerStatefulWidget {
  const EnquiriesSection({super.key});

  @override
  ConsumerState<EnquiriesSection> createState() => _EnquiriesSectionState();
}

class _EnquiriesSectionState extends ConsumerState<EnquiriesSection> {
  String _query = '';
  EnquiryChannel? _channelFilter;

  Future<void> _delete(FranchiseEnquiry e) async {
    final confirmed = await confirmAdminAction(
      context,
      title: 'Delete enquiry?',
      message: 'The enquiry from ${e.name} will be permanently removed.',
    );
    if (!confirmed) return;
    try {
      await ref.read(contentRepositoryProvider).deleteEnquiry(e.id!);
      if (mounted) showAdminSnack(context, 'Enquiry deleted');
    } catch (err) {
      if (mounted) showAdminSnack(context, 'Delete failed: $err', error: true);
    }
  }

  List<FranchiseEnquiry> _filter(List<FranchiseEnquiry> list) {
    final q = _query.toLowerCase();
    return list.where((e) {
      if (_channelFilter != null && e.channel != _channelFilter) return false;
      if (q.isEmpty) return true;
      return e.name.toLowerCase().contains(q) ||
          e.location.toLowerCase().contains(q) ||
          e.phone.contains(q) ||
          e.email.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final enquiries = ref.watch(enquiriesProvider);

    return enquiries.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AdminCard(
        child: AdminEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load enquiries',
          message: '$e',
        ),
      ),
      data: (list) {
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        final thisWeek =
            list.where((e) => e.createdAt?.isAfter(weekAgo) ?? true).length;
        int via(EnquiryChannel c) => list.where((e) => e.channel == c).length;
        final filtered = _filter(list);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminMetricRow(
              tiles: [
                AdminMetricTile(
                  label: 'Total enquiries',
                  value: '${list.length}',
                  icon: Icons.inbox_outlined,
                  color: AdminColors.primaryDark,
                ),
                AdminMetricTile(
                  label: 'Last 7 days',
                  value: '$thisWeek',
                  icon: Icons.calendar_today_outlined,
                  color: AdminColors.accent,
                ),
                AdminMetricTile(
                  label: 'Via WhatsApp',
                  value: '${via(EnquiryChannel.whatsapp)}',
                  leading: const BrandLogo(Brand.whatsapp, size: 20),
                  color: _channelColor(EnquiryChannel.whatsapp),
                ),
                AdminMetricTile(
                  label: 'Via Email / Form',
                  value:
                      '${via(EnquiryChannel.email) + via(EnquiryChannel.direct)}',
                  icon: Icons.email_outlined,
                  color: _channelColor(EnquiryChannel.email),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        child: AdminSearchField(
                          hint: 'Search name, phone, email, location…',
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _channelFilter == null,
                        onSelected: (_) =>
                            setState(() => _channelFilter = null),
                      ),
                      for (final c in EnquiryChannel.values)
                        ChoiceChip(
                          label: Text(c.label),
                          selected: _channelFilter == c,
                          onSelected: (_) => setState(() => _channelFilter = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (list.isEmpty)
                    const AdminEmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No enquiries yet',
                      message: 'Enquiries sent from the Franchise page '
                          'will appear here.',
                    )
                  else if (filtered.isEmpty)
                    const AdminEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matching enquiries',
                      message: 'Try a different search or filter.',
                    )
                  else
                    for (final e in filtered)
                      _EnquiryCard(enquiry: e, onDelete: () => _delete(e)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

Color _channelColor(EnquiryChannel c) => switch (c) {
      EnquiryChannel.whatsapp => const Color(0xFF16A34A),
      EnquiryChannel.email => const Color(0xFF2563EB),
      EnquiryChannel.direct => AdminColors.accent,
    };

Widget _channelLogo(EnquiryChannel c, {double size = 12}) => switch (c) {
      EnquiryChannel.whatsapp => BrandLogo(Brand.whatsapp, size: size),
      EnquiryChannel.email =>
        Icon(Icons.email_outlined, size: size, color: _channelColor(c)),
      EnquiryChannel.direct =>
        Icon(Icons.language_rounded, size: size, color: _channelColor(c)),
    };

class _EnquiryCard extends StatelessWidget {
  final FranchiseEnquiry enquiry;
  final VoidCallback onDelete;

  const _EnquiryCard({required this.enquiry, required this.onDelete});

  String _formatDate(DateTime? d) {
    if (d == null) return 'Just now';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}, ${two(d.hour)}:${two(d.minute)}';
  }

  /// "96568 61728" → "919656861728" for wa.me links.
  String get _whatsappDigits {
    final digits = enquiry.phone.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10 ? '91$digits' : digits;
  }

  @override
  Widget build(BuildContext context) {
    final e = enquiry;
    final initial = e.name.isNotEmpty ? e.name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AdminColors.primary.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AdminColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AdminColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${e.location}  ·  ${_formatDate(e.createdAt)}',
                      style: const TextStyle(
                        color: AdminColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              AdminPill(
                label: e.channel.label,
                color: _channelColor(e.channel),
                leading: _channelLogo(e.channel),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(
                  Icons.delete_outline,
                  color: AdminColors.danger,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
          if (e.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminColors.border),
              ),
              child: Text(
                e.message,
                style: const TextStyle(color: AdminColors.text, height: 1.4),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionChip(
                icon: const Icon(Icons.phone_outlined,
                    size: 16, color: AdminColors.primaryDark),
                label: e.phone,
                url: 'tel:${e.phone.replaceAll(RegExp(r'[^\d+]'), '')}',
              ),
              _ActionChip(
                icon: const BrandLogo(Brand.whatsapp, size: 16),
                label: 'WhatsApp',
                url: 'https://wa.me/$_whatsappDigits',
              ),
              _ActionChip(
                icon: const Icon(Icons.email_outlined,
                    size: 16, color: AdminColors.primaryDark),
                label: e.email,
                url: 'mailto:${e.email}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final Widget icon;
  final String label;
  final String url;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: icon,
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AdminColors.border),
      onPressed: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    );
  }
}
