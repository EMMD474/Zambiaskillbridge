import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/repositories/rules.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class WorkerProfileScreen extends ConsumerStatefulWidget {
  const WorkerProfileScreen({super.key, required this.workerId});
  final String workerId;
  @override
  ConsumerState<WorkerProfileScreen> createState() => _WorkerProfileState();
}

class _WorkerProfileState extends ConsumerState<WorkerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = ref.read(appProvider);
      if (!(s.isWorker && s.myWorkerId == widget.workerId)) {
        ref.read(appProvider.notifier).markViewedWorker(widget.workerId);
      }
    });
  }

  Future<void> _contact(WorkerProfile w) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.chat_bubble_outline), title: const Text('Message in SkillBridge'), subtitle: const Text('Local demo messaging'), onTap: () => Navigator.pop(c, 'chat')),
          ListTile(leading: const Icon(Icons.call_outlined), title: Text('Call ${w.phone}'), onTap: () => Navigator.pop(c, 'call')),
          ListTile(leading: const Icon(Icons.message_outlined), title: const Text('WhatsApp'), onTap: () => Navigator.pop(c, 'wa')),
          if (w.isDemo) const Padding(padding: EdgeInsets.fromLTRB(20, 4, 20, 12), child: Text('This is a fictional demo worker. The phone number is not real.', style: TextStyle(fontSize: 12, color: SB.text2))),
        ]),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'chat') {
      final id = ref.read(appProvider.notifier).openConversation(w.id);
      context.push('/chat/$id');
      return;
    }
    final digits = w.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = choice == 'call' ? Uri.parse('tel:$digits') : Uri.parse('https://wa.me/${digits.replaceAll('+', '')}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) showToast(context, 'Could not open that app on this device.');
    } catch (_) {
      if (mounted) showToast(context, 'Could not open that app on this device.');
    }
  }

  Future<void> _share(WorkerProfile w) async {
    final text = '${w.name}, ${tradeById(w.tradeId).name} in ${w.town} (SkillBridge demo profile)';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showToast(context, 'Profile summary copied to clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appProvider);
    final w = s.worker(widget.workerId);
    if (w == null) {
      return Scaffold(appBar: AppBar(), body: const ErrorState(message: 'This profile could not be found.'));
    }
    final r = s.ratingFor(w);
    final own = s.isWorker && s.myWorkerId == w.id;
    final fav = s.favourites.contains(w.id);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(children: [
          SizedBox(
            height: 250,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 205,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  child: Stack(fit: StackFit.expand, children: [
                    TradeImage(w.tradeId),
                    const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x66000000), Color(0x00000000), Color(0x33000000)]))),
                  ]),
                ),
              ),
              Positioned(
                top: 0,
                left: 12,
                right: 12,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(children: [
                      RoundIconButton(icon: Icons.arrow_back, tooltip: 'Back', onTap: () => context.canPop() ? context.pop() : context.go('/home')),
                      const Spacer(),
                      RoundIconButton(icon: Icons.share_outlined, tooltip: 'Share profile', onTap: () => _share(w)),
                      if (!own) ...[
                        const SizedBox(width: 8),
                        RoundIconButton(
                          icon: fav ? Icons.favorite : Icons.favorite_border,
                          color: fav ? SB.error : null,
                          tooltip: fav ? 'Remove from favourites' : 'Save to favourites',
                          onTap: () {
                            ref.read(appProvider.notifier).toggleFavourite(w.id);
                            showToast(context, fav ? 'Removed from favourites.' : 'Saved to favourites.');
                          },
                        ),
                      ],
                    ]),
                  ),
                ),
              ),
              Positioned(
                left: SB.pad,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: SB.bg, shape: BoxShape.circle),
                  child: Avatar(name: w.name, photoPath: w.photoPath, size: 76, colorValue: w.colorValue),
                ),
              ),
              Positioned(
                right: SB.pad,
                bottom: 6,
                child: StatusPill(w.isAvailable ? 'Available' : 'Busy', color: w.isAvailable ? SB.success : SB.warning, icon: w.isAvailable ? Icons.check_circle_outline : Icons.schedule),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(SB.pad, 6, SB.pad, 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w.name, style: SB.h2),
                  const SizedBox(height: 2),
                  Text('${tradeById(w.tradeId).name} · ${w.location}', style: const TextStyle(color: SB.text2, fontSize: 14)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [RatingRow(average: r.average, count: r.count), VerificationChip(w)]),
                ]),
              ),
              if (w.startingPrice != null)
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('From', style: TextStyle(fontSize: 11.5, color: SB.text2)),
                  Text(zmw(w.startingPrice!), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SB.terracotta)),
                ]),
            ]),
          ),
          const TabBar(tabs: [Tab(text: 'About'), Tab(text: 'Portfolio'), Tab(text: 'Reviews')]),
          Expanded(
            child: TabBarView(children: [
              _AboutTab(w),
              _PortfolioTab(w),
              _ReviewsTab(w, r),
            ]),
          ),
        ]),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(SB.pad, 8, SB.pad, 10),
            child: own
                ? Row(children: [
                    Expanded(child: SecondaryButton('Manage portfolio', onPressed: () => context.push('/portfolio'))),
                    const SizedBox(width: 10),
                    Expanded(child: PrimaryButton('Edit profile', onPressed: () => context.push('/setup'))),
                  ])
                : Row(children: [
                    Expanded(child: SecondaryButton('Contact worker', icon: Icons.chat_bubble_outline, onPressed: () => _contact(w))),
                    const SizedBox(width: 10),
                    Expanded(child: PrimaryButton('Request service', warm: true, onPressed: () {
                      if (s.isWorker) {
                        showToast(context, 'Switch to the client role in Profile to request a service.');
                      } else {
                        context.push('/request/${w.id}');
                      }
                    })),
                  ]),
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 20, color: SB.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12, color: SB.text2)),
              Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.3)),
            ]),
          ),
        ]),
      );
}

