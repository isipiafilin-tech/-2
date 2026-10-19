import '../models/author.dart';
import '../models/author_query.dart';
import '../models/page_result.dart';
import 'author_repository.dart';
import 'entity_repository.dart';
import 'seed_data.dart';

class InMemoryAuthorRepository implements AuthorRepository {
  final List<Author> _authors = [...seedAuthors];
  int _nextId = seedAuthors.length + 1;

  @override
  Future<PageResult<Author>> find(AuthorQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));

    var rows = _authors.where((a) => q.includeDeleted || !a.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (a) =>
                a.lastName.toLowerCase().contains(needle) ||
                a.country.toLowerCase().contains(needle),
          )
          .toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'country' => a.country.compareTo(b.country),
        'birthYear' => a.birthYear.compareTo(b.birthYear),
        _ => a.lastName.compareTo(b.lastName),
      };
      return q.sortAscending ? result : -result;
    });

    return PageResult.slice(rows, q.page, q.size);
  }

  @override
  Future<Author?> findById(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    for (final author in _authors) {
      if (author.id == id) return author;
    }
    return null;
  }

  @override
  Future<Author> create(Author author) async {
    final created = author.copyWith(id: _nextId++);
    _authors.add(created);
    return created;
  }

  @override
  Future<Author> update(Author author) async {
    _authors[_indexOf(author.id)] = author;
    return author;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _indexOf(id);
    _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _authors.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _indexOf(id);
    _authors[i] = _authors[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _authors.indexWhere((a) => a.id == id && !a.isDeleted);
      if (i != -1) {
        _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }

  int _indexOf(int id) {
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw RepositoryException('Автор $id не найден');
    return i;
  }
}
