import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/content/content_providers.dart';
import '../../core/content/site_content_models.dart';
import '../admin_theme.dart';
import '../widgets/admin_ui.dart';

/// Manages the `machines` collection shown on the public Find Us page.
class MachinesSection extends ConsumerStatefulWidget {
  const MachinesSection({super.key});

  @override
  ConsumerState<MachinesSection> createState() => _MachinesSectionState();
}

class _MachinesSectionState extends ConsumerState<MachinesSection> {
  String _query = '';
  MachineStatus? _statusFilter;

  Future<void> _run(Future<void> Function() action, String done) async {
    try {
      await action();
      if (mounted) showAdminSnack(context, done);
    } catch (e) {
      if (mounted) showAdminSnack(context, 'Failed: $e', error: true);
    }
  }

  Future<void> _edit([MachineLocation? machine]) async {
    final result = await showDialog<MachineLocation>(
      context: context,
      builder: (_) => _MachineDialog(machine: machine),
    );
    if (result == null) return;
    await _run(
      () => ref.read(contentRepositoryProvider).saveMachine(result),
      'Saved ${result.name}',
    );
  }

  Future<void> _delete(MachineLocation machine) async {
    final confirmed = await confirmAdminAction(
      context,
      title: 'Delete ${machine.name}?',
      message: 'It will be removed from the Find Us page.',
    );
    if (!confirmed) return;
    await _run(
      () => ref.read(contentRepositoryProvider).deleteMachine(machine.id),
      'Deleted ${machine.name}',
    );
  }