class _AboutTab extends ConsumerWidget {
  const _AboutTab(this.w);
  final WorkerProfile w;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appProvider);
    final badges = s.badgesFor(w);
    return ListView(padding: const EdgeInsets.fromLTRB(SB.pad, 12, SB.pad, 24), children: [
      if (w.bio.trim().isNotEmpty) Text(w.bio, style: const TextStyle(fontSize: 15, height: 1.5)),
      const SectionHeading('Details'),
      SbCard(
        child: Column(children: [
          _Fact(Icons.work_history_outlined, 'Experience', '${w.years} year${w.years == 1 ? '' : 's'} · ${w.skillLevel} (self-rated)'),
          _Fact(Icons.place_outlined, 'Service area', '${w.location}, ${w.province} Province · within ${w.radiusKm} km${w.willingToTravel ? ' · willing to travel further' : ''}'),
          _Fact(w.isAvailable ? Icons.check_circle_outline : Icons.schedule, 'Availability', '${w.isAvailable ? 'Available' : 'Currently busy'} · ${w.days.isEmpty ? 'Days not set' : w.days.join(', ')} · ${w.hoursStart} to ${w.hoursEnd}'),
          _Fact(Icons.payments_outlined, 'Pricing', w.startingPrice == null ? w.pricingType.label : 'From ${zmw(w.startingPrice!)} · ${w.pricingType.label}'),
        ]),
      ),
      if (w.serviceDescription.trim().isNotEmpty) ...[
        const SectionHeading('Services offered'),
        Text(w.serviceDescription, style: const TextStyle(fontSize: 14.5, height: 1.5)),
      ],
      const SectionHeading('Skills and credentials'),
      CredentialsBlock(worker: w, badges: badges),
    ]);
  }
}

