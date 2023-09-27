import 'package:skarnik_database_generator/test.dart';
import 'package:skarnik_database_generator/service/crawler.dart';
import 'package:skarnik_database_generator/service/storage.dart';

void main(List<String> arguments) async {
  final crawler = SkarnikCrawler();
  final storage = ObjectBoxStorage();
  final count = await storage.saveStream(crawler.start());
  print('Saved words: $count');
  // test();
}
