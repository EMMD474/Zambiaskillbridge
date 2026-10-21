import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../worker_profile/worker_profile.dart' show CredentialsBlock;

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appProvider);
    final w = s.myWorker;
    if (!s.isWorker || w == null) {
      return Scaffold(appBar: AppBar(title: const Text('Skills and badges')), body: EmptyState(icon: Icons.workspace_premium_outlined, title: 'Badges belong to worker profiles', message: s.isWorker ? 'Set up your profile to start earning badges.' : 'Switch to the worker role in Profile to see badges.', actionLabel: s.isWorker ? 'Start setup' : null, onAction: () => context.push('/setup')));
    }
    final earned = s.badgesFor(w);
    return Scaffold(
      appBar: AppBar(title: const Text('Skills and badges')),
      body: ListView(padding: const EdgeInsets.fromLTRB(SB.pad, 4, SB.pad, 24), children: [
        Text('${earned.length} of ${kBadges.length} badges earned', style: SB.h4),
        const SizedBox(height: 4),
        const Text('Badges come from your quiz scores, your profile and your saved client reviews.', style: TextStyle(color: SB.text2)),
        const SizedBox(height: 12),
        for (final k in BadgeKind.values) ...[
          SectionHeading(switch (k) { BadgeKind.quiz => 'Quiz badges', BadgeKind.profile => 'Profile badges', BadgeKind.reviews => 'Review badges' }),
          for (final b in kBadges.where((b) => b.kind == k))
            SbCard(
              margin: const EdgeInsets.only(bottom: 10),
              onTap: b.kind == BadgeKind.quiz ? () => context.push('/quizzes') : null,
              child: Row(children: [
                SizedBox(width: 64, child: BadgeTile(badge: b, earned: earned.contains(b.id))),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700))), StatusPill(earned.contains(b.id) ? 'Earned' : 'Not yet', color: earned.contains(b.id) ? SB.success : SB.text2, icon: earned.contains(b.id) ? Icons.check : Icons.lock_outline)]),
                    const SizedBox(height: 4),
                    Text(b.howToEarn, style: const TextStyle(fontSize: 13, color: SB.text2, height: 1.35)),
                  ]),
                ),
              ]),
            ),
        ],
        const SectionHeading('What your profile shows'),
        CredentialsBlock(worker: w, badges: earned),
        const SizedBox(height: 12),
        const InfoNote('SkillBridge badges are app achievements. They are not government-issued qualifications.'),
      ]),
    );
  }
}
