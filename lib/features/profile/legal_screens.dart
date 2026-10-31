import 'package:flutter/material.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';

enum LegalKind { privacy, terms }

class LegalScreen extends StatelessWidget {
  final LegalKind kind;
  const LegalScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isPrivacy = kind == LegalKind.privacy;
    return Scaffold(
      appBar: AppBar(title: Text(isPrivacy ? l.privacyPolicy : l.termsOfUse)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(isPrivacy ? l.privacyBody : l.termsBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
      ),
    );
  }
}
