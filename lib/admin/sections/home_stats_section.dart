import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/content/content_providers.dart';
import '../../core/content/site_content_models.dart';
import '../admin_theme.dart';
import '../widgets/admin_ui.dart';

/// Edits `site_content/home_stats` — the "BiteBox in Numbers" section
/// on the public home page (Active Machines, Daily Customers, ...).
class HomeStatsSection extends ConsumerStatefulWidget {
  const HomeStatsSection({super.key});

  @override
  ConsumerState<HomeStatsSection> createState() => _HomeStatsSectionState();
}

class _HomeStatsSectionState extends ConsumerState<HomeStatsSection> {
  final List<_StatRow> _rows = [];
  bool _loaded = false;
  bool _isSaving = false;

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow([StatItem? item]) {
    _rows.add(_StatRow(item ?? const StatItem(value: '', label: '')));
  }

  List<StatItem> get _currentStats => _rows
      .map((r) => StatItem(
            value: r.value.text.trim(),
            label: r.label.text.trim(),
          ))
      .where((s) => s.value.isNotEmpty || s.label.isNotEmpty)
      .toList();

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(contentRepositoryProvider).saveHomeStats(_currentStats);
      if (mounted) showAdminSnack(context, 'Home numbers saved');
    } catch (e) {
      if (mounted) showAdminSnack(context, 'Save failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _move(int from, int to) => setState(() {
        final row = _rows.removeAt(from);
        _rows.insert(to, row);
      });

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(homeStatsProvider);

    // Fill the editor once, the first time data arrives.
    if (!_loaded && stats.hasValue) {
      _loaded = true;
      (stats.value ?? SiteDefaults.homeStats).forEach(_addRow);
    }
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live preview, rebuilt as the admin types.
        ListenableBuilder(
          listenable: Listenable.merge([
            for (final r in _rows) ...[r.value, r.label],
          ]),
          builder: (context, _) => _StatsPreview(stats: _currentStats),
        ),
        const SizedBox(height: 16),
        AdminCard(
          title: 'Edit Numbers',
          subtitle: 'Value is the big figure, label is the text below it',
          icon: Icons.edit_outlined,
          trailing: OutlinedButton.icon(
            onPressed: () => setState(() => _addRow()),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
          ),
          child: Column(
            children: [
              if (_rows.isEmpty)
                const AdminEmptyState(
                  icon: Icons.insights_rounded,
                  title: 'No numbers yet',
                  message: 'Click "Add" to create the first figure.',
                ),
              for (var i = 0; i < _rows.length; i++)
                _buildRow(i),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save numbers'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(int i) {
    final number = CircleAvatar(
      radius: 14,
      backgroundColor: AdminColors.primary.withValues(alpha: 0.12),
      child: Text(
        '${i + 1}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AdminColors.primaryDark,
        ),
      ),
    );
    final valueField = TextField(
      controller: _rows[i].value,
      decoration: const InputDecoration(
        labelText: 'Value',
        hintText: '50+',
        fillColor: Colors.white,
        isDense: true,
      ),
    );
    final labelField = TextField(
      controller: _rows[i].label,
      decoration: const InputDecoration(
        labelText: 'Label',
        hintText: 'Active Machines',
        fillColor: Colors.white,
        isDense: true,
      ),
    );
    final actions = [
      IconButton(
        tooltip: 'Move up',
        icon: const Icon(Icons.keyboard_arrow_up_rounded),
        onPressed: i == 0 ? null : () => _move(i, i - 1),
      ),
      IconButton(
        tooltip: 'Move down',
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        onPressed: i == _rows.length - 1 ? null : () => _move(i, i + 1),
      ),
      IconButton(
        tooltip: 'Remove',
        icon: const Icon(Icons.delete_outline, color: AdminColors.danger),
        onPressed: () => setState(() => _rows.removeAt(i).dispose()),
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Narrow (phone): fields on one line, buttons underneath.
          if (constraints.maxWidth < 520) {
            return Column(
              children: [
                Row(
                  children: [
                    number,
                    const SizedBox(width: 10),
                    SizedBox(width: 84, child: valueField),
                    const SizedBox(width: 10),
                    Expanded(child: labelField),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            );
          }
          return Row(
            children: [
              number,
              const SizedBox(width: 12),
              SizedBox(width: 110, child: valueField),
              const SizedBox(width: 12),
              Expanded(child: labelField),
              const SizedBox(width: 4),
              ...actions,
            ],
          );
        },
      ),
    );
  }
}


/// Mirrors the dark "BiteBox in Numbers" banner on the public home page.
class _StatsPreview extends StatelessWidget {
  final List<StatItem> stats;
  const _StatsPreview({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AdminColors.sidebar, Color(0xFF14513A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_outlined, color: Colors.white54, size: 16),
              SizedBox(width: 6),
              Text(
                'LIVE PREVIEW',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'BiteBox in Numbers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          if (stats.isEmpty)
            const Text(
              'Nothing to show',
              style: TextStyle(color: Colors.white54),
            )
          else
            Wrap(
              spacing: 32,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                for (final s in stats)
                  SizedBox(
                    width: 150,
                    child: Column(
                      children: [
                        Text(
                          s.value.isEmpty ? '—' : s.value,
                          style: const TextStyle(
                            color: AdminColors.primary,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          s.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatRow {
  final TextEditingController value;
  final TextEditingController label;

  _StatRow(StatItem item)
      : value = TextEditingController(text: item.value),
        label = TextEditingController(text: item.label);

  void dispose() {
    value.dispose();
    label.dispose();
  }
}
