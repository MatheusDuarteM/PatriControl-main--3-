// lib/providers/patrimonio_list_provider.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patricontrol/controller/patrimonio_controller.dart';
import 'package:patricontrol/utils/Enums/tipoPatrimonio.dart';
import 'dart:typed_data';

// Importe seus modelos e serviços. Certifique-se de que os caminhos estão corretos.
import '../model/patrimonio.dart';
import '../services/patrimonio_service.dart';
import '../model/modelo.dart';
import '../services/modelo_service.dart';
import '../model/marca.dart';
import '../services/marca_service.dart';
import '../model/fornecedor.dart';
import '../services/fornecedor_service.dart';
import '../model/setor.dart';
import '../services/setor_service.dart';
// Certifique-se de que o StatusPatrimonio está sendo importado se for usado
// import '../utils/Enums/statusPatrimonio.dart';


class PatrimonioListProvider extends ChangeNotifier {
  // Serviços
  final PatrimonioService _patrimonioService = PatrimonioService();
  final ModeloService _modeloService = ModeloService();
  final MarcaService _marcaService = MarcaService();
  final FornecedorService _fornecedorService = FornecedorService();
  final SetorService _setorService = SetorService();

  // Controller gerenciado por este provider
  late PatrimonioController _patrimonioController;

  // Listas de dados para dropdowns
  List<Modelo> _modelosDisponiveis = [];
  List<Marca> _marcasDisponiveis = [];
  List<Fornecedor> _fornecedoresDisponiveis = [];
  List<Setor> _setoresDisponiveis = [];

  // Estados do provider
  bool _isLoading = false; // Este é o loading GERAL da página
  String? _error;

  // Getters para os dados e estados
  PatrimonioController get patrimonioController => _patrimonioController;
  List<Modelo> get modelosDisponiveis => _modelosDisponiveis;
  List<Marca> get marcasDisponiveis => _marcasDisponiveis;
  List<Fornecedor> get fornecedoresDisponiveis => _fornecedoresDisponiveis;
  List<Setor> get setoresDisponiveis => _setoresDisponiveis;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorMessage => _error; // Alias para consistência, se preferir

  PatrimonioListProvider() {
    // Instancia o controller passando o serviço necessário
    _patrimonioController = PatrimonioController(patrimonioService: _patrimonioService);
    // Adiciona o listener para o controller
    _patrimonioController.addListener(_onPatrimonioControllerChange);
  }

  // Método que será chamado quando o PatrimonioController notificar mudanças
  void _onPatrimonioControllerChange() {
    // Quando o PatrimonioController notifica (ex: a lista filtrada mudou),
    // este provider também notifica seus próprios ouvintes (o Consumer na UI).
    // Isso garante que a UI que está ouvindo o PatrimonioListProvider seja reconstruída.
    notifyListeners();
  }

  @override
  void dispose() {
    // É crucial remover o listener e descartar o controller para evitar vazamentos de memória.
    _patrimonioController.removeListener(_onPatrimonioControllerChange);
    _patrimonioController.dispose();
    super.dispose();
  }

