import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../portfolio/portfolio.dart';

const _stepTitles = ['Personal details', 'Trade and skills', 'Location', 'Portfolio', 'Availability and pricing', 'Preview'];

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  ConsumerState<ProfileSetupScreen> createState() => _SetupState();
}

class _SetupState extends ConsumerState<ProfileSetupScreen> {
  final _keys = List.generate(5, (_) => GlobalKey<FormState>());
  late WorkerProfile _p;
  int _step = 0;

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _bio = TextEditingController();
  final _service = TextEditingController();
  final _years = TextEditingController();
  final _hood = TextEditingController();
  final _price = TextEditingController();
  final _customSkill = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(appProvider);
    final ctl = ref.read(appProvider.notifier);
    final existing = s.myWorker;
    final draft = existing == null ? ctl.loadDraft(s.myWorkerId) : null;
    _p = existing ??
        draft ??
        WorkerProfile(id: s.myWorkerId, name: s.user?.name ?? '', phone: s.user?.phone ?? '', email: s.user?.email ?? '', photoPath: s.user?.photoPath);
    _name.text = _p.name;
    _phone.text = _p.phone.startsWith('+260') ? _p.phone.substring(4).trim() : _p.phone;
    _email.text = _p.email;
    _bio.text = _p.bio;
    _service.text = _p.serviceDescription;
    _years.text = _p.years == 0 ? '' : '${_p.years}';
    _hood.text = _p.neighbourhood;
    _price.text = _p.startingPrice == null ? '' : _p.startingPrice!.round().toString();
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _bio, _service, _years, _hood, _price, _customSkill]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Copies what is typed into the working profile.
  void _collect() {
    final digits = normaliseZmPhone(_phone.text);
    _p = _p.copyWith(
      name: _name.text.trim(),
      phone: digits == null ? _p.phone : '+260$digits',
      email: _email.text.trim(),
      bio: _bio.text.trim(),
      serviceDescription: _service.text.trim(),
      years: int.tryParse(_years.text.trim()) ?? 0,
      neighbourhood: _hood.text.trim(),
      startingPrice: double.tryParse(_price.text.replaceAll(',', '').trim()),
      clearPrice: _price.text.trim().isEmpty,
    );
  }

  void _next() {
    if (_step < 5 && _step != 3 && !(_keys[_step].currentState?.validate() ?? true)) return;
    setState(_collect);
    ref.read(appProvider.notifier).saveDraft(_p);
    if (_step < 5) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    setState(_collect);
    if (_step == 0) {
      context.canPop() ? context.pop() : context.go('/home');
    } else {
      setState(() => _step--);
    }
  }

  void _saveDraft() {
    setState(_collect);
    ref.read(appProvider.notifier).saveDraft(_p);
    showToast(context, 'Draft saved on this device.');
  }

  void _finish() {
    if (_p.name.isEmpty || _p.skills.isEmpty) {
      showToast(context, 'Add your name and at least one skill before finishing.');
      setState(() => _step = _p.name.isEmpty ? 0 : 1);
      return;
    }
    final ctl = ref.read(appProvider.notifier);
    ctl.saveWorkerProfile(_p);
    ctl.clearDraft();
    showToast(context, 'Profile saved on this device.');
    context.go('/home');
  }

  Future<void> _pickPhoto() async {
    final paths = await pickPhotos(context, ref, multi: false);
    if (paths.isNotEmpty) setState(() => _p = _p.copyWith(photoPath: paths.first));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Back', icon: const Icon(Icons.arrow_back), onPressed: _back),
        title: Text(_stepTitles[_step]),
        actions: [TextButton(onPressed: _saveDraft, child: const Text('Save draft'))],
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(SB.pad, 0, SB.pad, 8),
            child: Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: (_step + 1) / 6, minHeight: 6, backgroundColor: SB.soft, color: SB.navy))),
              const SizedBox(width: 12),
              Text('Step ${_step + 1} of 6', style: const TextStyle(fontSize: 12.5, color: SB.text2)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(SB.pad, 4, SB.pad, 16 + MediaQuery.of(context).viewInsets.bottom),
              child: [_personal, _trade, _location, _portfolio, _availability, _preview][_step](),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(SB.pad, 4, SB.pad, 12),
            child: Row(children: [
              if (_step > 0) ...[Expanded(child: SecondaryButton('Back', onPressed: _back)), const SizedBox(width: 10)],
              Expanded(flex: 2, child: PrimaryButton(_step == 5 ? 'Finish setup' : 'Continue', onPressed: _next)),
            ]),
          ),
        ]),
      ),
    );
  }

  // ---- steps -----------------------------------------------------------------

  Widget _personal() => Form(
        key: _keys[0],
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          Center(
            child: Stack(children: [
              Avatar(name: _name.text, photoPath: _p.photoPath, size: 96),
              Positioned(right: 0, bottom: 0, child: Material(color: SB.navy, shape: const CircleBorder(), child: IconButton(tooltip: 'Choose profile photo', iconSize: 18, color: Colors.white, icon: const Icon(Icons.camera_alt_outlined), onPressed: _pickPhoto))),
            ]),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name.' : null),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]'))],
            decoration: const InputDecoration(labelText: 'Phone number', prefixText: '+260  '),
            validator: (v) => normaliseZmPhone(v ?? '') == null ? 'Enter a valid Zambian mobile number.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email (optional)'),
            validator: (v) {
              final t = (v ?? '').trim();
              return t.isEmpty || RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t) ? null : 'Enter a valid email address.';
            },
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _bio, minLines: 3, maxLines: 5, maxLength: 300, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Short biography', alignLabelWithHint: true)),
        ]),
      );

  Widget _trade() {
    final trade = tradeById(_p.tradeId);
    return Form(
      key: _keys[1],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _p.tradeId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Primary trade'),
          items: [for (final t in kTrades) DropdownMenuItem(value: t.id, child: Text(t.name))],
          onChanged: (v) => setState(() => _p = _p.copyWith(tradeId: v)),
        ),
        FormSection('Your skills', hint: 'Tap the ones you do. These are self-declared and shown that way to clients.', children: [
          Wrap(spacing: 8, runSpacing: 4, children: [
            for (final name in {...trade.popularServices, ..._p.skills.map((k) => k.name)})
              FilterChip(
                label: Text(name),
                selected: _p.skills.any((k) => k.name == name),
                showCheckmark: false,
                labelStyle: TextStyle(color: _p.skills.any((k) => k.name == name) ? Colors.white : SB.text, fontSize: 13),
                onSelected: (on) => setState(() => _p = _p.copyWith(skills: on ? [..._p.skills, Skill(name, _p.skillLevel)] : _p.skills.where((k) => k.name != name).toList())),
              ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _customSkill, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Add another skill'))),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Add skill',
              onPressed: () {
                final t = _customSkill.text.trim();
                if (t.isEmpty || _p.skills.any((k) => k.name.toLowerCase() == t.toLowerCase())) return;
                setState(() {
                  _p = _p.copyWith(skills: [..._p.skills, Skill(t, _p.skillLevel)]);
                  _customSkill.clear();
                });
              },
              icon: const Icon(Icons.add),
            ),
          ]),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: _years,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
          decoration: const InputDecoration(labelText: 'Years of experience'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter 0 if you are just starting.' : null,
        ),
        FormSection('Skill level (your own rating)', children: [
          ChipGroup<String>(options: kSkillLevels, selected: _p.skillLevel, label: (x) => x, onSelected: (v) => setState(() => _p = _p.copyWith(skillLevel: v ?? _p.skillLevel))),
        ]),
        const SizedBox(height: 8),
        TextFormField(controller: _service, minLines: 3, maxLines: 5, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Describe the services you offer', alignLabelWithHint: true), validator: (v) => (v == null || v.trim().length < 10) ? 'Add a short description (at least 10 characters).' : null),
      ]),
    );
  }

  Widget _location() {
    final towns = kProvinceTowns[_p.province] ?? kAllTowns;
    return Form(
      key: _keys[2],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        const InfoNote('You do not need to share your live GPS location. Clients only see your town and neighbourhood.'),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: kProvinceTowns.containsKey(_p.province) ? _p.province : 'Lusaka',
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Province'),
          items: [for (final p in kProvinceTowns.keys) DropdownMenuItem(value: p, child: Text(p))],
          onChanged: (v) => setState(() {
            final prov = v ?? _p.province;
            final list = kProvinceTowns[prov] ?? const <String>[];
            _p = _p.copyWith(province: prov, town: list.contains(_p.town) || list.isEmpty ? _p.town : list.first);
          }),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('town-${_p.province}'),
          initialValue: towns.contains(_p.town) ? _p.town : towns.first,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'District or town'),
          items: [for (final t in towns) DropdownMenuItem(value: t, child: Text(t))],
          onChanged: (v) => setState(() => _p = _p.copyWith(town: v)),
        ),
        const SizedBox(height: 12),
        TextFormField(controller: _hood, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Neighbourhood (optional)', hintText: 'For example Kabulonga')),
        FormSection('Service radius: ${_p.radiusKm} km', children: [
          Slider(value: _p.radiusKm.toDouble().clamp(5.0, 100.0).toDouble(), min: 5, max: 100, divisions: 19, label: '${_p.radiusKm} km', onChanged: (v) => setState(() => _p = _p.copyWith(radiusKm: v.round()))),
        ]),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Willing to travel further for the right job'), value: _p.willingToTravel, onChanged: (v) => setState(() => _p = _p.copyWith(willingToTravel: v))),
      ]),
    );
  }

  Widget _portfolio() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        const Text('Add photos of finished work. Real photos from your phone build trust faster than any description.', style: TextStyle(color: SB.text2, height: 1.4)),
        const SizedBox(height: 12),
        if (_p.portfolio.isEmpty) const SbCard(child: Text('No projects yet. You can add them later too.', style: TextStyle(color: SB.text2))),
        for (final item in _p.portfolio)
          SbCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 60, height: 60, child: PortfolioImage(path: item.imagePaths.isEmpty ? null : item.imagePaths.first, tradeId: item.tradeId))),
              const SizedBox(width: 12),
              Expanded(child: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
              IconButton(
                tooltip: 'Edit project',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final e = await editPortfolioItem(context, existing: item, defaultTradeId: _p.tradeId);
                  if (e != null) setState(() => _p = _p.copyWith(portfolio: [for (final x in _p.portfolio) x.id == item.id ? e : x]));
                },
              ),
              IconButton(
                tooltip: 'Remove project',
                icon: const Icon(Icons.delete_outline, color: SB.error),
                onPressed: () async {
                  final ok = await confirmDialog(context, title: 'Remove project?', message: '"${item.title}" will be removed from this draft.', confirmLabel: 'Remove', destructive: true);
                  if (ok) setState(() => _p = _p.copyWith(portfolio: _p.portfolio.where((x) => x.id != item.id).toList()));
                },
              ),
            ]),
          ),
        const SizedBox(height: 4),
        SecondaryButton('Add a project', icon: Icons.add_photo_alternate_outlined, onPressed: () async {
          final item = await editPortfolioItem(context, defaultTradeId: _p.tradeId);
          if (item != null) setState(() => _p = _p.copyWith(portfolio: [..._p.portfolio, item]));
        }),
      ]);

  Future<void> _pickTime(bool start) async {
    final cur = (start ? _p.hoursStart : _p.hoursEnd).split(':');
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: int.tryParse(cur.first) ?? 8, minute: int.tryParse(cur.last) ?? 0));
    if (t == null) return;
    final s = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    setState(() => _p = start ? _p.copyWith(hoursStart: s) : _p.copyWith(hoursEnd: s));
  }

  Widget _availability() => Form(
        key: _keys[4],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FormSection('Days you work', children: [
            Wrap(spacing: 8, runSpacing: 4, children: [
              for (final d in kWeekdays)
                FilterChip(
                  label: Text(d),
                  selected: _p.days.contains(d),
                  showCheckmark: false,
                  labelStyle: TextStyle(color: _p.days.contains(d) ? Colors.white : SB.text),
                  onSelected: (on) => setState(() => _p = _p.copyWith(days: on ? ([..._p.days, d]..sort((a, b) => kWeekdays.indexOf(a).compareTo(kWeekdays.indexOf(b)))) : _p.days.where((x) => x != d).toList())),
                ),
            ]),
          ]),
          FormSection('Working hours', children: [
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => _pickTime(true), child: Text('From ${_p.hoursStart}'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(onPressed: () => _pickTime(false), child: Text('To ${_p.hoursEnd}'))),
            ]),
          ]),
          FormSection('Pricing', children: [
            ChipGroup<PricingType>(options: PricingType.values, selected: _p.pricingType, label: (x) => x.label, onSelected: (v) => setState(() => _p = _p.copyWith(pricingType: v ?? _p.pricingType))),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Starting price in ZMW (optional)', prefixText: 'K '),
            ),
          ]),
        ]),
      );

  Widget _preview() {
    final trade = tradeById(_p.tradeId);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 8),
      const Text('This is how clients will see your profile.', style: TextStyle(color: SB.text2)),
      const SizedBox(height: 12),
      SbCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Avatar(name: _p.name, photoPath: _p.photoPath, size: 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_p.name.isEmpty ? 'Your name' : _p.name, style: SB.h3),
                Text('${trade.name} · ${_p.location}', style: const TextStyle(color: SB.text2)),
                const SizedBox(height: 4),
                const StatusPill('Self-declared skills', color: SB.text2, icon: Icons.person_outline),
              ]),
            ),
          ]),
          if (_p.bio.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_p.bio, style: const TextStyle(height: 1.4))),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, children: [for (final k in _p.skills) Chip(label: Text(k.name))]),
          const Divider(height: 24),
          Text('${_p.years} year${_p.years == 1 ? '' : 's'} experience · ${_p.skillLevel}', style: const TextStyle(fontSize: 13.5)),
          const SizedBox(height: 4),
          Text('${_p.days.isEmpty ? 'Days not set' : _p.days.join(', ')} · ${_p.hoursStart} to ${_p.hoursEnd}', style: const TextStyle(fontSize: 13.5)),
          const SizedBox(height: 4),
          Text(_p.startingPrice == null ? _p.pricingType.label : 'From ${zmw(_p.startingPrice!)} · ${_p.pricingType.label}', style: const TextStyle(fontSize: 13.5)),
          const SizedBox(height: 4),
          Text('${_p.portfolio.length} portfolio project${_p.portfolio.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 13.5)),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [const Expanded(child: Text('Profile completion', style: TextStyle(fontWeight: FontWeight.w700))), Text('${(_p.completion * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800))]),
      const SizedBox(height: 8),
      ProfileCompletionBar(_p.completion),
      const SizedBox(height: 12),
      const InfoNote('No certificate or verification is shown on a new profile. Badges come from quizzes, and verification only comes from real records.'),
    ]);
  }
}
