import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/menu_viewmodel.dart';

class ResponsiveNavBarPage extends ConsumerWidget {
  const ResponsiveNavBarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(menuViewModelProvider);
    return Center(
      child: Text('Selected: ${state.selectedIndex}'),
    );
  }
}
