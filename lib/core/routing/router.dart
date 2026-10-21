import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assessments/quizzes.dart';
import '../../features/authentication/auth_screen.dart';
import '../../features/badges/badges.dart';
import '../../features/certification/certification.dart';
import '../../features/discovery/discovery.dart';
import '../../features/home/home_screens.dart';
import '../../features/home/shell.dart';
import '../../features/jobs/jobs.dart';
import '../../features/messaging/messaging.dart';
import '../../features/notifications/notifications.dart';
import '../../features/onboarding/onboarding.dart';
import '../../features/portfolio/portfolio.dart';
import '../../features/reviews/review_screen.dart';
import '../../features/settings/settings.dart';
import '../../features/worker_profile/setup_wizard.dart';
import '../../features/worker_profile/worker_profile.dart';
import '../../state/app_state.dart';
import 'routes.dart';

const _open = {'/splash', '/intro', '/role', '/auth'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AppState>(appProvider, (prev, next) {
    // Only identity changes need the redirect to run again.
    if (prev?.user?.id != next.user?.id) refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final s = ref.read(appProvider);
      final loc = state.matchedLocation;
      if (s.user == null && !_open.contains(loc)) {
        return s.onboarded ? '/auth' : '/intro';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('That page does not exist.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => context.go('/home'), child: const Text('Go home')),
          ]),
        ),
      ),
    ),
    routes: [
      GoRoute(path: '/splash', name: R.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/intro', name: R.intro, builder: (_, __) => const IntroScreen()),
      GoRoute(path: '/role', name: R.role, builder: (_, __) => const RoleScreen()),
      GoRoute(path: '/auth', name: R.auth, builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/setup', name: R.wizard, builder: (_, __) => const ProfileSetupScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', name: R.home, builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/discover', name: R.discover, builder: (_, __) => const DiscoverScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/action', name: R.action, builder: (_, __) => const ActionScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/messages', name: R.messages, builder: (_, __) => const ConversationsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', name: R.profile, builder: (_, __) => const ProfileScreen())]),
        ],
      ),
      GoRoute(
        path: '/search',
        name: R.results,
        builder: (_, st) => SearchScreen(
          key: ValueKey(st.uri.toString()),
          trade: st.uri.queryParameters['trade'],
          text: st.uri.queryParameters['q'],
          town: st.uri.queryParameters['town'],
        ),
      ),
      GoRoute(path: '/worker/:id', name: R.worker, builder: (_, st) => WorkerProfileScreen(workerId: st.pathParameters['id']!)),
      GoRoute(path: '/portfolio', name: R.portfolio, builder: (_, __) => const PortfolioManagerScreen()),
      GoRoute(path: '/job/:id', name: R.job, builder: (_, st) => JobDetailScreen(jobId: st.pathParameters['id']!)),
      GoRoute(path: '/applicants/:jobId', name: 'applicants', builder: (_, st) => ApplicantsScreen(jobId: st.pathParameters['jobId']!)),
      GoRoute(path: '/my-jobs', name: R.myJobs, builder: (_, __) => const MyJobsScreen()),
      GoRoute(path: '/request/:workerId', name: R.request, builder: (_, st) => RequestServiceScreen(workerId: st.pathParameters['workerId']!)),
      GoRoute(path: '/booking/:id', name: R.booking, builder: (_, st) => BookingDetailScreen(bookingId: st.pathParameters['id']!)),
      GoRoute(path: '/chat/:id', name: R.chat, builder: (_, st) => ChatScreen(conversationId: st.pathParameters['id']!)),
      GoRoute(
        path: '/review/:contextId',
        name: R.review,
        builder: (_, st) => ReviewScreen(contextId: st.pathParameters['contextId']!, workerId: st.uri.queryParameters['workerId'] ?? ''),
      ),
      GoRoute(path: '/quizzes', name: R.quizzes, builder: (_, __) => const QuizListScreen()),
      GoRoute(path: '/quiz/:id', name: R.quiz, builder: (_, st) => QuizScreen(quizId: st.pathParameters['id']!)),
      GoRoute(path: '/badges', name: R.badges, builder: (_, __) => const BadgesScreen()),
      GoRoute(path: '/certification', name: R.certification, builder: (_, __) => const CertificationScreen()),
      GoRoute(path: '/notifications', name: R.notifications, builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/favourites', name: R.favourites, builder: (_, __) => const FavouritesScreen()),
      GoRoute(path: '/edit-profile', name: R.account, builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/availability', name: R.availability, builder: (_, __) => const AvailabilityScreen()),
    ],
  );
});
