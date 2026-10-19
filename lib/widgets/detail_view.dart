import 'package:flutter/material.dart';

/// Каркас карточки записи: загрузка, «не найдено», список полей.
class DetailView<T> extends StatelessWidget {
  final String title;
  final Future<T?> future;
  final String notFoundText;
  final List<(String, Widget)> Function(T item) fields;
  final String Function(T item) headline;

  const DetailView({
    super.key,
    required this.title,
    required this.future,
    required this.notFoundText,
    required this.fields,
    required this.headline,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<T?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Не удалось загрузить: ${snapshot.error}'),
            );
          }
          final item = snapshot.data;
          if (item == null) return Center(child: Text(notFoundText));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(headline(item), style: textTheme.headlineSmall),
              const SizedBox(height: 12),
              for (final (label, value) in fields(item))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 160,
                        child: Text(label, style: textTheme.bodySmall),
                      ),
                      Expanded(child: value),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
