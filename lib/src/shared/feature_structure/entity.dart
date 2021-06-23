import 'package:built_collection/built_collection.dart';

abstract class Entity {
  Object get id;
}

extension EntityIterable<E extends Entity> on Iterable<E> {
  bool containsEntity(Entity entity) => any((e) => e.id == entity.id);
}

extension EntityBuiltList<E extends Entity> on BuiltList<E> {
  int indexOfEntity(E entity) => indexWhere((e) => e.id == entity.id);
}

extension EntityListBuilder<E extends Entity> on ListBuilder<E> {
  void removeEntity(E entity) {
    for (var i = 0; i < length; i++) {
      final e = this[i];
      if (e.id == entity.id) {
        removeAt(i);
        return;
      }
    }
  }

  void replaceEntity(E entity) {
    for (var i = 0; i < length; i++) {
      final e = this[i];
      if (e.id == entity.id) {
        this[i] = entity;
        return;
      }
    }
  }
}
