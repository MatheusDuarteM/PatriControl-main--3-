import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patricontrol/model/movimentacao.dart';
import 'package:patricontrol/model/setor.dart'; // Seu model Setor
import 'package:patricontrol/services/movimentacao_service.dart';
// Importe seu SetorService/Controller se for usá-lo para buscar setores
import 'package:patricontrol/services/setor_service.dart';
import 'package:patricontrol/controller/setor_controller.dart';

class MovimentacaoController extends ChangeNotifier {
  final MovimentacaoService _movimentacaoService = MovimentacaoService();
  // Se você tiver um SetorService/Controller, injete-o aqui
  final SetorService _setorService = SetorService();

  List<Movimentacao> _movimentacoes = [];
  List<Movimentacao> get movimentacoes => _movimentacoes;

  List<Setor> _setoresDisponiveis = []; // Para dropdowns
  List<Setor> get setoresDisponiveis => _setoresDisponiveis;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Estado para Cadastro de Movimentação ---
  PatrimonioParaSelecao? _patrimonioSelecionado;
  PatrimonioParaSelecao? get patrimonioSelecionado => _patrimonioSelecionado;

  final TextEditingController cadastroObservacaoController =
      TextEditingController();
  DateTime _cadastroDataMovimentacao = DateTime.now();
  DateTime get cadastroDataMovimentacao => _cadastroDataMovimentacao;

  Setor? _cadastroSetorDestino;
  Setor? get cadastroSetorDestino => _cadastroSetorDestino;

  // "ENTRADA", "TRANSFERENCIA", "EMPRESTIMO", "DESCARTE"
  String? _cadastroTipoMovimentacao;
  String? get cadastroTipoMovimentacao => _cadastroTipoMovimentacao;

  final List<String> tiposDeMovimentacao = const [
    "ENTRADA",
    "TRANSFERENCIA",
    "EMPRESTIMO",
    "DESCARTE",
  ];

  // --- Estado para Filtros da Lista ---
  final TextEditingController filtroRapidoController =
      TextEditingController(); // Para "Digite o nome ou código do patrimônio"
  DateTime? _filtroDataInicio;
  DateTime? get filtroDataInicio => _filtroDataInicio;
  DateTime? _filtroDataFim;
  DateTime? get filtroDataFim => _filtroDataFim;
  Setor? _filtroOrigemSetor;
  Setor? get filtroOrigemSetor => _filtroOrigemSetor;
  Setor? _filtroDestinoSetor;
  Setor? get filtroDestinoSetor => _filtroDestinoSetor;
  String? _filtroTipoMovimentacao;
  String? get filtroTipoMovimentacao => _filtroTipoMovimentacao;
  String? _filtroUsuarioNome;
  String? get filtroUsuarioNome => _filtroUsuarioNome;

  MovimentacaoController() {
    // Carrega os setores disponíveis ao iniciar o controller
    // Idealmente, isso viria do seu SetorController/Service
    _fetchSetoresDisponiveis(0);
    fetchMovimentacoes(); // Carrega a lista inicial
  }

  void _setStateLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearErrorMessage() {
    _errorMessage = null;
  }

