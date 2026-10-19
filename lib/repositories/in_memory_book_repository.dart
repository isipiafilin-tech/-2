import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import 'book_repository.dart';
import 'entity_repository.dart';
import 'seed_data.dart';

class InMemoryBookRepository implements BookRepository {
  final List<Book> _books = [...seedBooks];
  int _nextId = seedBooks.length + 1;

  @override
  Future<PageResult<Book>> find(BookQuery q) async {
    // Небольшая задержка имитирует сеть: без неё индикатор загрузки
    // невозможно увидеть, а в ПР4 он понадобится по-настоящему.
    await Future.delayed(const Duration(milliseconds: 250));

    if (q.yearFrom != null && q.yearTo != null && q.yearFrom! > q.yearTo!) {
      throw RepositoryException(
        'начальный год (${q.yearFrom}) больше конечного (${q.yearTo})',
      );
    }

    var rows = _books.where((b) => q.includeDeleted || !b.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (b) =>
                b.title.toLowerCase().contains(needle) ||
                b.isbn.toLowerCase().contains(needle),
          )
          .toList();
    }
    if (q.genreId != null) {
      rows = rows.where((b) => b.genreIds.contains(q.genreId)).toList();
    }
    if (q.publisherId != null) {
      rows = rows.where((b) => b.publisherId == q.publisherId).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((b) => b.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((b) => b.year <= q.yearTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'pages' => a.pages.compareTo(b.pages),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    return PageResult.slice(rows, q.page, q.size);
  }

  @override
  Future<Book?> findById(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    for (final book in _books) {
      if (book.id == id) return book;
    }
    return null;
  }

  @override
  Future<Book> create(Book book) async {
    final created = book.copyWith(id: _nextId++);
    _books.add(created);
    return created;
  }

  @override
  Future<Book> update(Book book) async {
    _books[_indexOf(book.id)] = book;
    return book;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _indexOf(id);
    _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _books.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _indexOf(id);
    _books[i] = _books[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      // Исправлено: в задании было `b.id == id && !b[i].isDeleted` —
      // у Book нет оператора [], а i используется в собственном
      // инициализаторе. Проверять нужно сам элемент b.
      final i = _books.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }

  int _indexOf(int id) {
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) throw RepositoryException('Книга $id не найдена');
    return i;
  }
}
