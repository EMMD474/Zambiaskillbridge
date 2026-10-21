import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashState();
}

class _SplashState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      final s = ref.read(appProvider);
      context.go(s.user != null ? '/home' : (s.onboarded ? '/auth' : '/intro'));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return Scaffold(
      body: ArchBackdrop(
        radius: 0,
        padding: EdgeInsets.zero,
        child: SizedBox.expand(
          child: Center(
            child: FadeTransition(
              opacity: a,
              child: ScaleTransition(
                scale: Tween<double>(begin: .92, end: 1).animate(a),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SbLogo(size: 88, wordmark: false, light: true),
                  const SizedBox(height: 20),
                  Text('Zambia SkillBridge', style: SB.h1.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text(kTagline, style: TextStyle(fontSize: 15, color: Color(0xCCFFFFFF), letterSpacing: .6)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroPage {
  final String title;
  final String body;
  final List<IconData> icons;
  final List<Color> colors;
  const _IntroPage(this.title, this.body, this.icons, this.colors);
}

const _pages = [
  _IntroPage('Show it', 'Workers build a profile with their services, experience and photos of real jobs, so skills are seen and not just talked about.', [Icons.person_outline, Icons.photo_library_outlined, Icons.handyman_outlined], [SB.navy, SB.navyLight]),
  _IntroPage('Prove it', 'Clients leave ratings and reviews after finished jobs. Short quizzes earn skill badges. Self-declared skills are always kept apart from verified ones.', [Icons.star_outline_rounded, Icons.quiz_outlined, Icons.workspace_premium_outlined], [Color(0xFF8A3F28), SB.terracotta]),
  _IntroPage('Grow it', 'Find workers by trade and town, discover jobs, and learn about formal vocational training. Badges do not replace formal certification.', [Icons.search, Icons.work_outline, Icons.school_outlined], [Color(0xFF3E6049), SB.sage]),
];

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroState();
}

class _IntroState extends State<IntroScreen> {
  final _ctl = PageController();
  int _i = 0;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _i == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => context.go('/role'), child: const Text('Skip')),
          ),
          Expanded(
            child: PageView.builder(
              controller: _ctl,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (_, i) {
                final p = _pages[i];
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(children: [
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 240,
                      child: ArchBackdrop(
                        colors: p.colors,
                        radius: 30,
                        child: Center(
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                            for (var k = 0; k < p.icons.length; k++)
                              Transform.translate(
                                offset: Offset(0, k == 1 ? -14 : 8),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white30)),
                                  child: Icon(p.icons[k], size: 32, color: Colors.white),
                                ),
                              ),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('${i + 1} of ${_pages.length}', style: const TextStyle(color: SB.text2, fontSize: 12.5)),
                    const SizedBox(height: 6),
                    Text(p.title, style: SB.h1Navy),
                    const SizedBox(height: 12),
                    Text(p.body, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15.5, height: 1.5, color: SB.text2)),
                  ]),
                );
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < _pages.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                width: i == _i ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(color: i == _i ? SB.navy : SB.border, borderRadius: BorderRadius.circular(8)),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(24),
            child: PrimaryButton(
              last ? 'Get started' : 'Next',
              onPressed: () {
                if (last) {
                  context.go('/role');
                } else {
                  _ctl.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
                }
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({super.key});
  @override
  ConsumerState<RoleScreen> createState() => _RoleState();
}

class _RoleState extends ConsumerState<RoleScreen> {
  UserRole? _role;

  @override
  void initState() {
    super.initState();
    _role = ref.read(appProvider).chosenRole;
  }

  Widget _card(UserRole r, IconData icon, String title, List<String> points) {
    final sel = _role == r;
    return Semantics(
      button: true,
      selected: sel,
      label: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _role = r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sel ? SB.navy : SB.border, width: sel ? 2 : 1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: sel ? SB.navy : SB.soft, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: sel ? Colors.white : SB.navy),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: SB.h4)),
              Icon(sel ? Icons.radio_button_checked : Icons.radio_button_off, color: sel ? SB.navy : SB.text2),
            ]),
            const SizedBox(height: 12),
            for (final p in points)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check, size: 16, color: SB.success),
                  const SizedBox(width: 8),
                  Expanded(child: Text(p, style: const TextStyle(fontSize: 13.5, color: SB.text2))),
                ]),
              ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('How will you use SkillBridge?')),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView(padding: const EdgeInsets.all(20), children: [
                _card(UserRole.worker, Icons.engineering_outlined, 'I am a skilled worker', const ['Build a professional profile.', 'Showcase previous work.', 'Find clients and job opportunities.', 'Earn skill badges.']),
                const SizedBox(height: 14),
                _card(UserRole.client, Icons.person_search_outlined, 'I need a skilled worker', const ['Search for local professionals.', 'Compare ratings and portfolios.', 'Post a job.', 'Contact suitable workers.']),
                const SizedBox(height: 14),
                const InfoNote('You can switch between both roles later from Profile while using the demo.'),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton('Continue', onPressed: _role == null ? null : () {
                ref.read(appProvider.notifier).chooseRole(_role!);
                context.go('/auth');
              }),
            ),
          ]),
        ),
      );
}
