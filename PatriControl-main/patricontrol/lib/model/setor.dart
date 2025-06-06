import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint (opcional, pode ser removido em produção)

class Setor extends Equatable {
  final int? id_setor;
  final String tipo_setor;
  final String nome_setor;
  final String responsavel_setor;
  final String descricao_setor;
  final String contato_setor;
  final String email_setor;
  final int deletado_setor;

  Setor({
    this.id_setor,
    required this.tipo_setor,
    required this.nome_setor,
    required this.responsavel_setor,
    required this.descricao_setor,
    required this.contato_setor,
    required this.email_setor,
    this.deletado_setor = 0,
  });

  factory Setor.fromJson(Map<String, dynamic> json) {
    // Helper para parsear ints de forma robusta
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      debugPrint(
        'AVISO: Tipo inesperado para campo int: ${value.runtimeType}. Valor: $value',
      );
      return null;
    }

    // Helper para parsear Strings de forma robusta, com fallback para '' se for required
    String _parseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      if (value is String) return value;
      debugPrint(
        'AVISO: Tipo inesperado para campo String: ${value.runtimeType}. Valor: $value',
      );
      return value.toString(); // Tenta converter para String
    }

    // Helper para parsear int com fallback padrão (0) para campos não-nullable
    int _parseIntWithDefault(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? fallback;
      debugPrint(
        'AVISO: Tipo inesperado para campo int com default: ${value.runtimeType}. Valor: $value',
      );
      return fallback;
    }

    return Setor(
      id_setor: _parseInt(json['id_setor']),
      tipo_setor: _parseString(json['tipo_setor']),
      nome_setor: _parseString(json['nome_setor']),
      responsavel_setor: _parseString(json['responsavel_setor']),
      descricao_setor: _parseString(json['descricao_setor']),
      contato_setor: _parseString(json['contato_setor']),
      email_setor: _parseString(json['email_setor']),
      deletado_setor: _parseIntWithDefault(json['deletado_setor'], fallback: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_setor': id_setor,
      'tipo_setor': tipo_setor,
      'nome_setor': nome_setor,
      'responsavel_setor': responsavel_setor,
      'descricao_setor': descricao_setor,
      'contato_setor': contato_setor,
      'email_setor': email_setor,
      'deletado_setor': deletado_setor,
    };
  }

  @override
  List<Object?> get props => [id_setor];

  get id => null;

  get nome => null;
}
