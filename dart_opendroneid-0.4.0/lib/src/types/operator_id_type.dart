sealed class OperatorIDType {
  final int value;

  const OperatorIDType({required this.value});

  Map<String, dynamic> toJson() {
    return {'value': value};
  }
}

// TODO better naming??
class OperatorIDTypeOperatorID extends OperatorIDType {
  OperatorIDTypeOperatorID() : super(value: 0);

  @override
  String toString() => 'Operator ID';
}

class OperatorIDTypePrivate extends OperatorIDType {
  const OperatorIDTypePrivate({required super.value});

  @override
  String toString() => 'Private Operator ID Type ($value)';
}
