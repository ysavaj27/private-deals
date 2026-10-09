import 'package:private_deals/src/shared/app_exports.dart';

import '../widgets/workspace_widgets.dart';
import 'channel_partner_page_ctrl.dart';
import 'add_channel_partner/add_channel_partner_dialog.dart';

String _partnerAmount(int value) => value == 0 ? '₹0' : value.toFormattedPrice;

class ChannelPartnerView extends StatefulWidget {
  const ChannelPartnerView({super.key});

  @override
  State<ChannelPartnerView> createState() => _ChannelPartnerViewState();
}

class _ChannelPartnerViewState extends State<ChannelPartnerView> {
  final c = Get.find<ChannelPartnerPageCtrl>();
  final _search = TextEditingController();
  String? _type;
  String _sort = 'name';
  bool _opening = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addPartner() async {
    if (_opening) return;
    _opening = true;
    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AddChannelPartnerDialog(),
      );
      if (result == true && mounted) await c.getData();
    } finally {
      _opening = false;
    }
  }

  void _clearFilters() => setState(() {
    _search.clear();
    _type = null;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Obx(() {
      final partners = c.list.toList();
      final types =
          partners
              .map((p) => p.type)
              .where((t) => t.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      final selectedType = types.contains(_type) ? _type : null;
      final query = _search.text.trim().toLowerCase();
      final rows =
          partners
              .where(
                (p) =>
                    (selectedType == null || p.type == selectedType) &&
                    [
                      p.name,
                      p.email,
                      '${p.mobileNumber}',
                      p.type,
                    ].any((v) => v.toLowerCase().contains(query)),
              )
              .toList()
            ..sort((a, b) {
              final comparison = switch (_sort) {
                'investment' => b.totalInvested.compareTo(a.totalInvested),
                'commission' => b.commissionEarned.compareTo(
                  a.commissionEarned,
                ),
                _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              };
              return comparison != 0 ? comparison : a.id.compareTo(b.id);
            });
      final unavailable = c.isLoading() || c.error().isNotEmpty;
      final colors = Theme.of(context).colorScheme;
      final text = Theme.of(context).textTheme;
      return WorkspacePage(
        title: 'Channel partners',
        subtitle: 'Manage your partner network and track its contribution.',
        onRefresh: c.getData,
        loading: c.isLoading(),
        error: c.error(),
        header: [
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _addPartner,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
              label: const Text('Add partner'),
            ),
          ),
          const SizedBox(height: 24),
          WorkspaceMetrics(
            children: [
              WorkspaceMetric(
                label: 'Total partners',
                value: unavailable ? '—' : '${partners.length}',
                icon: Icons.hub_outlined,
              ),
              WorkspaceMetric(
                label: 'Amount invested',
                value: unavailable
                    ? '—'
                    : _partnerAmount(
                        partners.fold<int>(
                          0,
                          (sum, p) => sum + p.totalInvested,
                        ),
                      ),
                icon: Icons.account_balance_outlined,
              ),
              WorkspaceMetric(
                label: 'Commission earned',
                value: unavailable
                    ? '—'
                    : _partnerAmount(
                        partners.fold<int>(
                          0,
                          (sum, p) => sum + p.commissionEarned,
                        ),
                      ),
                icon: Icons.payments_outlined,
                selected: true,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Partner directory', style: text.titleMedium),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final search = TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search name, email or mobile',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () => setState(_search.clear),
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              );
              final sort = DropdownButtonFormField<String>(
                initialValue: _sort,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Sort by'),
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name: A–Z')),
                  DropdownMenuItem(
                    value: 'investment',
                    child: Text('Highest investment'),
                  ),
                  DropdownMenuItem(
                    value: 'commission',
                    child: Text('Highest commission'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _sort = value);
                },
              );
              if (constraints.maxWidth < 700) {
                return Column(
                  children: [search, const SizedBox(height: 16), sort],
                );
              }
              return Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 16),
                  SizedBox(width: 250, child: sort),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All partners'),
                selected: selectedType == null,
                onSelected: (_) => setState(() => _type = null),
              ),
              for (final type in types)
                ChoiceChip(
                  label: Text(type),
                  selected: selectedType == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            unavailable
                ? 'Partner directory'
                : 'Showing ${rows.length} of ${partners.length} partners',
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
        itemCount: rows.length,
        empty: Column(
          children: [
            WorkspaceEmpty(
              icon: partners.isEmpty
                  ? Icons.group_add_outlined
                  : Icons.search_off_rounded,
              title: partners.isEmpty
                  ? 'Build your partner network'
                  : 'No matching partners',
              message: partners.isEmpty
                  ? 'Add your first channel partner to start growing your network.'
                  : 'Try a different name, email, mobile number or partner type.',
            ),
            if (partners.isNotEmpty) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
        itemBuilder: (context, index) => _PartnerCard(partner: rows[index]),
      );
    }),
  );
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.partner});
  final PartnerUser partner;

  @override
  Widget build(BuildContext context) {
    final p = partner;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = p.name.trim().isEmpty ? 'Unnamed partner' : p.name.trim();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: p.profilePhoto.trim().isEmpty
                      ? ColoredBox(
                          color: colors.primaryContainer,
                          child: Center(
                            child: Text(
                              name.characters.first.toUpperCase(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        )
                      : CacheImage(
                          url: p.profile,
                          placeHolderImage: p.placeholderImage,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Tag(
                          text: p.type.isEmpty ? 'Channel partner' : p.type,
                          color: colors.primary,
                        ),
                        if (p.isBlocked)
                          _Tag(text: 'Blocked', color: colors.error),
                        if (p.isDeleted)
                          _Tag(text: 'Deleted', color: colors.error),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 640;
              final email = _Contact(
                icon: Icons.mail_outline_rounded,
                value: p.email.isEmpty
                    ? 'Email not provided'
                    : p.email.toLowerCase(),
              );
              final phone = _Contact(
                icon: Icons.phone_outlined,
                value: p.mobileNumber == 0
                    ? 'Mobile not provided'
                    : '${p.mobileCountryCode > 0 ? '+${p.mobileCountryCode} ' : ''}${p.mobileNumber}',
              );
              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [email, const SizedBox(height: 10), phone],
                    )
                  : Row(
                      children: [
                        Expanded(child: email),
                        const SizedBox(width: 20),
                        Expanded(child: phone),
                      ],
                    );
            },
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 260
                  ? 1
                  : constraints.maxWidth < 720
                  ? 2
                  : 4;
              final width =
                  (constraints.maxWidth - 16 * (columns - 1)) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 18,
                children: [
                  for (final metric in [
                    ('Investors', '${p.investorCount}'),
                    ('Amount invested', _partnerAmount(p.totalInvested)),
                    ('Startups', '${p.noOfStartups}'),
                    ('Commission earned', _partnerAmount(p.commissionEarned)),
                  ])
                    SizedBox(
                      width: width,
                      child: WorkspaceDetail(
                        label: metric.$1,
                        value: metric.$2,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Product access',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              for (final access in [
                if (p.isPrimaryAccess) 'Private Equity',
                if (p.isSecondaryAccess) 'LP Secondary',
                if (p.isPreIpoAccess) 'Unlisted Shares',
              ])
                _Tag(text: access, color: colors.onSurfaceVariant),
              if (!p.isPrimaryAccess &&
                  !p.isSecondaryAccess &&
                  !p.isPreIpoAccess)
                Text('No products enabled', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
    ),
  );
}

class _Contact extends StatelessWidget {
  const _Contact({required this.icon, required this.value});
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size: 17,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: SelectableText(
          value,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ],
  );
}
