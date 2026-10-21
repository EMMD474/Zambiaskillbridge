import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/content/quizzes.dart';
import '../../data/repositories/rules.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appProvider);
    if (!s.isWorker) {
      return Scaffold(appBar: AppBar(title: const Text('Competency quizzes')), body: const EmptyState(icon: Icons.quiz_outlined, title: 'Quizzes are for workers', message: 'Switch to the worker role in Profile to take a quiz and earn badges.'));
    }
    final earned = s.myWorker == null ? <String>{} : s.badgesFor(s.myWorker!);
    return Scaffold(
      appBar: AppBar(title: const Text('Competency quizzes')),
      body: ListView(padding: const EdgeInsets.fromLTRB(SB.pad, 4, SB.pad, 24), children: [
        const InfoNote('These are original practice quizzes made for this prototype. They are not TEVETA exams and do not give you a certificate.'),
        const SizedBox(height: 12),
        for (final q in kQuizzes)
          Builder(builder: (context) {
            final best = bestAttempt(s.attempts, q.id, s.myWorkerId);
            final has = earned.contains(q.badgeId);
            return SbCard(
              margin: const EdgeInsets.only(bottom: 10),
              onTap: () => context.push('/quiz/${q.id}'),
              child: Row(children: [
                CircleAvatar(backgroundColor: has ? SB.navy : SB.soft, child: Icon(tradeById(q.tradeId).icon, color: has ? Colors.white : SB.navy)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(q.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                    Text('${q.questions.length} questions', style: const TextStyle(fontSize: 12.5, color: SB.text2)),
                    if (best != null) Text('Best score: ${best.score}/${best.total}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ]),
                ),
                if (has) const StatusPill('Badge earned', color: SB.success, icon: Icons.check) else const Icon(Icons.chevron_right),
              ]),
            );
          }),
      ]),
    );
  }
}

enum _Phase { intro, question, result }

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.quizId});
  final String quizId;
  @override
  ConsumerState<QuizScreen> createState() => _QuizState();
}

class _QuizState extends ConsumerState<QuizScreen> {
  late final Quiz _quiz = quizById(widget.quizId);
  late List<int?> _answers = List.filled(_quiz.questions.length, null);
  _Phase _phase = _Phase.intro;
  int _i = 0;
  QuizAttempt? _result;

  void _restart() => setState(() {
        _answers = List.filled(_quiz.questions.length, null);
        _i = 0;
        _result = null;
        _phase = _Phase.intro;
      });