  // Usar seu SetorService/Controller aqui se possível
  Future<void> _fetchSetoresDisponiveis(dynamic response) async {
    try {
      // Esta é uma simulação. Substitua pela chamada real ao seu serviço de setor.
      // Ex: _setoresDisponiveis = await _setorService.listarSetoresAtivos();
      // Por agora, vamos simular que o backend de movimentação também pode fornecer isso
      // ou que você tem um endpoint específico. Se não, você precisará implementar
      // a lógica para buscar de onde seus setores vêm.
      // final response = await http.get(Uri.parse('${_movimentacaoService._baseUrl}/setores'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        _setoresDisponiveis = data.map((s) => Setor.fromJson(s)).toList();
      }
      // Exemplo MOCK - SUBSTITUA PELA SUA LÓGICA REAL DE BUSCAR SETORES
    } catch (e) {
      print("Erro ao buscar setores disponíveis: $e");
      // Tratar erro como preferir
    }
  }

  Future<void> fetchMovimentacoes() async {
    _setStateLoading(true);
    _clearErrorMessage();

    Map<String, String?> filtros = {
      'patrimonio_query':
          filtroRapidoController.text
              .trim(), // Backend decide se busca por código ou nome/descrição
      'data_inicio':
          _filtroDataInicio != null
              ? DateFormat('yyyy-MM-dd').format(_filtroDataInicio!)
              : null,
      'data_fim':
          _filtroDataFim != null
              ? DateFormat('yyyy-MM-dd').format(_filtroDataFim!)
              : null,
      'origem_setor_id': _filtroOrigemSetor?.id.toString(),
      'destino_setor_id': _filtroDestinoSetor?.id.toString(),
      'tipo_movimentacao': _filtroTipoMovimentacao,
      'usuario_nome': _filtroUsuarioNome, // Para o filtro "Usuário"
    };

    try {
      final response = await _movimentacaoService.listarMovimentacoes(filtros);
      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> movimentacoesJson = response['data'] as List;
        _movimentacoes =
            movimentacoesJson
                .map(
                  (json) => Movimentacao.fromJson(json as Map<String, dynamic>),
                )
                .toList();
      } else {
        _errorMessage =
            response['message'] ?? 'Erro ao carregar movimentações.';
        _movimentacoes = [];
      }
    } catch (e) {
      _errorMessage = 'Exceção ao carregar movimentações: $e';
      _movimentacoes = [];
    }
    _setStateLoading(false);
  }

  // Métodos para o formulário de cadastro
  void selecionarPatrimonio(PatrimonioParaSelecao patrimonio) {
    _patrimonioSelecionado = patrimonio;
    // Se o tipo de movimentação já estiver selecionado e for "ENTRADA",
    // o setor de origem é nulo. Caso contrário, pode ser o setor atual do patrimônio.
    // A lógica de origem/destino pode ser mais complexa dependendo do tipo.
    notifyListeners();
  }

  void limparSelecaoPatrimonio() {
    _patrimonioSelecionado = null;
    notifyListeners();
  }

  void setCadastroDataMovimentacao(DateTime data) {
    _cadastroDataMovimentacao = data;
    notifyListeners();
  }

  void setCadastroSetorDestino(Setor? setor) {
    _cadastroSetorDestino = setor;
    notifyListeners();
  }

  void setCadastroTipoMovimentacao(String? tipo) {
    _cadastroTipoMovimentacao = tipo;
    notifyListeners();
  }

  void limparFormularioCadastro() {
    _patrimonioSelecionado = null;
    cadastroObservacaoController.clear();
    _cadastroDataMovimentacao = DateTime.now();
    _cadastroSetorDestino = null;
    _cadastroTipoMovimentacao = null;
    notifyListeners();
  }

  Future<bool> submeterCadastroMovimentacao(BuildContext context) async {
    if (_patrimonioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um patrimônio.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (_cadastroTipoMovimentacao == null ||
        _cadastroTipoMovimentacao!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o tipo de movimentação.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    // DESCARTE não exige setor de destino
    if (_cadastroSetorDestino == null &&
        _cadastroTipoMovimentacao != "DESCARTE") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o setor de destino.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    _setStateLoading(true);
    _clearErrorMessage();

    Setor? origemSetor;
    // Para 'ENTRADA', origemSetor é nulo.
    // Para 'TRANSFERENCIA', 'EMPRESTIMO', 'DESCARTE', origemSetor é o setor atual do patrimônio.
    if (_cadastroTipoMovimentacao != 'ENTRADA') {
      origemSetor = _patrimonioSelecionado!.setorAtual;
      // Validação adicional: Se for transferência ou empréstimo, o patrimônio DEVE ter um setor de origem
      if (origemSetor == null &&
          (_cadastroTipoMovimentacao == 'TRANSFERENCIA' ||
              _cadastroTipoMovimentacao == 'EMPRESTIMO')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Patrimônio selecionado não possui setor de origem para este tipo de movimentação.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        _setStateLoading(false);
        return false;
      }
    }

    final movimentacaoParaCriar = Movimentacao(
      id: 0, // ID será gerado pelo backend
      patrimonioId: _patrimonioSelecionado!.id,
      patrimonioCodigo:
          _patrimonioSelecionado!.codigo, // O backend pode buscar isso pelo ID
      patrimonioDescricao:
          _patrimonioSelecionado!
              .descricao, // O backend pode buscar isso pelo ID
      origemSetor: origemSetor,
      destinoSetor:
          _cadastroTipoMovimentacao == "DESCARTE"
              ? null
              : _cadastroSetorDestino,
      dataMovimentacao: _cadastroDataMovimentacao,
      tipoMovimentacao: _cadastroTipoMovimentacao!,
      observacao: cadastroObservacaoController.text.trim(),
      usuarioNome: '', // O backend deve preencher com o usuário logado
    );

    try {
      final response = await _movimentacaoService.cadastrarMovimentacao(
        movimentacaoParaCriar.toJsonForCreation(),
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Movimentação cadastrada com sucesso!',
            ),
          ),
        );
        limparFormularioCadastro();
        fetchMovimentacoes(); // Atualiza a lista
        _setStateLoading(false);
        return true;
      } else {
        _errorMessage =
            response['message'] ?? 'Erro ao cadastrar movimentação.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      _errorMessage = 'Exceção ao cadastrar: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _setStateLoading(false);
    return false;
  }

  // Métodos para os filtros avançados
  void setFiltroDataInicio(DateTime? data) {
    _filtroDataInicio = data;
    notifyListeners();
  }

  void setFiltroDataFim(DateTime? data) {
    _filtroDataFim = data;
    notifyListeners();
  }

  void setFiltroOrigemSetor(Setor? setor) {
    _filtroOrigemSetor = setor;
    notifyListeners();
  }

  void setFiltroDestinoSetor(Setor? setor) {
    _filtroDestinoSetor = setor;
    notifyListeners();
  }

  void setFiltroTipoMovimentacao(String? tipo) {
    _filtroTipoMovimentacao = tipo;
    notifyListeners();
  }

  void setFiltroUsuarioNome(String? nome) {
    _filtroUsuarioNome = nome;
    notifyListeners();
  }

  void aplicarFiltrosAvancados() {
    fetchMovimentacoes(); // Recarrega a lista com os filtros aplicados
  }

  void limparFiltrosAvancados() {
    filtroRapidoController.clear(); // Também limpa o filtro rápido
    _filtroDataInicio = null;
    _filtroDataFim = null;
    _filtroOrigemSetor = null;
    _filtroDestinoSetor = null;
    _filtroTipoMovimentacao = null;
    _filtroUsuarioNome = null;
    fetchMovimentacoes(); // Recarrega a lista sem filtros
    notifyListeners(); // Para atualizar a UI dos filtros se estiverem visíveis
  }
}