/// Keeps the four kinds of evidence visibly separate so nothing is overstated.
class CredentialsBlock extends StatelessWidget {
  const CredentialsBlock({super.key, required this.worker, required this.badges});
  final WorkerProfile worker;
  final Set<String> badges;
  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String title, String tag, Color color, Widget body) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
              StatusPill(tag, color: color),
            ]),
            const SizedBox(height: 8),
            body,
          ]),
        );
    return SbCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        row(
          Icons.person_outline,
          'Skills',
          'Self-declared',
          SB.text2,
          worker.skills.isEmpty ? const Text('None listed.', style: TextStyle(color: SB.text2)) : Wrap(spacing: 8, runSpacing: 6, children: [for (final k in worker.skills) Chip(label: Text(k.name))]),
        ),
        row(
          Icons.quiz_outlined,
          'SkillBridge quiz badges',
          'App achievement',
          SB.accent,
          badges.isEmpty
              ? const Text('No badges earned yet.', style: TextStyle(color: SB.text2))
              : Wrap(spacing: 4, runSpacing: 4, children: [for (final id in badges) SizedBox(width: 84, child: BadgeTile(badge: badgeById(id), earned: true))]),
        ),
        row(
          Icons.task_alt,
          'Work history',
          worker.verifiedHistory ? 'Verified (demo)' : 'Not verified',
          worker.verifiedHistory ? SB.success : SB.text2,
          Text(worker.verifiedHistory ? 'Jobs completed through SkillBridge in this demo dataset.' : 'No verified work history on SkillBridge yet.', style: const TextStyle(color: SB.text2, fontSize: 13.5)),
        ),
        row(
          Icons.verified_outlined,
          'Official qualifications',
          worker.externalCredentials.isEmpty ? 'None on record' : 'On record',
          worker.externalCredentials.isEmpty ? SB.text2 : SB.success,
          worker.externalCredentials.isEmpty
              ? const Text('SkillBridge badges are not government-issued certificates and do not replace formal certification.', style: TextStyle(color: SB.text2, fontSize: 13.5))
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final c in worker.externalCredentials) Text('• $c')]),
        ),
      ]),
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  const _PortfolioTab(this.w);
  final WorkerProfile w;
  @override
  Widget build(BuildContext context) {
    if (w.portfolio.isEmpty) {
      return const EmptyState(icon: Icons.photo_library_outlined, title: 'No portfolio yet', message: 'This worker has not added photos of past work.');
    }
    return ListView(padding: const EdgeInsets.fromLTRB(SB.pad, 12, SB.pad, 24), children: [
      LayoutBuilder(builder: (c, box) {
        final cw = (box.maxWidth - 12) / 2;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final p in w.portfolio)
            SizedBox(
              width: cw,
              child: InkWell(
                borderRadius: BorderRadius.circular(SB.radius),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PortfolioViewer(item: p))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SB.radius),
                    child: AspectRatio(aspectRatio: 1, child: PortfolioImage(path: p.imagePaths.isEmpty ? null : p.imagePaths.first, tradeId: p.tradeId)),
                  ),
                  const SizedBox(height: 6),
                  Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  Text(tradeById(p.tradeId).name, style: const TextStyle(fontSize: 12, color: SB.text2)),
                ]),
              ),
            ),
        ]);
      }),
    ]);
  }
}

