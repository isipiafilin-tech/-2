import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../state/author_list_notifier.dart';
import '../widgets/detail_view.dart';

class AuthorDetailScreen extends StatefulWidget {
  final int id;

  const AuthorDetailScreen({super.key, required this.id});

  @override
  State<AuthorDetailScreen> createState() => _AuthorDetailScreenState();
}

class _AuthorDetailScreenState extends State<AuthorDetailScreen> {
  late final Future<Author?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AuthorListNotifier>().findById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return DetailView<Author>(
      title: 'Карточка автора',
      future: _future,
      notFoundText: 'Автор ${widget.id} не найден',
      headline: (a) => a.fullName,
      fields: (a) => [
        ('Фамилия', Text(a.lastName)),
        ('Имя', Text(a.firstName)),
        ('Страна', Text(a.country)),
        ('Год рождения', Text('${a.birthYear}')),
        if (a.isDeleted) ('Удалён', Text('${a.deletedAt}')),
      ],
    );
  }
}
