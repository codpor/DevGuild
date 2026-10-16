import 'package:flutter/foundation.dart';

import 'app_repository.dart';

/// Menjadwalkan penyimpanan setiap perubahan provider, termasuk mutasi model.
class RepositoryNotifier extends ChangeNotifier {
  final AppRepository repository;
  RepositoryNotifier(this.repository);

  @override
  void notifyListeners() {
    repository.markChanged();
    super.notifyListeners();
  }
}
