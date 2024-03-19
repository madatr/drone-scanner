import '../enums.dart';

sealed class UAClassification {
  final int value;

  const UAClassification({required this.value});
}

class UAClassificationUndeclared extends UAClassification {
  const UAClassificationUndeclared() : super(value: 0);

  @override
  String toString() => 'UAClassificationUndeclared';
}

class UAClassificationEurope extends UAClassification {
  final UACategoryEurope uaCategoryEurope;
  final UAClassEurope uaClassEurope;

  const UAClassificationEurope({
    required this.uaCategoryEurope,
    required this.uaClassEurope,
  }) : super(value: 1);

  @override
  String toString() => 'UAClassificationEurope {'
      'Category: $uaCategoryEurope, '
      'Class: $uaClassEurope'
      '}';
}
