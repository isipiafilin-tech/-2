import '../models/book.dart';
import '../models/book_query.dart';
import '../repositories/book_repository.dart';
import 'list_notifier.dart';

class BookListNotifier extends ListNotifier<Book, BookQuery> {
  BookListNotifier(BookRepository repository)
    : super(repository, const BookQuery());
}
