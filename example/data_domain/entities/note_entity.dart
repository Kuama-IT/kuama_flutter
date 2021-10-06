import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final String text;
  final DateTime createdAt;

  const NoteEntity({
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [text, createdAt];
}