class PortfolioViewer extends StatelessWidget {
  const PortfolioViewer({super.key, required this.item});
  final PortfolioItem item;
  @override
  Widget build(BuildContext context) {
    final pages = item.imagePaths.isEmpty ? <String?>[null] : item.imagePaths;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 16))),
      body: Column(children: [
        Expanded(
          child: PageView(children: [
            for (final p in pages)
              InteractiveViewer(child: Center(child: PortfolioImage(path: p, tradeId: item.tradeId, fit: BoxFit.contain))),
          ]),
        ),
        Container(
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${tradeById(item.tradeId).name}${item.completedOn.isEmpty ? '' : ' · Completed ${fmtIsoDay(item.completedOn)}'}', style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
              if (item.description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(item.description, style: const TextStyle(color: Colors.white, height: 1.4))),
              if (item.videoRef != null && item.videoRef!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Video note: ${item.videoRef}', style: const TextStyle(color: Colors.white70, fontSize: 12.5))),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ReviewsTab extends ConsumerWidget {
  const _ReviewsTab(this.w, this.r);
  final WorkerProfile w;
  final RatingSummary r;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appProvider);
    final reviews = s.reviewsFor(w.id);
    final eligible = s.reviewableContexts(w.id);
    final maxCount = r.distribution.values.fold<int>(1, (a, b) => b > a ? b : a);
    final tagCounts = <String, int>{};
    for (final rv in reviews) {
      for (final t in rv.tags) {
        tagCounts[t] = (tagCounts[t] ?? 0) + 1;
      }
    }
    return ListView(padding: const EdgeInsets.fromLTRB(SB.pad, 12, SB.pad, 24), children: [
      SbCard(
        child: Row(children: [
          Column(children: [
            Text(r.count == 0 ? '-' : r.average.toStringAsFixed(1), style: SB.h0),
            Text('${r.count} review${r.count == 1 ? '' : 's'}', style: const TextStyle(color: SB.text2, fontSize: 12.5)),
          ]),
          const SizedBox(width: 20),
          Expanded(
            child: Column(children: [
              for (var i = 5; i >= 1; i--)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Text('$i', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(minHeight: 6, value: (r.distribution[i] ?? 0) / maxCount, backgroundColor: SB.soft, color: const Color(0xFFE0A21B)))),
                    const SizedBox(width: 6),
                    SizedBox(width: 22, child: Text('${r.distribution[i] ?? 0}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: SB.text2))),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
      if (tagCounts.isNotEmpty) ...[
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in tagCounts.entries) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: SB.border)), child: Text('${e.key}  ${e.value}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
        ]),
      ],
      const SizedBox(height: 6),
      const Text('The distribution counts reviews listed below. Older sample ratings are included in the average only.', style: TextStyle(fontSize: 11.5, color: SB.text2)),
      if (eligible.isNotEmpty) ...[
        const SizedBox(height: 12),
        PrimaryButton('Write a review', icon: Icons.rate_review_outlined, onPressed: () => context.push('/review/${eligible.first.id}?workerId=${w.id}')),
      ],
      const SectionHeading('Reviews'),
      if (reviews.isEmpty)
        const SbCard(child: Text('No written reviews yet.', style: TextStyle(color: SB.text2)))
      else
        for (final rv in reviews)
          SbCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Avatar(name: rv.clientName, size: 34),
                const SizedBox(width: 10),
                Expanded(child: Text(rv.clientName, style: const TextStyle(fontWeight: FontWeight.w700))),
                RatingRow(average: rv.rating.toDouble(), count: 1, size: 14),
              ]),
              const SizedBox(height: 6),
              if (rv.contextLabel.isNotEmpty) Text('Job: ${rv.contextLabel}', style: const TextStyle(fontSize: 12.5, color: SB.text2)),
              if (rv.text.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(rv.text, style: const TextStyle(height: 1.4))),
              if (rv.tags.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Wrap(spacing: 6, runSpacing: 4, children: [for (final t in rv.tags) StatusPill(t, color: SB.accent)])),
              const SizedBox(height: 6),
              Text('${fmtDate(rv.createdAt)}${rv.isDemo ? ' · Demo sample review' : ' · Saved on this device'}', style: const TextStyle(fontSize: 11.5, color: SB.text2)),
            ]),
          ),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Service request
// ---------------------------------------------------------------------------

class RequestServiceScreen extends ConsumerStatefulWidget {
  const RequestServiceScreen({super.key, required this.workerId});
  final String workerId;
  @override
  ConsumerState<RequestServiceScreen> createState() => _RequestState();
}

class _RequestState extends ConsumerState<RequestServiceScreen> {
  final _form = GlobalKey<FormState>();
  final _service = TextEditingController();
  final _desc = TextEditingController();
  final _loc = TextEditingController();
  final _budget = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final w = ref.read(appProvider).worker(widget.workerId);
    _loc.text = w?.town ?? '';
  }

  @override
  void dispose() {
    for (final c in [_service, _desc, _loc, _budget, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final ok = _form.currentState!.validate();
    setState(() => _dateError = _date == null ? 'Choose a preferred date.' : null);
    if (!ok || _date == null) return;
    final budget = double.tryParse(_budget.text.replaceAll(',', '').trim());
    final id = ref.read(appProvider.notifier).createBooking(ServiceRequest(
          workerId: widget.workerId,
          service: _service.text.trim(),
          description: _desc.text.trim(),
          preferredDate: _date!,
          preferredTime: _time == null ? 'Flexible' : _time!.format(context),
          location: _loc.text.trim(),
          budget: budget,
          notes: _notes.text.trim(),
        ));
    showToast(context, 'Request saved on this device and shown to the worker in the demo.');
    context.pushReplacement('/booking/$id');
  }

  @override
  Widget build(BuildContext context) {
    final w = ref.watch(appProvider).worker(widget.workerId);
    if (w == null) return Scaffold(appBar: AppBar(), body: const ErrorState(message: 'This worker could not be found.'));
    final trade = tradeById(w.tradeId);
    return Scaffold(
      appBar: AppBar(title: const Text('Request a service')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(padding: EdgeInsets.fromLTRB(SB.pad, 8, SB.pad, 24 + MediaQuery.of(context).viewInsets.bottom), children: [
            Row(children: [
              Avatar(name: w.name, photoPath: w.photoPath, size: 44, colorValue: w.colorValue),
              const SizedBox(width: 12),
              Expanded(child: Text('${w.name} · ${trade.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5))),
            ]),
            const SizedBox(height: 14),
            TextFormField(controller: _service, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Requested service'), validator: (v) => (v == null || v.trim().length < 3) ? 'Say which service you need.' : null),
            const SizedBox(height: 6),
            Wrap(spacing: 8, children: [for (final p in trade.popularServices) ActionChip(label: Text(p), onPressed: () => setState(() => _service.text = p))]),
            const SizedBox(height: 12),
            TextFormField(controller: _desc, minLines: 3, maxLines: 5, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Describe the job', alignLabelWithHint: true), validator: (v) => (v == null || v.trim().length < 10) ? 'Add a few details (at least 10 characters).' : null),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final d = await pickDate(context, initial: _date);
                    if (d != null) setState(() { _date = d; _dateError = null; });
                  },
                  icon: const Icon(Icons.event),
                  label: Text(_date == null ? 'Preferred date' : fmtDate(_date!)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final t = await showTimePicker(context: context, initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0));
                    if (t != null) setState(() => _time = t);
                  },
                  icon: const Icon(Icons.schedule),
                  label: Text(_time == null ? 'Preferred time' : _time!.format(context)),
                ),
              ),
            ]),
            if (_dateError != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(_dateError!, style: const TextStyle(color: SB.error, fontSize: 12.5))),
            const SizedBox(height: 12),
            TextFormField(controller: _loc, decoration: const InputDecoration(labelText: 'Location (town or neighbourhood)'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter where the work is needed.' : null),
            const SizedBox(height: 12),
            TextFormField(
              controller: _budget,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Budget in ZMW (optional)', prefixText: 'K '),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return null;
                final n = double.tryParse(t.replaceAll(',', ''));
                return (n == null || n <= 0) ? 'Enter a valid amount.' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _notes, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Additional notes (optional)', alignLabelWithHint: true)),
            const SizedBox(height: 16),
            const InfoNote('This request is stored on this device for the demo. It is not sent to a real worker.'),
            const SizedBox(height: 16),
            PrimaryButton('Send request', onPressed: _submit),
          ]),
        ),
      ),
    );
  }
}