  List<MachineLocation> _filter(List<MachineLocation> list) {
    final q = _query.toLowerCase();
    return list.where((m) {
      if (_statusFilter != null && m.status != _statusFilter) return false;
      if (q.isEmpty) return true;
      return m.name.toLowerCase().contains(q) ||
          m.district.toLowerCase().contains(q) ||
          m.address.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final machines = ref.watch(machinesProvider);

    return machines.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AdminCard(
        child: AdminEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load machines',
          message: '$e',
        ),
      ),
      data: (list) {
        if (list.isEmpty) return _buildEmpty();

        int count(MachineStatus s) => list.where((m) => m.status == s).length;
        final filtered = _filter(list);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminMetricRow(
              tiles: [
                AdminMetricTile(
                  label: 'Total machines',
                  value: '${list.length}',
                  icon: Icons.storefront_outlined,
                  color: AdminColors.primaryDark,
                ),
                AdminMetricTile(
                  label: MachineStatus.stocked.label,
                  value: '${count(MachineStatus.stocked)}',
                  icon: _statusIcon(MachineStatus.stocked),
                  color: _statusColor(MachineStatus.stocked),
                ),
                AdminMetricTile(
                  label: MachineStatus.lowStock.label,
                  value: '${count(MachineStatus.lowStock)}',
                  icon: _statusIcon(MachineStatus.lowStock),
                  color: _statusColor(MachineStatus.lowStock),
                ),
                AdminMetricTile(
                  label: MachineStatus.offline.label,
                  value: '${count(MachineStatus.offline)}',
                  icon: _statusIcon(MachineStatus.offline),
                  color: _statusColor(MachineStatus.offline),
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
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 300,
                        child: AdminSearchField(
                          hint: 'Search name, district, address…',
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _edit(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add machine'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _statusFilter == null,
                        onSelected: (_) => setState(() => _statusFilter = null),
                      ),
                      for (final s in MachineStatus.values)
                        ChoiceChip(
                          label: Text(s.label),
                          selected: _statusFilter == s,
                          onSelected: (_) => setState(() => _statusFilter = s),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (filtered.isEmpty)
                    const AdminEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matching machines',
                      message: 'Try a different search or filter.',
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 900
                            ? 3
                            : constraints.maxWidth >= 560
                                ? 2
                                : 1;
                        const spacing = 12.0;
                        final width =
                            (constraints.maxWidth - spacing * (columns - 1)) /
                                columns;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final m in filtered)
                              SizedBox(
                                width: width,
                                child: _MachineCard(
                                  machine: m,
                                  onEdit: () => _edit(m),
                                  onDelete: () => _delete(m),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return AdminCard(
      child: AdminEmptyState(
        icon: Icons.storefront_outlined,
        title: 'No machines saved yet',
        message: 'The Find Us page shows "No machines" until you add one.',
        action: ElevatedButton.icon(
          onPressed: () => _edit(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add machine'),
        ),
      ),
    );
  }
}

Color _statusColor(MachineStatus status) => switch (status) {
      MachineStatus.stocked => AdminColors.success,
      MachineStatus.lowStock => AdminColors.warning,
      MachineStatus.offline => AdminColors.danger,
    };

/// One icon per status, used by the summary tiles, cards and the edit dialog.
IconData _statusIcon(MachineStatus status) => switch (status) {
      MachineStatus.stocked => Icons.check_circle_outline,
      MachineStatus.lowStock => Icons.inventory_2_outlined,
      MachineStatus.offline => Icons.build_circle_outlined,
    };

class _MachineCard extends StatelessWidget {
  final MachineLocation machine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MachineCard({
    required this.machine,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              AdminPill(
                label: machine.district,
                color: AdminColors.primaryDark,
                icon: Icons.place_outlined,
              ),
              const Spacer(),
              AdminPill(
                label: machine.status.label,
                color: _statusColor(machine.status),
                icon: _statusIcon(machine.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            machine.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AdminColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            machine.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AdminColors.muted, fontSize: 13),
          ),
          if (machine.landmark.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '📍 ${machine.landmark}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AdminColors.muted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AdminColors.danger,
                ),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MachineDialog extends StatefulWidget {
  final MachineLocation? machine;
  const _MachineDialog({this.machine});

  @override
  State<_MachineDialog> createState() => _MachineDialogState();
}

class _MachineDialogState extends State<_MachineDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.machine?.name);
  late final _district = TextEditingController(text: widget.machine?.district);
  late final _address = TextEditingController(text: widget.machine?.address);
  late final _landmark = TextEditingController(text: widget.machine?.landmark);
  late MachineStatus _status = widget.machine?.status ?? MachineStatus.stocked;

  @override
  void dispose() {
    for (final c in [_name, _district, _address, _landmark]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    final isNew = widget.machine == null;

    return AlertDialog(
      title: Text(isNew ? 'Add machine' : 'Edit machine'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Machine name',
                    hintText: 'Enter machine name',
                    prefixIcon: Icon(Icons.local_convenience_store_outlined, size: 20),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _district,
                  decoration: const InputDecoration(
                    labelText: 'District',
                    hintText: 'Enter district',
                    prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _address,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter full address',
                    alignLabelWithHint: true,
                    // Keep the pin on the first line of the 2-line field.
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 22),
                      child: Icon(Icons.location_on_outlined, size: 20),
                    ),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _landmark,
                  decoration: const InputDecoration(
                    labelText: 'Landmark (optional)',
                    hintText: 'Enter a nearby landmark',
                    prefixIcon: Icon(Icons.near_me_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AdminColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in MachineStatus.values)
                      ChoiceChip(
                        label: Text(s.label),
                        selected: _status == s,
                        // Keep the status icon visible when selected
                        // (the default checkmark would replace it).
                        showCheckmark: false,
                        selectedColor: _statusColor(s).withValues(alpha: 0.18),
                        side: BorderSide(
                          color: _status == s
                              ? _statusColor(s)
                              : AdminColors.border,
                        ),
                        avatar: Icon(
                          _statusIcon(s),
                          size: 18,
                          color: _statusColor(s),
                        ),
                        onSelected: (_) => setState(() => _status = s),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              MachineLocation(
                // Empty id → a new id is generated when saving.
                id: widget.machine?.id ?? '',
                name: _name.text.trim(),
                district: _district.text.trim(),
                address: _address.text.trim(),
                landmark: _landmark.text.trim(),
                status: _status,
              ),
            );
          },
          child: Text(isNew ? 'Add machine' : 'Save changes'),
        ),
      ],
    );
  }
}
