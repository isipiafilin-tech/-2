import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Каркас экранов списка с переходом между разделами каталога.
class CatalogScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const CatalogScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => context.go('/books'),
            child: const Text('Книги'),
          ),
          TextButton(
            onPressed: () => context.go('/authors'),
            child: const Text('Авторы'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}
