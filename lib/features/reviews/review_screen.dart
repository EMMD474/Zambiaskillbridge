import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/app_state.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.contextId, required this.workerId});
  final String contextId;
  final String workerId;
  @override
  ConsumerState<ReviewScreen> createState() => _ReviewState();
}

class _ReviewState extends ConsumerState<ReviewScreen> {
  final _text = TextEditingController();
  int _stars = 0;
  final _tags = <String>{};
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (_stars == 0) {
      setState(() => _error = 'Choose a star rating first.');
      return;
    }
    final err = ref.read(appProvider.notifier).submitReview(contextId: widget.contextId, workerId: widget.workerId, rating: _stars, text: _text.text, tags: _tags.toList());
    if (err != null) {
      setState(() => _error = err);
    } else {
      setState(() { _done = true; _error = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appProvider);
    final w = s.worker(widget.workerId);
    final eligible = s.reviewableContexts(widget.workerId).any((c) => c.id == widget.contextId);
    return Scaffold(
      appBar: AppBar(title: const Text('Rate and review')),
      body: SafeArea(
        child: _done
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle, size: 72, color: SB.success),
                  const SizedBox(height: 14),
                  const Text('Review saved', style: SB.h2),
                  const SizedBox(height: 6),
                  Text('Your review of ${w?.name ?? 'the worker'} is saved on this device and now counts in their rating.', textAlign: TextAlign.center, style: const TextStyle(color: SB.text2)),
                  const SizedBox(height: 22),
                  PrimaryButton('Done', onPressed: () => context.canPop() ? context.pop() : context.go('/home')),
                ]),
              )
            : (w == null || (!eligible && !s.alreadyReviewed(widget.contextId)))
                ? const EmptyState(icon: Icons.lock_outline, title: 'Review not available', message: 'You can review a worker once a job or booking with them is marked completed.')
                : s.alreadyReviewed(widget.contextId)
                    ? const EmptyState(icon: Icons.check_circle_outline, title: 'Already reviewed', message: 'You have already left a review for this job.')
                    : ListView(padding: EdgeInsets.fromLTRB(SB.pad, 8, SB.pad, 24 + MediaQuery.of(context).viewInsets.bottom), children: [
                        Row(children: [
                          Avatar(name: w.name, photoPath: w.photoPath, size: 52, colorValue: w.colorValue),
                          const SizedBox(width: 12),
                          Expanded(child: Text('How was your job with ${w.name}?', style: SB.h4)),
                        ]),
                        const SizedBox(height: 12),
                        StarInput(value: _stars, onChanged: (v) => setState(() { _stars = v; _error = null; })),
                        Center(child: Text(_stars == 0 ? 'Tap a star' : ['', 'Poor', 'Fair', 'Good', 'Very good', 'Excellent'][_stars], style: const TextStyle(color: SB.text2))),
                        const SizedBox(height: 14),
                        TextField(controller: _text, minLines: 4, maxLines: 6, maxLength: 500, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Write a review (optional)', alignLabelWithHint: true)),
                        FormSection('What stood out?', children: [
                          Wrap(spacing: 8, runSpacing: 4, children: [
                            for (final t in kReviewTags)
                              FilterChip(label: Text(t), selected: _tags.contains(t), showCheckmark: false, labelStyle: TextStyle(fontSize: 13, color: _tags.contains(t) ? Colors.white : SB.text), onSelected: (on) => setState(() => on ? _tags.add(t) : _tags.remove(t))),
                          ]),
                        ]),
                        if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: InfoNote(_error!, icon: Icons.error_outline, color: SB.error)),
                        const SizedBox(height: 16),
                        PrimaryButton('Submit review', onPressed: _submit),
                        const SizedBox(height: 10),
                        const Text('Reviews you write here are demo reviews stored on this device. They are not independently verified testimonials.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: SB.text2)),
                      ]),
      ),
    );
  }
}
