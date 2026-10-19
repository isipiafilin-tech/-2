import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/book_query.dart';
import '../models/query_params.dart';
import '../state/book_list_notifier.dart';
import '../state/dictionary_notifier.dart';
import '../widgets/catalog_scaffold.dart';
import '../widgets/debounced_text_field.dart';
import '../widgets/entity_list_view.dart';
import '../widgets/entity_table.dart';
import '../widgets/filter_dropdown.dart';

class BooksScreen extends StatefulWidget {
  /// Условия отбора, разобранные из адреса /books?...
  final BookQuery query;

  const BooksScreen({super.key, required this.query});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(BooksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _sync();
  }

  /// Адрес изменился (переход, «назад», новая вкладка) — подгружаем список.
  /// После кадра, потому что загрузка сразу вызывает notifyListeners.
  void _sync() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) context.read<BookListNotifier>().syncWith(widget.query);
  });

  /// Любое изменение условий отбора — это переход на новый адрес.
  void _go(BookQuery query) => context.go(query.toUri().toString());

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookListNotifier>();
    final dictionary = context.watch<DictionaryNotifier>();
    final q = widget.query;

    return CatalogScaffold(
      title: 'Книги',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: DebouncedTextField(
                    label: 'Поиск по названию или ISBN',
                    icon: Icons.search,
                    value: q.search,
                    onChanged: (v) => _go(q.copyWith(search: v)),
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: FilterDropdown(
                    label: 'Жанр',
                    value: q.genreId,
                    items: dictionary.genres,
                    onChanged: (v) => _go(q.copyWith(genreId: v)),
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: FilterDropdown(
                    label: 'Издательство',
                    value: q.publisherId,
                    items: dictionary.publishers,
                    onChanged: (v) => _go(q.copyWith(publisherId: v)),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: DebouncedTextField(
                    label: 'Год с',
                    digitsOnly: true,
                    value: q.yearFrom?.toString() ?? '',
                    onChanged: (v) =>
                        _go(q.copyWith(yearFrom: int.tryParse(v))),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: DebouncedTextField(
                    label: 'Год по',
                    digitsOnly: true,
                    value: q.yearTo?.toString() ?? '',
                    onChanged: (v) => _go(q.copyWith(yearTo: int.tryParse(v))),
                  ),
                ),
                FilterChip(
                  label: const Text('Показывать удалённые'),
                  selected: q.includeDeleted,
                  onSelected: (v) => _go(q.copyWith(includeDeleted: v)),
                ),
                TextButton(
                  onPressed: () => _go(const BookQuery()),
                  child: const Text('Сбросить'),
                ),
              ],
            ),
          ),
          Expanded(
            child: EntityListView<Book>(
              notifier: notifier,
              idOf: (b) => b.id,
              isDeleted: (b) => b.isDeleted,
              titleOf: (b) => b.title,
              sortField: q.sortField,
              sortAscending: q.sortAscending,
              onSort: (field) => _go(
                q.copyWith(
                  sortField: field,
                  sortAscending: field == q.sortField ? !q.sortAscending : true,
                ),
              ),
              onPage: (page) => _go(q.copyWith(page: page)),
              onSize: (size) => _go(q.copyWith(size: size)),
              onOpen: (b) => context.go(
                listUri('/books/${b.id}', q.toQueryParameters()).toString(),
              ),
              onReset: () => _go(const BookQuery()),
              columns: [
                TableColumnSpec(
                  label: 'Название',
                  sortField: 'title',
                  build: (b) => Text(b.title),
                ),
                TableColumnSpec(label: 'ISBN', build: (b) => Text(b.isbn)),
                TableColumnSpec(
                  label: 'Год',
                  sortField: 'year',
                  numeric: true,
                  build: (b) => Text('${b.year}'),
                ),
                TableColumnSpec(
                  label: 'Страниц',
                  sortField: 'pages',
                  numeric: true,
                  build: (b) => Text('${b.pages}'),
                ),
                TableColumnSpec(
                  label: 'Издательство',
                  build: (b) => Text(dictionary.publisherName(b.publisherId)),
                ),
                TableColumnSpec(
                  label: 'В наличии',
                  numeric: true,
                  build: (b) =>
                      Text('${b.copiesAvailable} из ${b.copiesTotal}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
