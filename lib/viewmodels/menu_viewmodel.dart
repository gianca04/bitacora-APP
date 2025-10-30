import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/menu_item_model.dart';
import '../repositories/menu_repository.dart';

/// Simple immutable state for the menu view
class MenuViewState {
  final List<MenuItemModel> items;
  final int selectedIndex;

  const MenuViewState({required this.items, this.selectedIndex = -1});

  MenuViewState copyWith({List<MenuItemModel>? items, int? selectedIndex}) {
    return MenuViewState(
      items: items ?? this.items,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class MenuViewModel extends StateNotifier<MenuViewState> {
  final MenuRepository repository;

  MenuViewModel({required this.repository}) : super(MenuViewState(items: [])) {
    _load();
  }

  void _load() {
    final items = repository.fetchMenuItems();
    state = state.copyWith(items: items);
  }

  void select(int index) {
    if (index < 0 || index >= state.items.length) return;
    state = state.copyWith(selectedIndex: index);
  }
}

final menuRepositoryProvider = Provider<MenuRepository>((ref) => MenuRepository());

final menuViewModelProvider = StateNotifierProvider<MenuViewModel, MenuViewState>((ref) {
  final repo = ref.read(menuRepositoryProvider);
  return MenuViewModel(repository: repo);
});

