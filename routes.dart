import 'models/game_night.dart';

abstract final class Routes {
  static const String shell = '/';
  static const String detail = '/detail';
  static const String form = '/form';
}

/// Arguments of the detail screen: the item and the callbacks.
class DetailArgs {
  const DetailArgs({
    required this.item,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final GameNight item;
  final String profileName;
  final void Function(GameNight updated) onChanged;
  final void Function(String id) onDelete;
  final void Function() onOpenProfile;
}

/// Arguments of the form: null means "new item".
class FormArgs {
  const FormArgs({this.item});

  final GameNight? item;
}
