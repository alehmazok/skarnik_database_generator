import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

import '../model/word.dart';
import '../objectbox.g.dart';

abstract class Storage {
  const Storage._();

  Future<int> saveStream(Stream<Word> wordStream);
}

class JsonFileStorage implements Storage {
  final file = File('db.json');

  JsonFileStorage() {
    _createFile();
  }

  Future<void> _createFile() async {
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
  }

  void _append(String value) {
    file.writeAsStringSync(value, mode: FileMode.append);
  }

  void _save(Word word) {
    _append(word.toJson());
  }

  @override
  Future<int> saveStream(Stream<Word> wordStream) async {
    _append('[\n');
    int counter = 0;
    await for (final word in wordStream) {
      if (counter != 0) {
        _append(',\n');
      }
      _save(word);
      counter += 1;
    }
    _append('\n]');
    return counter;
  }
}

extension JsonExt on Word {
  static const encoder = JsonEncoder.withIndent('  ');

  String toJson() {
    final map = {
      'id': id,
      'lang_id': langId,
      'letter': letter,
      'wordId': wordId,
      'word': word,
      'lword': lword,
      'lword_mask': lwordMask,
    };
    return encoder.convert(map);
  }
}

class ObjectBoxStorage implements Storage {
  late final Store _store;
  late final Box<Word> _box;

  ObjectBoxStorage() {
    _init();
  }

  void _init() async {
    _store = openStore();
    _box = _store.box<Word>();
    _box.removeAll();
  }

  void _close() => _store.close();

  @override
  Future<int> saveStream(Stream<Word> wordStream) async {
    final bufferedStream = wordStream.bufferCount(500);
    await for (final words in bufferedStream) {
      _box.putMany(words);
    }
    final count = _box.count();
    _close();
    return count;
  }
}
