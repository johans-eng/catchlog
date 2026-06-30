class ViewerSaved {
  final String room;
  final String? ntfy;

  const ViewerSaved({required this.room, this.ntfy});
}

abstract class ViewerPersistence {
  static void save({required String room, String? ntfy}) {}

  static ViewerSaved? load() => null;

  static void replaceViewerUrl(String room, String? ntfy) {}
}
