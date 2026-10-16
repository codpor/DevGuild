import 'package:sembast_web/sembast_web.dart';

import 'state_store.dart';

Future<StateStore> openStateStore() async =>
    DatabaseStateStore(await databaseFactoryWeb.openDatabase('devguild'));
