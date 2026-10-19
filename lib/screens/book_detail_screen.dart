import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../state/author_list_notifier.dart';
import '../state/book_list_notifier.dart';
import '../state/dictionary_notifier.dart';
import '../widgets/detail_view.dart';

class BookDetailScreen extends StatefulWidget {
  final int id;

  const BookDetailScreen({super.key, required this.id});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late final Future<(Book, List<Author>)?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load(
      context.read<BookListNotifier>(),
      context.read<AuthorListNotifier>(),
    );
  }

  Future<(Book, List<Author>)?> _load(
    BookListNotifier books,
    AuthorListNotifier authors,
  ) async {
    final book = await books.findById(widget.id);
    if (book == null) return null;
    final found = await Future.wait(book.authorIds.map(authors.findById));
    return (book, found.whereType<Author>().toList());
  }

  @override
  Widget build(BuildContext context) {
    final dictionary = context.watch<DictionaryNotifier>();
    return DetailView<(Book, List<Author>)>(
      title: 'Карточка книги',
      future: _future,
      notFoundText: 'Книга ${widget.id} не найдена',
      headline: (data) => data.$1.title,
      fields: (data) {
        final (book, authors) = data;
        return [
          (
            'Авторы',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final author in authors)
                  ActionChip(
                    label: Text(author.fullName),
                    onPressed: () => context.go('/authors/${author.id}'),
                  ),
              ],
            ),
          ),
          ('ISBN', Text(book.isbn)),
          ('Год издания', Text('${book.year}')),
          ('Страниц', Text('${book.pages}')),
          ('Издательство', Text(dictionary.publisherName(book.publisherId))),
          ('Жанры', Text(book.genreIds.map(dictionary.genreName).join(', '))),
          (
            'Экземпляры',
            Text('в наличии ${book.copiesAvailable} из ${book.copiesTotal}'),
          ),
          if (book.isDeleted) ('Удалена', Text('${book.deletedAt}')),
        ];
      },
    );
  }
}
