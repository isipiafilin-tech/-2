import '../models/book.dart';
import '../models/book_query.dart';
import 'entity_repository.dart';

abstract interface class BookRepository
    implements EntityRepository<Book, BookQuery> {}
