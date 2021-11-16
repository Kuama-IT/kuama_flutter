import 'package:built_collection/built_collection.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/params.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';

import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

// You can define use cases without parameters
class ReadAllNotes extends UseCase<NoParams, BuiltList<NoteEntity>> {
  // Use GetIt to quickly get a repository
  final _notesRepository = GetIt.I<NotesRepository>();

  @override
  Future<BuiltList<NoteEntity>> onCall(NoParams params) async {
    return _notesRepository.readAll();
  }
}
