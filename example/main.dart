// ignore_for_file: avoid_print

import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failures/dart_failures.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/params.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case_observer.dart';

import 'data_domain/repositories/notes_repository.dart';
import 'data_domain/use_cases/read_all_notes.dart';
import 'data_domain/use_cases/write_note.dart';

// This is an example of a note-taking application
void main() async {
  // By changing the listener we can now log all the errors and failures of the use cases
  UseCaseBase.observer = MyUseCaseObserver();

  GetIt.instance.registerSingleton(NotesRepository());

  final writeNoteUC = WriteNote();
  final readNotesUC = ReadAllNotes();

  while (true) {
    print(
        'You can:\n - [write]: Write a note\n - [read]: Read all notes\n - [exit]: close the app');

    final line = stdin.readLineSync();

    if (line == 'exit') return;

    if (line == 'write') {
      final line = stdin.readLineSync();

      if (line == null || line == '') continue;

      // There is no need to call the call method to call a use case
      await writeNoteUC(WriteNoteParams(text: line));
    }

    if (line == 'read') {
      // Never call onCall when calling a use case
      final notes = await readNotesUC.call(NoParams());

      print(notes.map((note) {
        return 'Created at: ${note.createdAt}\n${note.text}';
      }).join('\n'));
    }
  }
}

class MyUseCaseObserver extends UseCaseObserver {
  @override
  void onError(UseCaseBase useCase, params, Object error, StackTrace stackTrace) {
    print(error);
    print(stackTrace);
  }

  @override
  void onFailure(UseCaseBase useCase, params, Failure failure, StackTrace stackTrace) {
    print(failure);
    print(stackTrace);
  }
}
