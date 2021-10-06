import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failures/dart_failures.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/params.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';

import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

// You can define use cases without parameters
class ReadAllNotes extends UseCase<NoParams, BuiltList<NoteEntity>> {
  // Use GetIt to quickly get a repository
  final _notesRepository = GetIt.I<NotesRepository>();

  @override
  Future<Either<Failure, BuiltList<NoteEntity>>> tryCall(NoParams params) async {
    final notes = _notesRepository.readAll();

    return Right(notes);
  }
}
