import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/author_query.dart';
import '../models/query_params.dart';
import '../state/author_list_notifier.dart';
import '../widgets/catalog_scaffold.dart';
import '../widgets/debounced_text_field.dart';
import '../widgets/entity_list_view.dart';
import '../widgets/entity_table.dart';

class AuthorsScreen extends StatefulWidget {
  final AuthorQuery query;

  const AuthorsScreen({super.key, required this.query});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(AuthorsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _sync();
  }

  void _sync() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) context.read<AuthorListNotifier>().syncWith(widget.query);
  });

  void _go(AuthorQuery query) => context.go(query.toUri().toString());

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthorListNotifier>();
    final q = widget.query;

    return CatalogScaffold(
      title: 'Авторы',
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
                    label: 'Поиск по фамилии или стране',
                    icon: Icons.search,
                    value: q.search,
                    onChanged: (v) => _go(q.copyWith(search: v)),
                  ),
                ),
                FilterChip(
                  label: const Text('Показывать удалённых'),
                  selected: q.includeDeleted,
                  onSelected: (v) => _go(q.copyWith(includeDeleted: v)),
                ),
                TextButton(
                  onPressed: () => _go(const AuthorQuery()),
                  child: const Text('Сбросить'),
                ),
              ],
            ),
          ),
          Expanded(
            child: EntityListView<Author>(
              notifier: notifier,
              idOf: (a) => a.id,
              isDeleted: (a) => a.isDeleted,
              titleOf: (a) => a.fullName,
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
              onOpen: (a) => context.go(
                listUri('/authors/${a.id}', q.toQueryParameters()).toString(),
              ),
              onReset: () => _go(const AuthorQuery()),
              columns: [
                TableColumnSpec(
                  label: 'Фамилия',
                  sortField: 'lastName',
                  build: (a) => Text(a.lastName),
                ),
                TableColumnSpec(label: 'Имя', build: (a) => Text(a.firstName)),
                TableColumnSpec(
                  label: 'Страна',
                  sortField: 'country',
                  build: (a) => Text(a.country),
                ),
                TableColumnSpec(
                  label: 'Год рождения',
                  sortField: 'birthYear',
                  numeric: true,
                  build: (a) => Text('${a.birthYear}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
