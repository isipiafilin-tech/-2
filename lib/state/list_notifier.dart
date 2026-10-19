import 'package:flutter/foundation.dart';

import '../models/page_result.dart';
import '../repositories/entity_repository.dart';

enum LoadStatus { idle, loading, success, error }

/// Состояние экрана списка: условия отбора, текущая страница, выделение.
///
/// Общее для книг и авторов; отличаются только типы [T] и [Q].
class ListNotifier<T, Q> extends ChangeNotifier {
  final EntityRepository<T, Q> _repository;

  ListNotifier(this._repository, Q initialQuery) : _query = initialQuery;

  Q _query;
  PageResult<T> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  Q get query => _query;
  PageResult<T> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(Q next) async {
    _query = next;
    _selected.clear(); // выделение теряет смысл при смене условий отбора
    await load();
  }

  /// Вызывается экраном, когда меняется адрес: загружает список,
  /// только если условия из адреса отличаются от текущих.
  Future<void> syncWith(Q fromAddress) async {
    if (fromAddress != _query || _status == LoadStatus.idle) {
      await applyQuery(fromAddress);
    }
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  Future<void> softDelete(int id) =>
      _changeAndReload(_repository.softDelete(id));
  Future<void> hardDelete(int id) =>
      _changeAndReload(_repository.hardDelete(id));
  Future<void> restore(int id) => _changeAndReload(_repository.restore(id));

  Future<T?> findById(int id) => _repository.findById(id);

  Future<void> _changeAndReload(Future<void> change) async {
    await change;
    _selected.clear();
    await load();
  }
}
