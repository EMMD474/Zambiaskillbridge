import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/content/certification_content.dart';

class CertificationScreen extends StatelessWidget {
  const CertificationScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    try {
      final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        await Clipboard.setData(ClipboardData(text: url));
        if (context.mounted) showToast(context, 'Could not open the browser. The link was copied instead.');
      }
    } catch (_) {
      if (context.mounted) showToast(context, 'Could not open the link on this device.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Certification pathways')),
        body: ListView(padding: const EdgeInsets.fromLTRB(SB.pad, 4, SB.pad, 24), children: [
          const InfoNote('This page is general information for a prototype. Eligibility, costs, availability and application requirements must be confirmed with the training institution or the relevant authority.', icon: Icons.warning_amber_rounded, color: SB.warning),
          const SizedBox(height: 10),
          const InfoNote('SkillBridge badges and quizzes do not replace formal certification.'),
          const SectionHeading('Why formal certification can help'),
          for (final t in kWhyCertify)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, size: 18, color: SB.success), const SizedBox(width: 8), Expanded(child: Text(t, style: const TextStyle(height: 1.4)))])),
          const SectionHeading('Guidance by trade'),
          for (final e in kTradeGuidance.entries)
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                leading: Icon(tradeById(e.key).icon, color: SB.navy),
                title: Text(tradeById(e.key).name, style: const TextStyle(fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.only(left: 40, bottom: 10),
                expandedAlignment: Alignment.centerLeft,
                children: [Text(e.value, style: const TextStyle(color: SB.text2, height: 1.45))],
              ),
            ),
          const SectionHeading('Questions to ask a training provider'),
          SbCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final q in kProviderQuestions)
                Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.help_outline, size: 18, color: SB.accent), const SizedBox(width: 8), Expanded(child: Text(q, style: const TextStyle(height: 1.4)))])),
            ]),
          ),
          const SectionHeading('Official external resources'),
          for (final r in kCertificationResources)
            SbCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700))), StatusPill(r.url == null ? 'Link not set' : 'Official site', color: r.url == null ? SB.text2 : SB.success)]),
                const SizedBox(height: 6),
                Text(r.description, style: const TextStyle(color: SB.text2, fontSize: 13.5, height: 1.4)),
                if (r.url != null) ...[const SizedBox(height: 10), SecondaryButton('Open website', icon: Icons.open_in_new, onPressed: () => _open(context, r.url!))],
              ]),
            ),
          const SizedBox(height: 6),
          const Text('Links marked "Link not set" are placeholders that can be configured once an official address has been verified.', style: TextStyle(fontSize: 12, color: SB.text2)),
        ]),
      );
}
