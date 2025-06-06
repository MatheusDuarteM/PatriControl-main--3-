import 'package:intl/intl.dart';
import 'package:patricontrol/model/setor.dart'; // Assumindo que você tem este arquivo
// Importe seu model de Patrimonio aqui se precisar de mais detalhes do que IDs
// import 'package:patricontrol/model/patrimonio.dart';

class Movimentacao {
  final int id;
  final int patrimonioId;
  final String patrimonioCodigo;
  final String patrimonioDescricao;
  final Setor? origemSetor; // Setor de origem (pode ser nulo para 'ENTRADA')
  final Setor? destinoSetor; // Setor de destino (pode ser nulo para 'DESCARTE')
  final DateTime dataMovimentacao;
  final String
  tipoMovimentacao; // Ex: "TRANSFERENCIA", "EMPRESTIMO", "DESCARTE", "ENTRADA"
  final String usuarioNome; // Nome do usuário que realizou a movimentação
  final String? observacao; // Descrição/observação da movimentação

  Movimentacao({
    required this.id,
    required this.patrimonioId,
    required this.patrimonioCodigo,
    required this.patrimonioDescricao,
    this.origemSetor,
    this.destinoSetor,
    required this.dataMovimentacao,
    required this.tipoMovimentacao,
    required this.usuarioNome,
    this.observacao,
  });

  factory Movimentacao.fromJson(Map<String, dynamic> json) {
    return Movimentacao(
      id: json['id'] as int,
      patrimonioId: json['patrimonio_id'] as int,
      patrimonioCodigo: json['patrimonio_codigo'] as String,
      patrimonioDescricao: json['patrimonio_descricao'] as String,
      origemSetor:
          json['origem_setor'] != null
              ? Setor.fromJson(json['origem_setor'] as Map<String, dynamic>)
              : null,
      destinoSetor:
          json['destino_setor'] != null
              ? Setor.fromJson(json['destino_setor'] as Map<String, dynamic>)
              : null,
      dataMovimentacao: DateTime.parse(json['data_movimentacao'] as String),
      tipoMovimentacao: json['tipo_movimentacao'] as String,
      usuarioNome: json['usuario_nome'] as String,
      observacao: json['observacao'] as String?,
    );
  }

  // Para enviar ao backend ao cadastrar uma nova movimentação
  Map<String, dynamic> toJsonForCreation() {
    return {
      'patrimonio_id': patrimonioId,
      'origem_setor_id':
          origemSetor?.id, // Enviar ID do setor de origem, se houver
      'destino_setor_id':
          destinoSetor?.id, // Enviar ID do setor de destino, se houver
      'data_movimentacao': DateFormat(
        "yyyy-MM-ddTHH:mm:ss",
      ).format(dataMovimentacao),
      'tipo_movimentacao': tipoMovimentacao,
      'observacao': observacao,
      // O backend deve inferir o usuário logado e outros detalhes do patrimônio pelo patrimonio_id
    };
  }
}

// Model auxiliar para a busca de patrimônio na tela de cadastro de movimentação
// Isso evita carregar o objeto Patrimonio completo se ele for muito pesado.
// Se seu model Patrimonio já for leve e tiver esses campos, pode usá-lo diretamente.
class PatrimonioParaSelecao {
  final int id;
  final String codigo;
  final String descricao;
  final String? marca; // Opcional, para exibir no card
  final String? modelo; // Opcional
  final String? status; // Opcional
  final String? imagemUrl; // Opcional
  final Setor?
  setorAtual; // Importante para saber a origem em transferências/empréstimos

  PatrimonioParaSelecao({
    required this.id,
    required this.codigo,
    required this.descricao,
    this.marca,
    this.modelo,
    this.status,
    this.imagemUrl,
    this.setorAtual,
  });

  factory PatrimonioParaSelecao.fromJson(Map<String, dynamic> json) {
    return PatrimonioParaSelecao(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      descricao: json['descricao'] as String, // ou 'nome' dependendo da sua API
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      status: json['status'] as String?,
      imagemUrl: json['imagem_url'] as String?,
      setorAtual:
          json['setor_atual'] != null
              ? Setor.fromJson(json['setor_atual'] as Map<String, dynamic>)
              : null,
    );
  }
}
