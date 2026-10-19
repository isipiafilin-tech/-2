import 'package:flutter/foundation.dart';

import '../models/dictionary_item.dart';
import '../repositories/dictionary_repository.dart';

/// Жанры и издательства для фильтров и подписей.
class DictionaryNotifier extends ChangeNotifier {
  final DictionaryRepository _repository;

  DictionaryNotifier(this._repository);

  List<DictionaryItem> genres = const [];
  List<DictionaryItem> publishers = const [];

  Future<void> load() async {
    genres = await _repository.genres();
    publishers = await _repository.publishers();
    notifyListeners();
  }

  String genreName(int id) => _name(genres, id);
  String publisherName(int id) => _name(publishers, id);

  String _name(List<DictionaryItem> items, int id) {
    for (final item in items) {
      if (item.id == id) return item.name;
    }
    return '#$id';
  }
}
