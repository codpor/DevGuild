import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

import 'state_store.dart';

Future<StateStore> openStateStore() async {
  final directory = await getApplicationSupportDirectory();
  await directory.create(recursive: true);
  final database = await databaseFactoryIo.openDatabase(
    path.join(directory.path, 'devguild.db'),
  );
  return DatabaseStateStore(database);
}
