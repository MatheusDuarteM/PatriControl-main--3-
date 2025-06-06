// lib/utils/cnpj_validator.dart
class CnpjValidator {
  
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite o CNPJ.';
    }

    final cnpjSemFormatacao = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cnpjSemFormatacao.length != 14) {
      return 'CNPJ inválido.';
    }

    // Verificar se todos os dígitos são iguais (CNPJs inválidos comuns)
    if (RegExp(r'^(\d)\1+$').hasMatch(cnpjSemFormatacao)) {
      return 'CNPJ inválido.';
    }

    // Validação dos dígitos verificadores (algoritmo padrão)
    List<int> digitos = cnpjSemFormatacao.split('').map(int.parse).toList();
    List<int> multiplicadores1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    List<int> multiplicadores2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    int soma1 = 0;
    for (int i = 0; i < 12; i++) {
      soma1 += digitos[i] * multiplicadores1[i];
    }
    int resto1 = soma1 % 11;
    int digitoVerificador1 = (resto1 < 2) ? 0 : 11 - resto1;

    if (digitos[12] != digitoVerificador1) {
      return 'CNPJ inválido';
    }

    int soma2 = 0;
    for (int i = 0; i < 13; i++) {
      soma2 += digitos[i] * multiplicadores2[i];
    }
    int resto2 = soma2 % 11;
    int digitoVerificador2 = (resto2 < 2) ? 0 : 11 - resto2;

    if (digitos[13] != digitoVerificador2) {
      return 'CNPJ inválido';
    }

    return null;
  }
}