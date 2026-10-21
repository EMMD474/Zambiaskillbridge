import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/constants.dart';
import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';

class SkillBridgeApp extends ConsumerWidget {
  const SkillBridgeApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: kAppName,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        routerConfig: ref.watch(routerProvider),
      );
}