  // Método de inicialização para carregar todos os dados necessários
  Future<void> init() async {
    print('PatrimonioListProvider.init() chamado. Carregando todos os dados.');
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notifica que o loading geral começou

    try {
      // Carrega os dados principais do patrimônio (delegando ao controller)
      // O controller já tem seu próprio notifyListeners para loading interno
      await _patrimonioController.buscarPatrimonios(mostrarLoading: false);
      // Propaga o erro do controller para o estado de erro geral do provider, se houver.
      _error = _patrimonioController.erroGeral;

      // Carrega as listas para os dropdowns (modelos, marcas, fornecedores, setores) em paralelo.
      await Future.wait([
        _carregarModelosDisponiveis(),
        _carregarMarcasDisponiveis(),
        _carregarFornecedoresDisponiveis(),
        _carregarSetoresDisponiveis(),
      ]);
    } catch (e) {
      _error = 'Erro geral na inicialização do provider: $e';
      print('Erro geral na inicialização do PatrimonioListProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica que o loading geral terminou
    }
  }

  // Métodos privados para carregar dados dos dropdowns (mantidos como estão, com tratamento de erro e propagação)
  Future<void> _carregarModelosDisponiveis() async {
    try {
      final response = await _modeloService.listarModelos(deletado: 0);
      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> listaJson = (response['data'] as Map<String, dynamic>)['modelos'] ?? [];
        _modelosDisponiveis = listaJson.map((data) => Modelo.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        _error = _error != null ? '$_error\nErro ao carregar modelos: ${response['message'] ?? 'Desconhecido'}' : 'Erro ao carregar modelos: ${response['message'] ?? 'Desconhecido'}';
      }
    } catch (e) {
      _error = _error != null ? '$_error\nErro de conexão ao carregar modelos: $e' : 'Erro de conexão ao carregar modelos: $e';
    }
  }

  Future<void> _carregarMarcasDisponiveis() async {
    try {
      final response = await _marcaService.listarMarcas(deletado: 0);
      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> listaJson = (response['data'] as Map<String, dynamic>)['marcas'] ?? [];
        _marcasDisponiveis = listaJson.map((data) => Marca.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        _error = _error != null ? '$_error\nErro ao carregar marcas: ${response['message'] ?? 'Desconhecido'}' : 'Erro ao carregar marcas: ${response['message'] ?? 'Desconhecido'}';
      }
    } catch (e) {
      _error = _error != null ? '$_error\nErro de conexão ao carregar marcas: $e' : 'Erro de conexão ao carregar marcas: $e';
    }
  }

  Future<void> _carregarFornecedoresDisponiveis() async {
    try {
      final response = await _fornecedorService.listarFornecedores(0);
      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> listaJson = (response['data'] as Map<String, dynamic>)['fornecedores'] ?? [];
        _fornecedoresDisponiveis = listaJson.map((data) => Fornecedor.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        _error = _error != null ? '$_error\nErro ao carregar fornecedores: ${response['message'] ?? 'Desconhecido'}' : 'Erro ao carregar fornecedores: ${response['message'] ?? 'Desconhecido'}';
      }
    } catch (e) {
      _error = _error != null ? '$_error\nErro de conexão ao carregar fornecedores: $e' : 'Erro de conexão ao carregar fornecedores: $e';
    }
  }

  Future<void> _carregarSetoresDisponiveis() async {
    try {
      final response = await _setorService.listarSetor(deletado: 0);
      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> listaJson = (response['data'] as Map<String, dynamic>)['setores'] ?? [];
        _setoresDisponiveis = listaJson.map((data) => Setor.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        _error = _error != null ? '$_error\nErro ao carregar setores: ${response['message'] ?? 'Desconhecido'}' : 'Erro ao carregar setores: ${response['message'] ?? 'Desconhecido'}';
      }
    } catch (e) {
      _error = _error != null ? '$_error\nErro de conexão ao carregar setores: $e' : 'Erro de conexão ao carregar setores: $e';
    }
  }

  // --- Métodos de delegação para o PatrimonioController ---

  Future<void> buscarPatrimonios({bool mostrarLoading = true, int deletado = 0}) async {
    await _patrimonioController.buscarPatrimonios(mostrarLoading: mostrarLoading, deletado: deletado);
    _error = _patrimonioController.erroGeral;
    notifyListeners();
  }

  // REMOVIDO: O método filtrarPatrimoniosLocalmente do PatrimonioListProvider
  // Ele não existe mais no PatrimonioController e a filtragem é feita na ListaPatrimonioPage.
  /*
  void filtrarPatrimoniosLocalmente(String texto) {
    _patrimonioController.filtrarPatrimoniosLocalmente(texto);
  }
  */

  Future<bool> cadastrarPatrimonio(BuildContext context) async {
    bool success = await _patrimonioController.cadastrarPatrimonio(context);
    if (success) {
      await init();
    }
    _error = _patrimonioController.erroGeral;
    return success;
  }

  Future<bool> editarPatrimonio(BuildContext context) async {
    bool success = await _patrimonioController.editarPatrimonio(context);
    if (success) {
      await init();
    }
    _error = _patrimonioController.erroGeral;
    return success;
  }

  Future<bool> inativarPatrimonio(BuildContext context, int idPatrimonio) async {
    bool success = await _patrimonioController.inativarPatrimonio(context, idPatrimonio);
    if (success) {
      await buscarPatrimonios(mostrarLoading: false);
    }
    _error = _patrimonioController.erroGeral;
    return success;
  }

  void limparCampos() {
    _patrimonioController.limparCampos();
    _error = null;
  }

  Future<void> carregarDadosParaEdicao(Patrimonio patrimonio) async {
    await _patrimonioController.carregarDadosParaEdicao(patrimonio);
    _error = _patrimonioController.erroGeral;
  }

  void reverterDadosEdicao() {
    _patrimonioController.reverterDadosEdicao();
    _error = null;
  }

  void setSelectedModelo(Modelo? modelo) {
    _patrimonioController.setSelectedModelo(modelo);
  }

  void setSelectedMarca(Marca? marca) {
    _patrimonioController.setSelectedMarca(marca);
  }

  void setSelectedFornecedor(Fornecedor? fornecedor) {
    _patrimonioController.setSelectedFornecedor(fornecedor);
  }

  void setSelectedSetorOrigem(Setor? setor) {
    _patrimonioController.setSelectedSetorOrigem(setor);
  }

  void setSelectedSetorAtual(Setor? setor) {
    _patrimonioController.setSelectedSetorAtual(setor);
  }

  void setSelectedTipoPatrimonio(TipoPatrimonio? tipo) {
    _patrimonioController.setSelectedTipoPatrimonio(tipo);
  }

  void setImagemSelecionada(Uint8List? bytes, String? nomeArquivo) {
    _patrimonioController.setImagemSelecionada(bytes, nomeArquivo);
  }

  Future<void> pickImageFromGallery() async {
    await _patrimonioController.pickImage(source: ImageSource.gallery);
    _error = _patrimonioController.erroGeral; // Propaga qualquer erro do controller
    notifyListeners(); // Notifica a UI que o estado pode ter mudado
  }

  // NOVO: Método para acionar a seleção de imagem da câmera no controller
  Future<void> pickImageFromCamera() async {
    await _patrimonioController.pickImage(source: ImageSource.camera);
    _error = _patrimonioController.erroGeral; // Propaga qualquer erro do controller
    notifyListeners(); // Notifica a UI que o estado pode ter mudado
  }
}