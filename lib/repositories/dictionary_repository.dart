import '../models/dictionary_item.dart';
import 'seed_data.dart';

/// Справочники жанров и издательств.
abstract interface class DictionaryRepository {
  Future<List<DictionaryItem>> genres();
  Future<List<DictionaryItem>> publishers();
}

class InMemoryDictionaryRepository implements DictionaryRepository {
  @override
  Future<List<DictionaryItem>> genres() async => seedGenres;

  @override
  Future<List<DictionaryItem>> publishers() async => seedPublishers;
}
