import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint (opcional, pode ser removido em produção)

// ignore: must_be_immutable
class Fornecedor extends Equatable {
  final int? id_fornecedor;
  final String nome_fornecedor;
  final String cnpj_fornecedor;
  final String contato_fornecedor;
  final String endereco_fornecedor;
  final int deletado_fornecedor;

  Fornecedor({
    this.id_fornecedor,
    required this.nome_fornecedor,
    required this.cnpj_fornecedor,
    required this.contato_fornecedor,
    required this.endereco_fornecedor,
    this.deletado_fornecedor = 0,
  });

  factory Fornecedor.fromJson(Map<String, dynamic> json) {
    // Helper para parsear ints de forma robusta
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      debugPrint('AVISO: Tipo inesperado para campo int: ${value.runtimeType}. Valor: $value');
      return null; // Retorna null para tipos inesperados
    }

    // Helper para parsear Strings de forma robusta, com fallback para '' se for required
    String _parseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      if (value is String) return value;
      debugPrint('AVISO: Tipo inesperado para campo String: ${value.runtimeType}. Valor: $value');
      return value.toString(); // Tenta converter para String
    }

    // Helper para parsear int com fallback padrão (0) para campos não-nullable
    int _parseIntWithDefault(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? fallback;
      debugPrint('AVISO: Tipo inesperado para campo int com default: ${value.runtimeType}. Valor: $value');
      return fallback;
    }

    return Fornecedor(
      id_fornecedor: _parseInt(json['id_fornecedor']),
      nome_fornecedor: _parseString(json['nome_fornecedor']),
      cnpj_fornecedor: _parseString(json['cnpj_fornecedor']),
      contato_fornecedor: _parseString(json['contato_fornecedor']),
      endereco_fornecedor: _parseString(json['endereco_fornecedor']),
      deletado_fornecedor: _parseIntWithDefault(json['deletado_fornecedor'], fallback: 0),
    );
  }

  // Opcional: Método toJson para converter um Fornecedor em um Map
  Map<String, dynamic> toJson() {
    return {
      'id_fornecedor': id_fornecedor,
      'nome_fornecedor': nome_fornecedor,
      'cnpj_fornecedor': cnpj_fornecedor,
      'contato_fornecedor': contato_fornecedor,
      'endereco_fornecedor': endereco_fornecedor,
      'deletado_fornecedor': deletado_fornecedor,
    };
  }

  @override
  List<Object?> get props => [
        id_fornecedor,
      ];
}