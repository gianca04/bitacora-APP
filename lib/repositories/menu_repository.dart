import '../models/menu_item_model.dart';

class MenuRepository {
  // In a real app this might call an API or database. Kept sync for simplicity.
  List<MenuItemModel> fetchMenuItems() {
    return const [
      MenuItemModel('Home'),
      MenuItemModel('Reports'),
      MenuItemModel('About'),
      MenuItemModel('Contact'),
      MenuItemModel('Settings'),
      MenuItemModel('Sign Out'),
    ];
  }
}
