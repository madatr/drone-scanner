sealed class DescriptionType {
  final int value;

  const DescriptionType({required this.value});
}

class DescriptionTypeText extends DescriptionType {
  const DescriptionTypeText() : super(value: 0);

  @override
  String toString() => 'Text Description';
}

class DescriptionTypeEmergency extends DescriptionType {
  const DescriptionTypeEmergency() : super(value: 1);

  @override
  String toString() => 'Emergency Description';
}

class DescriptionTypeExtendedStatus extends DescriptionType {
  const DescriptionTypeExtendedStatus() : super(value: 2);

  @override
  String toString() => 'Extended Status Description';
}

class DescriptionTypePrivate extends DescriptionType {
  const DescriptionTypePrivate({required super.value});

  @override
  String toString() => 'Private Description Type ($value)';
}
