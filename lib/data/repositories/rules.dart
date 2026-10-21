import '../../core/constants/constants.dart';
import '../../data/content/quizzes.dart';
import '../../models/models.dart';

/// Pure business rules, kept free of Flutter so they are easy to unit test.

class RatingSummary {
  final double average;
  final int count;
  final Map<int, int> distribution; // stars -> count (reviews saved on device)
  const RatingSummary(this.average, this.count, this.distribution);
}

/// Combines the demo's historic aggregate with reviews written on this device.
/// Seeded sample reviews (isDemo) are already part of the historic aggregate.
RatingSummary summarizeRatings(WorkerProfile w, List<Review> reviews) {
  final mine = reviews.where((r) => r.workerId == w.id).toList();
  final live = mine.where((r) => !r.isDemo).toList();
  final total = w.baseRating * w.baseReviews + live.fold<int>(0, (a, r) => a + r.rating);
  final count = w.baseReviews + live.length;
  final dist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  for (final r in mine) {
    dist[r.rating] = (dist[r.rating] ?? 0) + 1;
  }
  return RatingSummary(count == 0 ? 0 : total / count, count, dist);
}

QuizAttempt? bestAttempt(List<QuizAttempt> attempts, String quizId, String workerId) {
  QuizAttempt? best;
  for (final a in attempts) {
    if (a.quizId != quizId || a.workerId != workerId) continue;
    if (best == null || a.score > best.score) best = a;
  }
  return best;
}

/// Which badges a worker holds, from real profile, review and quiz data.
Set<String> computeBadges({
  required WorkerProfile worker,
  required List<Review> reviews,
  required List<QuizAttempt> attempts,
}) {
  final out = <String>{...worker.quizBadgeIds};
  if (worker.years >= 5) out.add('experienced_worker');
  if (worker.portfolio.length >= 3) out.add('portfolio_complete');
  final rv = reviews.where((r) => r.workerId == worker.id).toList();
  if (rv.length >= 3) {
    final avg = rv.fold<int>(0, (a, r) => a + r.rating) / rv.length;
    if (avg >= 4.5) out.add('consistent_reviews');
  }
  for (final q in kQuizzes) {
    final best = bestAttempt(attempts, q.id, worker.id);
    if (best != null && best.percent >= kBadgeThreshold) out.add(q.badgeId);
  }
  return out;
}

int scoreQuiz(Quiz quiz, List<int> answers) {
  var s = 0;
  for (var i = 0; i < quiz.questions.length; i++) {
    if (i < answers.length && answers[i] == quiz.questions[i].correctIndex) s++;
  }
  return s;
}

/// Booking transitions each side may make. Keeps the lifecycle consistent.
List<BookingStatus> allowedBookingTransitions(BookingStatus from, UserRole actor) {
  switch (from) {
    case BookingStatus.requested:
      return actor == UserRole.worker
          ? [BookingStatus.accepted, BookingStatus.declined]
          : [BookingStatus.cancelled];
    case BookingStatus.accepted:
      return actor == UserRole.worker
          ? [BookingStatus.inProgress, BookingStatus.cancelled]
          : [BookingStatus.cancelled];
    case BookingStatus.inProgress:
      return [BookingStatus.completed];
    case BookingStatus.declined:
    case BookingStatus.completed:
    case BookingStatus.cancelled:
      return const [];
  }
}

/// My Jobs buckets.
enum WorkBucket { active, pending, completed, cancelled }

WorkBucket bucketForBooking(BookingStatus s) {
  switch (s) {
    case BookingStatus.requested:
      return WorkBucket.pending;
    case BookingStatus.accepted:
    case BookingStatus.inProgress:
      return WorkBucket.active;
    case BookingStatus.completed:
      return WorkBucket.completed;
    case BookingStatus.declined:
    case BookingStatus.cancelled:
      return WorkBucket.cancelled;
  }
}

WorkBucket bucketForJob(JobStatus s) {
  switch (s) {
    case JobStatus.open:
      return WorkBucket.pending;
    case JobStatus.inProgress:
      return WorkBucket.active;
    case JobStatus.completed:
      return WorkBucket.completed;
    case JobStatus.cancelled:
      return WorkBucket.cancelled;
  }
}

WorkBucket bucketForApplication(ApplicationStatus a, JobStatus? job) {
  switch (a) {
    case ApplicationStatus.pending:
      return job == JobStatus.cancelled ? WorkBucket.cancelled : WorkBucket.pending;
    case ApplicationStatus.accepted:
      if (job == JobStatus.completed) return WorkBucket.completed;
      if (job == JobStatus.cancelled) return WorkBucket.cancelled;
      return WorkBucket.active;
    case ApplicationStatus.declined:
    case ApplicationStatus.withdrawn:
      return WorkBucket.cancelled;
  }
}
