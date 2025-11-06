import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class ResponsiveNavBarPage extends ConsumerWidget {
  const ResponsiveNavBarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(menuViewModelProvider);
    return Center(
      child: Text('Index y pantalla principal'),
    );
  }
}
