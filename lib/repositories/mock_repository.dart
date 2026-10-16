import '../data/demo_state.dart';
import 'memory_repository.dart';

/// Repository terisolasi tanpa penyimpanan, untuk test.
class MockRepository extends MemoryRepository {
  MockRepository() : super(createDemoState());
}
