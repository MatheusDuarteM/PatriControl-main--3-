// Enum para Tipos de Patrimônio
import 'package:collection/collection.dart';

enum TipoPatrimonio {
  custeio('Custeio'),
  capital('Capital');

  final String displayValue;
  const TipoPatrimonio(this.displayValue);

  static TipoPatrimonio? fromString(String? value) {
    if (value == null) return null;
    return TipoPatrimonio.values.firstWhereOrNull((e) => e.displayValue == value);
  }
}