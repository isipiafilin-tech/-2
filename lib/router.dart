import 'package:go_router/go_router.dart';

import 'models/author_query.dart';
import 'models/book_query.dart';
import 'screens/author_detail_screen.dart';
import 'screens/authors_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/books_screen.dart';

/// Условия отбора живут в адресе: экран списка получает их из
/// queryParameters, поэтому ссылка на отфильтрованный список
/// открывается в новой вкладке в том же состоянии.
final router = GoRouter(
  initialLocation: '/books',
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/books'),
    GoRoute(
      path: '/books',
      builder: (context, state) => BooksScreen(
        query: BookQuery.fromQueryParameters(state.uri.queryParameters),
      ),
      routes: [
        // Карточка вложена в список: при возврате назад параметры отбора
        // из адреса сохраняются.
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              BookDetailScreen(id: int.parse(state.pathParameters['id']!)),
        ),
      ],
    ),
    GoRoute(
      path: '/authors',
      builder: (context, state) => AuthorsScreen(
        query: AuthorQuery.fromQueryParameters(state.uri.queryParameters),
      ),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              AuthorDetailScreen(id: int.parse(state.pathParameters['id']!)),
        ),
      ],
    ),
  ],
);
