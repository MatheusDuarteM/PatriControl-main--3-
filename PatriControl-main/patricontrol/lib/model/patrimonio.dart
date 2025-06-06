// lib/model/patrimonio.dart

import 'package:equatable/equatable.dart';
import 'package:patricontrol/model/fornecedor.dart'; // Ajuste o caminho se necessário
import 'package:patricontrol/model/marca.dart';     // Ajuste o caminho se necessário
import 'package:patricontrol/model/modelo.dart';    // Ajuste o caminho se necessário
import 'package:patricontrol/model/setor.dart';     // Ajuste o caminho se necessário

class Patrimonio extends Equatable {
  final int? idPatrimonio;
  final String? codigoPatrimonio;
  final String? imagemPatrimonio;
  final String tipoPatrimonio;
  final String? descricaoPatrimonio;
  final String statusPatrimonio;
  final int deletadoPatrimonio;
  final int? setorOrigemId;
  final String? nfePatrimonio;
  final String? lotePatrimonio;
  final String? dataEntrada; // Atenção: este campo em si é string, mas no JSON pode ser 'dataentrada_patrimonio'
  final int idModelo;
  final int idMarca;
  final int idFornecedor;
  final int idSetorAtual;

  // Objetos aninhados que podem vir com os detalhes do patrimônio da API
  final Modelo? modelo;
  final Marca? marca;
  final Fornecedor? fornecedor;
  final Setor? setorOrigem;
  final Setor? setorAtual;

  Patrimonio({
    this.idPatrimonio,
    this.codigoPatrimonio,
    this.imagemPatrimonio,
    required this.tipoPatrimonio,
    this.descricaoPatrimonio,
    this.statusPatrimonio = 'Alocado',
    this.deletadoPatrimonio = 0,
    required this.setorOrigemId,
    this.nfePatrimonio,
    this.lotePatrimonio,
    this.dataEntrada,
    required this.idModelo,
    required this.idMarca,
    required this.idFornecedor,
    required this.idSetorAtual,
    this.modelo,
    this.marca,
    this.fornecedor,
    this.setorOrigem,
    this.setorAtual,
  });

  static String? _stringOrNull(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }
    return value.toString();
  }

  factory Patrimonio.fromJson(Map<String, dynamic> json) {
    return Patrimonio(
      idPatrimonio: json['id_patrimonio'] != null ? int.tryParse(json['id_patrimonio'].toString()) : null,
      codigoPatrimonio: _stringOrNull(json['codigo_patrimonio']),
      imagemPatrimonio: _stringOrNull(json['imagem_patrimonio']),
      tipoPatrimonio: json['tipo_patrimonio'],
      descricaoPatrimonio: _stringOrNull(json['descricao_patrimonio']),
      statusPatrimonio: _stringOrNull(json['status_patrimonio']) ?? 'Alocado',
      deletadoPatrimonio: json['deletado_patrimonio'] != null ? int.tryParse(json['deletado_patrimonio'].toString()) ?? 0 : 0,
      setorOrigemId: json['setor_origem_id'] != null ? int.tryParse(json['setor_origem_id'].toString()) : null,
      nfePatrimonio: _stringOrNull(json['nfe_patrimonio']),
      lotePatrimonio: _stringOrNull(json['lote_patrimonio']),
      dataEntrada: _stringOrNull(json['dataentrada_patrimonio']), // O campo da API é 'dataentrada_patrimonio'
      idModelo: json['id_modelo'] != null ? int.tryParse(json['id_modelo'].toString()) ?? 0 : 0,
      idMarca: json['id_marca'] != null ? int.tryParse(json['id_marca'].toString()) ?? 0 : 0,
      idFornecedor: json['id_fornecedor'] != null ? int.tryParse(json['id_fornecedor'].toString()) ?? 0 : 0,
      idSetorAtual: json['id_setorAtual'] != null ? int.tryParse(json['id_setorAtual'].toString()) ?? 0 : 0, // O campo da API é 'id_setorAtual'

      modelo: json['modelo'] != null && json['modelo'] is Map ? Modelo.fromJson(json['modelo'] as Map<String, dynamic>) : null,
      marca: json['marca'] != null && json['marca'] is Map ? Marca.fromJson(json['marca'] as Map<String, dynamic>) : null,
      fornecedor: json['fornecedor'] != null && json['fornecedor'] is Map ? Fornecedor.fromJson(json['fornecedor'] as Map<String, dynamic>) : null,
      setorOrigem: json['setor_origem'] != null && json['setor_origem'] is Map ? Setor.fromJson(json['setor_origem'] as Map<String, dynamic>) : null,
      setorAtual: json['setor_atual'] != null && json['setor_atual'] is Map ? Setor.fromJson(json['setor_atual'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_patrimonio': idPatrimonio,
      'codigo_patrimonio': codigoPatrimonio,
      'imagem_patrimonio': imagemPatrimonio,
      'tipo_patrimonio': tipoPatrimonio,
      'descricao_patrimonio': descricaoPatrimonio,
      'status_patrimonio': statusPatrimonio,
      'deletado_patrimonio': deletadoPatrimonio,
      'setor_origem_id': setorOrigemId,
      'nfe_patrimonio': nfePatrimonio,
      'lote_patrimonio': lotePatrimonio,
      'dataentrada_patrimonio': dataEntrada, // O campo da API é 'dataentrada_patrimonio'
      'id_modelo': idModelo,
      'id_marca': idMarca,
      'id_fornecedor': idFornecedor,
      'id_setorAtual': idSetorAtual, // O campo da API é 'id_setorAtual'
    };
  }

  @override
  List<Object?> get props => [
        idPatrimonio,
        codigoPatrimonio,
        imagemPatrimonio,
        tipoPatrimonio,
        descricaoPatrimonio,
        statusPatrimonio,
        deletadoPatrimonio,
        setorOrigemId,
        nfePatrimonio,
        lotePatrimonio,
        dataEntrada,
        idModelo,
        idMarca,
        idFornecedor,
        idSetorAtual,
      ];
}