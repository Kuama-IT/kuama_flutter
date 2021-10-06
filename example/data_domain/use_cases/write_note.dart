import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failures/dart_failures.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/params.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';

import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class WriteNoteParams extends Params {
  final String text;

  const WriteNoteParams({
    required this.text,
  });

  @override
  List<Object?> get props => [text];
}

// You can define use cases with parameters
class WriteNote extends UseCase<WriteNoteParams, NoteEntity> {
  final _notesRepository = GetIt.I<NotesRepository>();

  // Manage the logic in the use case
  @override
  Future<Either<Failure, NoteEntity>> tryCall(WriteNoteParams params) async {
    final note = _notesRepository.create(params.text, DateTime.now());

    return Right(note);
  }
}
