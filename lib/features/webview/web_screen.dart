import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/widgets/shimmer.dart';

class WebArgs {
  final String title, url, stateName;
  const WebArgs({required this.title, required this.url, required this.stateName});
}

/// Opens a government service inside the app. URLs come from config (states.json / remote).
void openService(BuildContext context, WidgetRef ref, String key, String title) {
  final cfg = ref.read(appConfigProvider);
  final st = cfg.stateById(ref.read(settingsProvider).stateId);
  final url = st?.services[key];
  if (st == null || url == null) return;
  context.push('/web', extra: WebArgs(title: title, url: url, stateName: st.name.of(ref.read(langProvider))));
}

class WebScreen extends StatefulWidget {
  final WebArgs args;
  const WebScreen({super.key, required this.args});
  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  late final WebViewController _c;
  bool _loading = true;
  bool _offline = false;
  String? _error;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() { _loading = true; _error = null; });
        },
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        onWebResourceError: (e) {
          if (e.isForMainFrame == false || !mounted) return;
          setState(() { _loading = false; _error = e.description; });
          if (e.description.toUpperCase().contains('BLOCKED')) _openSecureTab(showNote: true);
        },
        // Keep users inside the app; only web pages are allowed.
        onNavigationRequest: (r) {
          final u = Uri.tryParse(r.url);
          final ok = u != null && (u.scheme == 'https' || u.scheme == 'http' || u.scheme == 'about');
          return ok ? NavigationDecision.navigate : NavigationDecision.prevent;
        },
      ));
    _start();
  }

  Future<void> _start() async {
    final r = await Connectivity().checkConnectivity();
    final off = r.isEmpty || r.every((e) => e == ConnectivityResult.none);
    if (!mounted) return;
    setState(() { _offline = off; _error = null; _loading = !off; });
    if (!off) await _c.loadRequest(Uri.parse(widget.args.url));
  }

  /// Fallback for portals that refuse to load in a WebView: Chrome Custom Tab.
  Future<void> _openSecureTab({bool showNote = false}) async {
    if (showNote && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).openInChrome)));
    }
    await launchUrl(Uri.parse(widget.args.url), mode: LaunchMode.inAppBrowserView);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final showError = _offline || _error != null;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _c.canGoBack()) {
          await _c.goBack();
        } else if (context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back), onPressed: () async {
            if (await _c.canGoBack()) {
              await _c.goBack();
            } else if (context.mounted) {
              context.pop();
            }
          }),
          title: Text(widget.args.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _start),
            IconButton(icon: const Icon(Icons.open_in_browser_rounded), onPressed: () => _openSecureTab()),
          ],
        ),
        body: Column(children: [
          if (_loading) LinearProgressIndicator(value: _progress == 0 ? null : _progress / 100, minHeight: 4),
          Expanded(
            child: Stack(children: [
              if (!_offline) WebViewWidget(controller: _c),
              if (_loading && _progress < 25 && !showError)
                Positioned.fill(child: ColoredBox(color: cs.surface, child: const ShimmerList())),
              if (showError)
                Positioned.fill(
                  child: ColoredBox(
                    color: cs.surface,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(_offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                              size: 64, color: cs.secondary),
                          const SizedBox(height: 16),
                          Text(_offline ? l.noInternet : l.loadError,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                              onPressed: _start,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(l.retry)),
                          if (!_offline) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                                onPressed: () => _openSecureTab(showNote: true),
                                icon: const Icon(Icons.open_in_browser_rounded),
                                label: Text(l.openPortal)),
                          ],
                        ]),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
          Container(
            width: double.infinity,
            color: cs.primaryContainer,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: SafeArea(
              top: false,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.dataSource(widget.args.stateName),
                    style: TextStyle(fontSize: 13, color: cs.onPrimaryContainer, height: 1.3)),
                const SizedBox(height: 2),
                Text(l.captchaNote,
                    style: TextStyle(
                        fontSize: 13, color: cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