  void _submit() {
    final attempt = ref.read(appProvider.notifier).submitQuiz(_quiz, [for (final a in _answers) a ?? -1]);
    setState(() {
      _result = attempt;
      _phase = _Phase.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appProvider);
    if (!s.isWorker) {
      return Scaffold(appBar: AppBar(title: Text(_quiz.title)), body: const EmptyState(icon: Icons.quiz_outlined, title: 'Quizzes are for workers', message: 'Switch to the worker role in Profile to take this quiz.'));
    }
    return Scaffold(appBar: AppBar(title: Text(_quiz.title)), body: SafeArea(child: switch (_phase) {
      _Phase.intro => _intro(),
      _Phase.question => _question(),
      _Phase.result => _results(s),
    }));
  }

  Widget _intro() => ListView(padding: const EdgeInsets.all(SB.pad), children: [
        const SizedBox(height: 8),
        Center(child: CircleAvatar(radius: 38, backgroundColor: SB.soft, child: Icon(tradeById(_quiz.tradeId).icon, size: 36, color: SB.navy))),
        const SizedBox(height: 16),
        Text(_quiz.title, textAlign: TextAlign.center, style: SB.h2),
        const SizedBox(height: 8),
        Text(_quiz.intro, textAlign: TextAlign.center, style: const TextStyle(color: SB.text2, height: 1.45)),
        const SizedBox(height: 18),
        SbCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Instructions', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('• ${_quiz.questions.length} multiple-choice questions, one correct answer each.'),
            const Text('• You can move back and change an answer before you submit.'),
            Text('• Score ${(kBadgeThreshold * 100).round()}% or more to earn the ${badgeById(_quiz.badgeId).name} badge.'),
            const Text('• You can retry as often as you like. Your best score counts.'),
          ]),
        ),
        const SizedBox(height: 12),
        const InfoNote('This is a SkillBridge practice quiz. It is not an official TEVETA exam.'),
        const SizedBox(height: 20),
        PrimaryButton('Start quiz', onPressed: () => setState(() => _phase = _Phase.question)),
      ]);

  Widget _question() {
    final q = _quiz.questions[_i];
    final last = _i == _quiz.questions.length - 1;
    final sel = _answers[_i];
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(SB.pad, 4, SB.pad, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Question ${_i + 1} of ${_quiz.questions.length}', style: const TextStyle(color: SB.text2, fontSize: 12.5)),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: (_i + 1) / _quiz.questions.length, minHeight: 6, backgroundColor: SB.soft, color: SB.navy)),
        ]),
      ),
      Expanded(
        child: ListView(padding: const EdgeInsets.all(SB.pad), children: [
          Text(q.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.35)),
          const SizedBox(height: 16),
          for (var k = 0; k < q.options.length; k++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _answers[_i] = k),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: sel == k ? SB.navy : SB.border, width: sel == k ? 2 : 1)),
                  child: Row(children: [
                    Icon(sel == k ? Icons.radio_button_checked : Icons.radio_button_off, color: sel == k ? SB.navy : SB.text2),
                    const SizedBox(width: 12),
                    Expanded(child: Text(q.options[k], style: const TextStyle(fontSize: 15, height: 1.3))),
                  ]),
                ),
              ),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(SB.pad, 4, SB.pad, 12),
        child: Row(children: [
          if (_i > 0) ...[Expanded(child: SecondaryButton('Previous', onPressed: () => setState(() => _i--))), const SizedBox(width: 10)],
          Expanded(
            flex: 2,
            child: PrimaryButton(last ? 'Submit quiz' : 'Next', onPressed: sel == null ? null : (last ? _confirmSubmit : () => setState(() => _i++))),
          ),
        ]),
      ),
    ]);
  }

  Future<void> _confirmSubmit() async {
    final unanswered = _answers.where((a) => a == null).length;
    if (unanswered > 0) {
      showToast(context, 'You skipped $unanswered question${unanswered == 1 ? '' : 's'}. Go back and answer them first.');
      return;
    }
    _submit();
  }

  Widget _results(AppState s) {
    final r = _result!;
    final pass = r.percent >= kBadgeThreshold;
    return ListView(padding: const EdgeInsets.all(SB.pad), children: [
      const SizedBox(height: 8),
      Center(child: Text('${r.score} / ${r.total}', style: SB.h0Navy)),
      Center(child: Text('${(r.percent * 100).round()}%', style: const TextStyle(fontSize: 16, color: SB.text2))),
      const SizedBox(height: 12),
      InfoNote(
        pass ? 'You earned the ${badgeById(_quiz.badgeId).name} badge. It shows on your profile as a SkillBridge quiz achievement, not an official certificate.' : 'You need ${(kBadgeThreshold * 100).round()}% for the ${badgeById(_quiz.badgeId).name} badge. Review the answers below and try again.',
        icon: pass ? Icons.workspace_premium_outlined : Icons.refresh,
        color: pass ? SB.success : SB.warning,
      ),
      const SectionHeading('Review your answers'),
      for (var i = 0; i < _quiz.questions.length; i++)
        Builder(builder: (context) {
          final q = _quiz.questions[i];
          final mine = r.answers.length > i ? r.answers[i] : -1;
          final ok = mine == q.correctIndex;
          return SbCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? SB.success : SB.error, size: 22),
                const SizedBox(width: 8),
                Expanded(child: Text('${i + 1}. ${q.text}', style: const TextStyle(fontWeight: FontWeight.w700, height: 1.3))),
              ]),
              const SizedBox(height: 8),
              Text('Your answer: ${mine >= 0 && mine < q.options.length ? q.options[mine] : 'No answer'}', style: TextStyle(color: ok ? SB.success : SB.error, fontSize: 13.5)),
              if (!ok) Text('Correct answer: ${q.options[q.correctIndex]}', style: const TextStyle(color: SB.success, fontSize: 13.5)),
              const SizedBox(height: 6),
              Text(q.explanation, style: const TextStyle(color: SB.text2, fontSize: 13, height: 1.4)),
            ]),
          );
        }),
      const SizedBox(height: 8),
      PrimaryButton('Try again', onPressed: _restart),
      const SizedBox(height: 10),
      SecondaryButton('Other quizzes', onPressed: () => context.pop()),
    ]);
  }
}
