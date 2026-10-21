import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

/// Opens the gallery and copies the chosen photos into app storage.
/// Returns the stored paths. Cancelling returns an empty list; failures show a plain message.
Future<List<String>> pickPhotos(BuildContext context, WidgetRef ref, {bool multi = true}) async {
  final media = ref.read(mediaProvider);
  try {
    final picker = ImagePicker();
    List<XFile> files;
    if (multi) {
      files = await picker.pickMultiImage(maxWidth: 1600, imageQuality: 85);
    } else {
      final f = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
      files = f == null ? <XFile>[] : <XFile>[f];
    }
    final out = <String>[];
    for (final f in files) {
      out.add(await media.persist(f));
    }
    return out;
  } catch (_) {
    if (context.mounted) {
      showToast(context, 'We could not open your photos. Check that SkillBridge may access photos in your phone settings, then try again.');
    }
    return [];
  }
}

/// Full-screen form to add or edit one project. Pops with the saved [PortfolioItem].
class PortfolioEditScreen extends ConsumerStatefulWidget {
  const PortfolioEditScreen({super.key, this.existing, required this.defaultTradeId});
  final PortfolioItem? existing;
  final String defaultTradeId;
  @override
  ConsumerState<PortfolioEditScreen> createState() => _PortfolioEditState();
}

class _PortfolioEditState extends ConsumerState<PortfolioEditScreen> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _desc = TextEditingController(text: widget.existing?.description ?? '');
  late final _video = TextEditingController(text: widget.existing?.videoRef ?? '');
  late String _trade = widget.existing?.tradeId ?? widget.defaultTradeId;
  late String _date = widget.existing?.completedOn ?? '';
  late List<String> _images = [...(widget.existing?.imagePaths ?? const <String>[])];

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _video.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final id = widget.existing?.id ?? 'p_${DateTime.now().microsecondsSinceEpoch}';
    Navigator.of(context).pop(PortfolioItem(
      id: id,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      tradeId: _trade,
      completedOn: _date,
      imagePaths: _images,
      videoRef: _video.text.trim().isEmpty ? null : _video.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.existing == null ? 'Add project' : 'Edit project')),
        body: SafeArea(
          child: Form(
            key: _form,
            child: ListView(padding: EdgeInsets.fromLTRB(SB.pad, 8, SB.pad, 24 + MediaQuery.of(context).viewInsets.bottom), children: [
              TextFormField(controller: _title, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Project title'), validator: (v) => (v == null || v.trim().length < 3) ? 'Give the project a short title.' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _desc, minLines: 3, maxLines: 5, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'What did you do?', alignLabelWithHint: true)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _trade,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Trade or skill'),
                items: [for (final t in kTrades) DropdownMenuItem(value: t.id, child: Text(t.name))],
                onChanged: (v) => setState(() => _trade = v ?? _trade),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final d = await pickDate(context, initial: _date.isEmpty ? null : DateTime.tryParse(_date), future: false);
                  if (d != null) setState(() => _date = isoDay(d));
                },
                icon: const Icon(Icons.event),
                label: Text(_date.isEmpty ? 'Completion date' : 'Completed ${fmtIsoDay(_date)}'),
              ),
              const SectionHeading('Photos'),
              Wrap(spacing: 10, runSpacing: 10, children: [
                for (final p in _images)
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: Stack(fit: StackFit.expand, children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: PortfolioImage(path: p, tradeId: _trade)),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(customBorder: const CircleBorder(), onTap: () => setState(() => _images.remove(p)), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, size: 16, color: Colors.white))),
                        ),
                      ),
                    ]),
                  ),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final added = await pickPhotos(context, ref);
                    if (added.isNotEmpty) setState(() => _images = [..._images, ...added]);
                  },
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: SB.border), color: SB.soft),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_outlined, color: SB.navy), SizedBox(height: 4), Text('Add photos', style: TextStyle(fontSize: 12))]),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextFormField(controller: _video, decoration: const InputDecoration(labelText: 'Video link or note (optional)', helperText: 'Recording video is not part of this prototype. You can add a link or a note.')),
              const SizedBox(height: 20),
              PrimaryButton('Save project', onPressed: _save),
            ]),
          ),
        ),
      );
}

/// Opens the editor and returns the saved item, or null if cancelled.
Future<PortfolioItem?> editPortfolioItem(BuildContext context, {PortfolioItem? existing, required String defaultTradeId}) =>
    Navigator.of(context).push<PortfolioItem>(MaterialPageRoute(builder: (_) => PortfolioEditScreen(existing: existing, defaultTradeId: defaultTradeId)));

class PortfolioManagerScreen extends ConsumerWidget {
  const PortfolioManagerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appProvider);
    final w = s.myWorker;
    final ctl = ref.read(appProvider.notifier);
    if (w == null) {
      return Scaffold(appBar: AppBar(title: const Text('My portfolio')), body: EmptyState(icon: Icons.person_add_alt, title: 'Set up your profile first', message: 'Your portfolio is part of your worker profile.', actionLabel: 'Start setup', onAction: () => context.push('/setup')));
    }
    final items = w.portfolio;
    return Scaffold(
      appBar: AppBar(title: const Text('My portfolio'), actions: [TextButton(onPressed: () => context.push('/worker/${w.id}'), child: const Text('Preview'))]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final item = await editPortfolioItem(context, defaultTradeId: w.tradeId);
          if (item != null) {
            ctl.savePortfolio([...items, item]);
            if (context.mounted) showToast(context, 'Project saved on this device.');
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add project'),
      ),
      body: items.isEmpty
          ? const EmptyState(icon: Icons.photo_library_outlined, title: 'No projects yet', message: 'Add photos of finished jobs so clients can see your work.')
          : ListView(padding: const EdgeInsets.fromLTRB(SB.pad, 8, SB.pad, 96), children: [
              const InfoNote('Changes are saved on this device as you make them.', icon: Icons.save_outlined),
              const SizedBox(height: 12),
              for (final p in items)
                SbCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  child: Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 72, height: 72, child: PortfolioImage(path: p.imagePaths.isEmpty ? null : p.imagePaths.first, tradeId: p.tradeId))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${tradeById(p.tradeId).name} · ${p.imagePaths.length} photo${p.imagePaths.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 12.5, color: SB.text2)),
                        if (p.completedOn.isNotEmpty) Text('Completed ${fmtIsoDay(p.completedOn)}', style: const TextStyle(fontSize: 12, color: SB.text2)),
                      ]),
                    ),
                    IconButton(
                      tooltip: 'Edit ${p.title}',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final edited = await editPortfolioItem(context, existing: p, defaultTradeId: w.tradeId);
                        if (edited != null) {
                          ctl.savePortfolio([for (final x in items) x.id == p.id ? edited : x]);
                          if (context.mounted) showToast(context, 'Project updated.');
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'Remove ${p.title}',
                      icon: const Icon(Icons.delete_outline, color: SB.error),
                      onPressed: () async {
                        final ok = await confirmDialog(context, title: 'Remove project?', message: '"${p.title}" will be removed from your public portfolio.', confirmLabel: 'Remove', destructive: true);
                        if (ok) ctl.savePortfolio([for (final x in items) if (x.id != p.id) x]);
                      },
                    ),
                  ]),
                ),
            ]),
    );
  }
}
