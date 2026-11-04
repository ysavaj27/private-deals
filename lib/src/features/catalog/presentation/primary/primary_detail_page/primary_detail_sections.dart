import 'package:flutter/foundation.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:private_deals/src/shared/app_exports.dart';

String primaryMoney(double value) =>
    value > 0 && value.isFinite ? value.toCurrency : '—';

Future<void> _openLink(String value) async {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return;
  final uri = Uri.tryParse(
    trimmed.contains('://') ? trimmed : 'https://$trimmed',
  );
  if (uri == null || !['http', 'https'].contains(uri.scheme)) return;
  try {
    // Preserve path casing, including signed document URLs.
    await Launcher.openNewTab(uri.toString());
  } catch (_) {
    toast('Unable to open this link. Please try again.', MessageEnum.alert);
  }
}

class PrimaryCompanyHeader extends StatelessWidget {
  const PrimaryCompanyHeader({super.key, required this.model});
  final StartupModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PrimaryDetailSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(
                url: model.cms.logo,
                business: true,
                size: MediaQuery.sizeOf(context).width < 600 ? 52 : 64,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.brandName.isEmpty
                          ? model.companyName
                          : model.brandName,
                      style:
                          (MediaQuery.sizeOf(context).width < 600
                                  ? theme.textTheme.headlineSmall
                                  : theme.textTheme.headlineMedium)
                              ?.copyWith(letterSpacing: -0.6),
                    ),
                    if (model.companyName.isNotEmpty &&
                        model.companyName != model.brandName) ...[
                      const SizedBox(height: 4),
                      Text(
                        model.companyName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (model.cms.oneLiner.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        model.cms.oneLiner,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        const PrimaryDetailBadge(
                          label: 'Primary',
                          accent: true,
                        ),
                        if (model.raisingRound.instrument.isNotEmpty)
                          PrimaryDetailBadge(
                            label: model.raisingRound.instrument.instrumentName,
                          ),
                        if (model.sector.name.isNotEmpty)
                          PrimaryDetailBadge(label: model.sector.name),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1),
          ),
          _Facts(
            facts: [
              ('Location', model.city.name.isEmpty ? '—' : model.city.name),
              (
                'Incorporated',
                model.legalInfo.incorporationDate.year > 0
                    ? model.legalInfo.incorporationDate.dateWithSortMonthYear
                    : '—',
              ),
              (
                'Total round size',
                primaryMoney(model.raisingRound.totalFundRequirement),
              ),
              (
                'Minimum investment',
                primaryMoney(model.raisingRound.minimumInvestment),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PrimaryDetailSections extends StatelessWidget {
  const PrimaryDetailSections({
    super.key,
    required this.model,
    required this.sectionKeys,
  });
  final StartupModel model;
  final List<GlobalKey> sectionKeys;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _Section(
        key: sectionKeys[0],
        number: '01',
        title: 'Company overview',
        subtitle: 'The business, its vision, and company information.',
        child: _Overview(model: model),
      ),
      const SizedBox(height: 24),
      _Section(
        key: sectionKeys[1],
        number: '02',
        title: 'Key information',
        subtitle: 'A closer look at the startup and its opportunity.',
        child: _RichContent(
          data: model.cms.keyInformation,
          empty: 'Key information has not been published yet.',
        ),
      ),
      const SizedBox(height: 24),
      _Section(
        key: sectionKeys[2],
        number: '03',
        title: 'Team',
        subtitle: 'Meet the people building the business.',
        child: _Team(model: model),
      ),
      const SizedBox(height: 24),
      _Section(
        key: sectionKeys[3],
        number: '04',
        title: 'Updates',
        subtitle: 'The latest milestones and announcements.',
        child: _Updates(model: model),
      ),
      const SizedBox(height: 24),
      _Section(
        key: sectionKeys[4],
        number: '05',
        title: 'Investors',
        subtitle: 'Investors backing the startup.',
        child: _Investors(model: model),
      ),
      const SizedBox(height: 24),
      _Section(
        key: sectionKeys[5],
        number: '06',
        title: 'Frequently asked questions',
        subtitle: 'Answers to common questions about this startup.',
        child: _FAQs(model: model),
      ),
      const SizedBox(height: 24),
      _Section(
        key: sectionKeys[6],
        number: '07',
        title: 'Documents',
        subtitle:
            'Explore the company’s pitch, reports, and supporting documents.',
        child: _Documents(model: model),
      ),
    ],
  );
}

class _Overview extends StatelessWidget {
  const _Overview({required this.model});
  final StartupModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHighlights =
        model.briefInformation.isNotEmpty || model.cms.highlights.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasHighlights) ...[
          Text('Startup highlights', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (model.briefInformation.isNotEmpty)
            Text(
              model.briefInformation,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          if (model.cms.highlights.isNotEmpty)
            _RichContent(data: model.cms.highlights),
          const SizedBox(height: 24),
        ],
        if (model.cms.pitchVideo.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.control),
            child: CustomVideoPlayer(url: model.cms.pitchVideo),
          ),
          const SizedBox(height: 20),
        ],
        if (model.cms.idea.isNotEmpty)
          _RichContent(data: model.cms.idea)
        else if (!hasHighlights && model.cms.pitchVideo.isEmpty)
          const _EmptyState('The company overview has not been published yet.'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(height: 1),
        ),
        _Facts(
          facts: [
            ('Legal name', model.companyName.isEmpty ? '—' : model.companyName),
            ('CIN', model.legalInfo.cin.isEmpty ? '—' : model.legalInfo.cin),
          ],
        ),
        if (model.cms.website.isNotEmpty ||
            model.socialMediaLinks.any((s) => s.link.isNotEmpty)) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (model.cms.website.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _openLink(model.cms.website),
                  icon: const Icon(Icons.language_rounded, size: 18),
                  label: const Text('Company website'),
                ),
              for (final social in model.socialMediaLinks.where(
                (s) => s.link.isNotEmpty,
              ))
                TextButton.icon(
                  onPressed: () => _openLink(social.link),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(
                    social.socialMediaType.name.isEmpty
                        ? 'Social profile'
                        : social.socialMediaType.name,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Team extends StatelessWidget {
  const _Team({required this.model});
  final StartupModel model;

  @override
  Widget build(BuildContext context) {
    if (model.teamMembers.isEmpty) {
      return const _EmptyState('Team profiles are not available yet.');
    }
    final theme = Theme.of(context);
    return _CardGrid(
      children: [
        for (final member in model.teamMembers)
          _InsetCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(url: member.profilePhoto, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.name, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(
                            member.designation,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (member.briefInformation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    member.briefInformation,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                  ),
                ],
                if (member.linkedinUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () => _openLink(member.linkedinUrl),
                      icon: const Icon(Icons.open_in_new_rounded, size: 14),
                      iconAlignment: IconAlignment.end,
                      label: const Text('LinkedIn profile'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Updates extends StatelessWidget {
  const _Updates({required this.model});
  final StartupModel model;
  @override
  Widget build(BuildContext context) {
    if (model.updates.isEmpty) {
      return const _EmptyState('There are no company updates yet.');
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < model.updates.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1),
            ),
          Text(model.updates[i].title, style: theme.textTheme.titleMedium),
          if (model.updates[i].createdAt.year > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                model.updates[i].createdAt.dateWithSortMonthYear,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (model.updates[i].image.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.control),
                child: Image.network(
                  model.updates[i].image,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (_, error, stack) => const SizedBox.shrink(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            model.updates[i].description,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ],
    );
  }
}

class _Investors extends StatelessWidget {
  const _Investors({required this.model});
  final StartupModel model;
  @override
  Widget build(BuildContext context) {
    if (model.portfolio.isEmpty) {
      return const _EmptyState('Investor information is not available yet.');
    }
    final theme = Theme.of(context);
    return _CardGrid(
      children: [
        for (final investor in model.portfolio)
          _InsetCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(url: investor.profile, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investor.showName,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Amount invested',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        primaryMoney(investor.totalInvested),
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FAQs extends StatelessWidget {
  const _FAQs({required this.model});
  final StartupModel model;
  @override
  Widget build(BuildContext context) {
    if (model.faqs.isEmpty) {
      return const _EmptyState(
        'Frequently asked questions are not available yet.',
      );
    }
    return Column(
      children: [
        for (var i = 0; i < model.faqs.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          ExpansionTile(
            key: PageStorageKey('primary-faq-${model.id}-$i'),
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(
              model.faqs[i].question,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            children: [_RichContent(data: model.faqs[i].answer)],
          ),
        ],
      ],
    );
  }
}

class _Documents extends StatelessWidget {
  const _Documents({required this.model});
  final StartupModel model;

  Future<void> _openDocument(String path, String title) async {
    final cleanPath =
        Uri.tryParse(path)?.path.toLowerCase() ?? path.toLowerCase();
    if (cleanPath.endsWith('.pdf')) {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        Get.to(() => PdfViewerPage(path: path, title: title));
      } else {
        showCustomDialog(PdfViewerDialog(path: path, title: title));
      }
    } else if (cleanPath.isVideoFileName) {
      showCustomDialog(CustomVideoPlayer(url: path));
    } else {
      await _openLink(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final docs = [
      (
        'Pitch deck',
        'The business, products, and growth plans.',
        model.cms.pitchDeck,
      ),
      (
        'Financial projections',
        'Projected financial performance.',
        model.cms.financialProjection,
      ),
      (
        'Due diligence report',
        'Company information and review findings.',
        model.cms.ddReport,
      ),
      (
        'DPIIT startup certificate',
        'Official startup recognition.',
        model.cms.dpiitReport,
      ),
      (
        'Shuru-Up research report',
        'Research and analysis of the startup.',
        model.cms.shuruupResearchReport,
      ),
      (
        'Valuation report',
        'The company’s valuation assessment.',
        model.cms.valuationReport,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 2 : 1;
        final textWidth =
            (constraints.maxWidth - (columns - 1) * 16) / columns - 32;
        final titleStyle = theme.textTheme.titleSmall!;
        final descriptionStyle = theme.textTheme.bodySmall!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );
        double heightFor(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            locale: Localizations.maybeLocaleOf(context),
          )..layout(maxWidth: textWidth);
          final height = painter.height.ceilToDouble();
          painter.dispose();
          return height;
        }

        final titleHeight = docs
            .map((doc) => heightFor(doc.$1, titleStyle))
            .reduce((a, b) => a > b ? a : b);
        final descriptionHeight = docs
            .map((doc) => heightFor(doc.$2, descriptionStyle))
            .reduce((a, b) => a > b ? a : b);
        return _CardGrid(
          children: [
            for (final doc in docs)
              KeyedSubtree(
                key: ValueKey('primary-document-card-${doc.$1}'),
                child: _InsetCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 24,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: titleHeight,
                        child: Text(doc.$1, style: titleStyle),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: descriptionHeight,
                        child: Text(doc.$2, style: descriptionStyle),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        key: ValueKey('primary-document-${doc.$1}'),
                        onPressed: doc.$3.trim().isEmpty
                            ? null
                            : () => _openDocument(doc.$3.trim(), doc.$1),
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        iconAlignment: IconAlignment.end,
                        label: Text(
                          doc.$3.trim().isEmpty
                              ? 'Not available'
                              : 'View document',
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PrimaryDetailSurface extends StatelessWidget {
  const PrimaryDetailSurface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(AppRadii.card),
    ),
    child: child,
  );
}

class PrimaryDetailBadge extends StatelessWidget {
  const PrimaryDetailBadge({
    super.key,
    required this.label,
    this.accent = false,
  });
  final String label;
  final bool accent;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent
            ? colors.secondaryContainer
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.badge),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accent ? colors.onSecondaryContainer : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String number, title, subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizeChangedLayoutNotifier(
      child: RepaintBoundary(
        child: PrimaryDetailSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadii.badge),
                    ),
                    child: Text(
                      number,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.facts});
  final List<(String, String)> facts;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final columns = facts.length.clamp(1, box.maxWidth < 560 ? 2 : 4);
      return Wrap(
        spacing: 16,
        runSpacing: 20,
        children: [
          for (final fact in facts)
            SizedBox(
              width: (box.maxWidth - (columns - 1) * 16) / columns,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fact.$1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(fact.$2, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final columns = box.maxWidth >= 650 ? 2 : 1;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final child in children)
            SizedBox(
              width: (box.maxWidth - (columns - 1) * 16) / columns,
              child: child,
            ),
        ],
      );
    },
  );
}

class _InsetCard extends StatelessWidget {
  const _InsetCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(AppRadii.control),
    ),
    child: child,
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size, this.business = false});
  final String url;
  final double size;
  final bool business;
  @override
  Widget build(BuildContext context) => url.isNotEmpty
      ? LogoImage(
          url: url,
          width: size,
          height: size,
          radius: AppRadii.control,
          fit: BoxFit.contain,
        )
      : Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          child: Icon(
            business ? Icons.business_rounded : Icons.person_outline_rounded,
            size: size / 2,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        );
}

class _RichContent extends StatelessWidget {
  const _RichContent({
    required this.data,
    this.empty = 'Information is not available yet.',
  });
  final String data, empty;
  @override
  Widget build(BuildContext context) => data.trim().isEmpty
      ? _EmptyState(empty)
      : Html(
          data: data,
          onLinkTap: (url, attributes, element) {
            if (url != null) _openLink(url);
          },
          style: {
            'body': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: FontSize(14),
              lineHeight: const LineHeight(1.6),
            ),
          },
        );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}
