import 'package:built_collection/built_collection.dart';

import '../entities/note_entity.dart';

class NotesRepository {
  var _notes = BuiltList<NoteEntity>();

  NoteEntity create(String text, DateTime createdAt) {
    final note = NoteEntity(text: text, createdAt: createdAt);
    _notes = _notes.rebuild((b) => b.add(note));
    return note;
  }

  BuiltList<NoteEntity> readAll() {
    return _notes;
  }
}
