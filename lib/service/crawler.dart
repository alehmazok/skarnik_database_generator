import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import '../model/word.dart';

class SkarnikDict {
  final String name;
  final String letter;
  final int langId;

  const SkarnikDict({
    required this.name,
    required this.letter,
    required this.langId,
  });

  static const SkarnikDict rusBel = SkarnikDict(
    name: 'rusbel',
    letter: 'bukva',
    langId: 0,
  );

  static const SkarnikDict belRus = SkarnikDict(
    name: 'belrus',
    letter: 'litara',
    langId: 1,
  );

  static const SkarnikDict tsbm = SkarnikDict(
    name: 'tsbm',
    letter: 'litara-tsbm',
    langId: 2,
  );

  static const all = [
    rusBel,
    belRus,
    tsbm,
  ];
}

class SkarnikCrawler {
  static const baseUrl = 'https://skarnik.by';
  final _dio = Dio();

  Future<Document> getDocument(Uri uri) async {
    print('Url: $uri');
    final res = await _dio.get(uri.toString());
    final document = parse(res.data);
    final title = document.querySelector('title')?.innerHtml;
    print('Title: $title');
    return document;
  }

  Iterable<String> findLetters(Document document, SkarnikDict dict) {
    final letters = document.querySelectorAll('[href*="${dict.letter}/"]');
    return letters.map((it) => it.innerHtml);
  }

  Iterable<Word> findWords(Document document, String letter, SkarnikDict dict) {
    final words = document.querySelectorAll('[href*="/${dict.name}/"]');
    return words.map((it) => it.toWord(letter, dict));
  }

  Stream<Word> start() async* {
    final rootDoc = await getDocument(Uri.parse(baseUrl));
    for (final dict in SkarnikDict.all) {
      final letters = findLetters(rootDoc, dict);
      for (final letter in letters) {
        final letterDoc = await getDocument(Uri.parse('$baseUrl/${dict.letter}/$letter'));
        final words = findWords(letterDoc, letter, dict);
        for (final word in words) {
          yield word;
        }
      }
    }
  }
}

extension WordExt on Element {
  static const charReplacements = {'и': 'і', 'е': 'ё', 'щ': 'ў', 'ъ': '‘', '\'': '‘'};

  /// returns null if no replacements made
  static String _replaceChars(String lword) {
    for (final entry in charReplacements.entries) {
      lword = lword.replaceAll(entry.key, entry.value);
    }
    return lword;
  }

  String get _lastHrefSegment => attributes['href']!.split('/').last;

  Word toWord(String letter, SkarnikDict dict) {
    final lletter = letter.toLowerCase();
    final wordId = int.parse(_lastHrefSegment);
    final word = innerHtml;
    final lword = word.toLowerCase();
    final lwordMask = _replaceChars(lword);

    return Word(
      langId: dict.langId,
      letter: lletter,
      wordId: wordId,
      word: word,
      lword: lword,
      lwordMask: lword == lwordMask ? null : lwordMask,
    );
  }
}
