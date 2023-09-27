import 'model/word.dart';
import 'objectbox.g.dart';

void test() {
  print('Staring generation...');
  final store = openStore();
  print('Doing some work...');
  final wordBox = store.box<Word>();
  print('Box is empty: ${wordBox.isEmpty()}');
  final query = wordBox.query(Word_.id.greaterThan(0)).build()..limit = 10;
  final words = query.find();
  for (final word in words) {
    print('Word: $word');
  }
  store.close();
  print('Generation finished.');
}
