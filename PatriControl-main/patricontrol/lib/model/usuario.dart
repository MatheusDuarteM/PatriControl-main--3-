import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Usuario {
  final int? idUsuario;
  final String nomeUsuario;
  String? senhaUsuario;
  final String cpfUsuario;
  final DateTime nascUsuario;
  final String tipoUsuario;
  final bool? deletadoUsuario;

  Usuario({
    this.idUsuario,
    required this.nomeUsuario,
    this.senhaUsuario,
    required this.cpfUsuario,
    required this.nascUsuario,
    required this.tipoUsuario,
    this.deletadoUsuario,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    // Acessando com as chaves exatas da API (snake_case)
    final String? nascUsuarioString = json['nasc_usuario'] as String?; // CORRIGIDO: 'nasc_usuario'
    DateTime parsedNascUsuario;

    if (nascUsuarioString != null && nascUsuarioString.isNotEmpty) {
      try {
        parsedNascUsuario = DateTime.parse(nascUsuarioString);
      } catch (e) {
        if (kDebugMode) { // Use kDebugMode para prints de debug
          print('Erro ao parsear nasc_usuario: $e para valor "$nascUsuarioString". Usando data atual como fallback.');
        }
        parsedNascUsuario = DateTime.now(); // Fallback
      }
    } else {
      if (kDebugMode) {
        print('nasc_usuario é null ou vazio na API. Usando data atual como fallback.');
      }
      parsedNascUsuario = DateTime.now(); // Fallback
    }

    // Tratamento para tipo_usuario
    final String? tipoUsuarioString = json['tipo_usuario'] as String?; // CORRIGIDO: 'tipo_usuario'
    
    // Tratamento para deletado_usuario (vindo como int: 0 ou 1)
    final int? deletadoUsuarioInt = json['deletado_usuario'] as int?; // CORRIGIDO: 'deletado_usuario'
    bool? parsedDeletadoUsuario;
    if (deletadoUsuarioInt != null) {
      parsedDeletadoUsuario = deletadoUsuarioInt == 1; // Converte 0 para false, 1 para true
    }


    return Usuario(
      idUsuario: json['id_usuario'] as int?,        // CORRIGIDO: 'id_usuario'
      nomeUsuario: json['nome_usuario'] as String,    // CORRIGIDO: 'nome_usuario'
      cpfUsuario: json['cpf_usuario'] as String,      // CORRIGIDO: 'cpf_usuario'
      nascUsuario: parsedNascUsuario, // Já é DateTime e garantido não-nulo pelo fallback
      tipoUsuario: tipoUsuarioString ?? 'Padrão', // Fallback se 'tipo_usuario' for null/vazio
      senhaUsuario: null, // Senha não deve ser preenchida via fromJson para segurança
      deletadoUsuario: parsedDeletadoUsuario, // Atribui o valor booleano
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // No toJson, use snake_case se a sua API espera isso para o envio
      'id_usuario': idUsuario,
      'nome_usuario': nomeUsuario,
      'cpf_usuario': cpfUsuario,
      'nasc_usuario': DateFormat('yyyy-MM-dd').format(nascUsuario),
      'tipo_usuario': tipoUsuario,
      'deletado_usuario': deletadoUsuario == true ? 1 : 0, // Converte bool para int 0 ou 1
      // 'senhaUsuario': senhaUsuario, // Incluir APENAS se for para enviar (cadastro/edição de senha)
    };
  }
}