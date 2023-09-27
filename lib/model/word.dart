import 'package:objectbox/objectbox.dart';

@Entity(uid: 1)
class Word {
  @Id()
  int id = 0;

  int langId;

  String letter;

  int wordId;

  String word;

  String lword;

  String? lwordMask;

  Word({
    required this.langId,
    required this.letter,
    required this.wordId,
    required this.word,
    required this.lword,
    required this.lwordMask,
  });

  @override
  String toString() => 'Word(id: $id, langId: $langId, $letter, $wordId, $word, $lword, $lwordMask)';
}
