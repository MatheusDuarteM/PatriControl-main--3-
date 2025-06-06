// lib/utils/cpf_validator.dart
class CpfValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite o CPF.';
    }

    final cpfSemFormatacao = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cpfSemFormatacao.length != 11) {
      return 'CPF inválido.';
    }

    // Verificar se todos os dígitos são iguais (CPFs inválidos comuns)
    if (RegExp(r'^(\d)\1+$').hasMatch(cpfSemFormatacao)) {
      return 'CPF inválido.';
    }

    // Validação dos dígitos verificadores
    List<int> digitos = cpfSemFormatacao.split('').map(int.parse).toList();
    List<int> multiplicadores1 = [10, 9, 8, 7, 6, 5, 4, 3, 2];
    List<int> multiplicadores2 = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2];

    int soma1 = 0;
    for (int i = 0; i < 9; i++) {
      soma1 += digitos[i] * multiplicadores1[i];
    }
    int resto1 = soma1 % 11;
    int digitoVerificador1 = (resto1 < 2) ? 0 : 11 - resto1;

    if (digitos[9] != digitoVerificador1) {
      return 'CPF inválido.';
    }

    int soma2 = 0;
    for (int i = 0; i < 10; i++) {
      soma2 += digitos[i] * multiplicadores2[i];
    }
    int resto2 = soma2 % 11;
    int digitoVerificador2 = (resto2 < 2) ? 0 : 11 - resto2;

    if (digitos[10] != digitoVerificador2) {
      return 'CPF inválido.';
    }

    return null;
  }
}
