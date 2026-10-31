import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';
import '../../core/constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final faqs = [(l.faq1q, l.faq1a), (l.faq2q, l.faq2a), (l.faq3q, l.faq3a)];
    return Scaffold(
      appBar: AppBar(title: Text(l.helpFaq)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(l.faqTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final f in faqs)
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(f.$1, style: Theme.of(context).textTheme.titleMedium),
              children: [Align(alignment: Alignment.centerLeft, child: Text(f.$2, style: Theme.of(context).textTheme.bodyLarge))],
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.mail_rounded),
          label: Text(l.contactSupport),
          onPressed: () => launchUrl(Uri(scheme: 'mailto', path: AppConstants.supportEmail)),
        ),
      ]),
    );
  }
}
