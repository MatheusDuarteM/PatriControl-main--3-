import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart'; // Para firstWhereOrNull
import 'package:intl/intl.dart';
import 'package:patricontrol/utils/Enums/tipoPatrimonio.dart';

// Importe seus modelos e serviços. Certifique-se de que os caminhos estão corretos.
import '../model/patrimonio.dart';
import '../model/modelo.dart';
import '../model/marca.dart';
import '../model/fornecedor.dart';
import '../model/setor.dart';
import '../services/patrimonio_service.dart';

class PatrimonioController extends ChangeNotifier {
  final PatrimonioService _patrimonioService;

  // --- State for Form (Text Editing Controllers) ---
  final TextEditingController codigoPatrimonioController = TextEditingController();
  final TextEditingController descricaoPatrimonioController = TextEditingController();
  final TextEditingController nfePatrimonioController = TextEditingController();
  final TextEditingController lotePatrimonioController = TextEditingController();
  final TextEditingController dataEntradaController = TextEditingController();

  final TextEditingController corModeloController = TextEditingController();
  final TextEditingController descricaoModeloPatrimonioController = TextEditingController();

  // --- State for Form (Dropdown Selections) ---
  Modelo? _selectedModelo;
  Marca? _selectedMarca;
  Fornecedor? _selectedFornecedor;
  Setor? _selectedSetorOrigem;
  Setor? _selectedSetorAtual;
  TipoPatrimonio? _selectedTipoPatrimonio;

  // --- State for Form (Image Handling) ---
  Uint8List? _imagemSelecionadaBytes;
  String? _nomeArquivoImagemSelecionada;
  String? _imagemModeloUrl;
  bool _editandoImagemFoiAlterada = false;
  Patrimonio? _patrimonioEmEdicao;
  Uint8List? _bytesImagemOriginalCarregada;
  bool _isImageLoading = false;

  // --- State for List/Loading/Error ---
  bool _isLoading = false;
  String? _erroGeral;
  List<Patrimonio> _todosOsPatrimonios = []; // Lista original completa carregada da API
  List<Patrimonio> _listaDePatrimoniosFiltrada = []; // A lista que será exibida na UI, após filtros
  // String _textoPesquisaAtual = ''; // Este será gerenciado pela ListaPatrimonioPage agora
  int _totalPatrimoniosApi = 0;

  // --- Getters ---
  Uint8List? get imagemSelecionadaBytes => _imagemSelecionadaBytes;
  String? get nomeArquivoImagemSelecionada => _nomeArquivoImagemSelecionada;
  bool get isLoading => _isLoading;

  // MODIFICADO: Este getter agora retorna a lista que *deve ser exibida*, que é manipulada externamente
  List<Patrimonio> get listaDePatrimoniosExibida => _listaDePatrimoniosFiltrada;

  String? get erroGeral => _erroGeral;
  // String get textoPesquisaAtual => _textoPesquisaAtual; // Removido, gerenciado pela UI
  bool get editandoImagemFoiAlterada => _editandoImagemFoiAlterada;
  Patrimonio? get patrimonioEmEdicao => _patrimonioEmEdicao;
  bool get isImageLoading => _isImageLoading;
  String? get imagemModeloUrl => _imagemModeloUrl;


  Modelo? get selectedModelo => _selectedModelo;
  Marca? get selectedMarca => _selectedMarca;
  Fornecedor? get selectedFornecedor => _selectedFornecedor;
  Setor? get selectedSetorOrigem => _selectedSetorOrigem;
  Setor? get selectedSetorAtual => _selectedSetorAtual;
  TipoPatrimonio? get selectedTipoPatrimonio => _selectedTipoPatrimonio;

  // NOVO GETTER: Para a ListaPatrimonioPage acessar a lista original completa
  List<Patrimonio> get todosOsPatrimonios => _todosOsPatrimonios;


  PatrimonioController({PatrimonioService? patrimonioService})
      : _patrimonioService = patrimonioService ?? PatrimonioService();

  @override
  void dispose() {
    codigoPatrimonioController.dispose();
    descricaoPatrimonioController.dispose();
    nfePatrimonioController.dispose();
    lotePatrimonioController.dispose();
    dataEntradaController.dispose();
    corModeloController.dispose();
    descricaoModeloPatrimonioController.dispose();
    super.dispose();
  }

  // --- Form/Image Handling Setters ---

  void setSelectedModelo(Modelo? modelo) {
    _selectedModelo = modelo;
    if (modelo != null) {
      corModeloController.text = modelo.corModelo ?? '';
      descricaoModeloPatrimonioController.text = modelo.descricaoModelo ?? '';

      if (_patrimonioEmEdicao == null || !_editandoImagemFoiAlterada) {
        _imagemModeloUrl = modelo.imagemUrl;
        _imagemSelecionadaBytes = null;
        _nomeArquivoImagemSelecionada = null;
      }
    } else {
      corModeloController.clear();
      descricaoModeloPatrimonioController.clear();
      _imagemModeloUrl = null;

      if (!_editandoImagemFoiAlterada) {
        _imagemSelecionadaBytes = null;
        _nomeArquivoImagemSelecionada = null;
      }
    }
    notifyListeners();
  }

  void setSelectedMarca(Marca? marca) {
    _selectedMarca = marca;
    notifyListeners();
  }

  void setSelectedFornecedor(Fornecedor? fornecedor) {
    _selectedFornecedor = fornecedor;
    notifyListeners();
  }

  void setSelectedSetorOrigem(Setor? setor) {
    _selectedSetorOrigem = setor;
    notifyListeners();
  }

  void setSelectedSetorAtual(Setor? setor) {
    _selectedSetorAtual = setor;
    notifyListeners();
  }

  void setSelectedTipoPatrimonio(TipoPatrimonio? tipo) {
    _selectedTipoPatrimonio = tipo;
    notifyListeners();
  }

  void setImagemSelecionada(Uint8List? bytes, String? nomeArquivo) {
    _imagemSelecionadaBytes = bytes;
    _nomeArquivoImagemSelecionada = nomeArquivo;
    _imagemModeloUrl = null;
    _editandoImagemFoiAlterada = true;
    notifyListeners();
  }

  void _setImageLoading(bool value, {bool notify = true}) {
    _isImageLoading = value;
    if (notify) notifyListeners();
  }

  Future<void> pickImage({required ImageSource source}) async { // <-- Adicionado "required ImageSource source"
  _setErro(null);
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source); // <-- Agora usa o source passado

    if (image != null) {
      final bytes = await image.readAsBytes();
      setImagemSelecionada(bytes, image.name);
      notifyListeners();
    } else {
      debugPrint('Nenhuma imagem selecionada ou ação cancelada.'); // Mensagem mais genérica
    }
  } catch (e) {
    debugPrint('Erro ao selecionar imagem: $e');
    _setErro('Erro ao selecionar imagem: ${e.toString()}');
  }
}

  void removerImagem() {
    _imagemSelecionadaBytes = null;
    _nomeArquivoImagemSelecionada = null;
    _imagemModeloUrl = null;
    _editandoImagemFoiAlterada = true;
    notifyListeners();
  }

  void limparCampos() {
    codigoPatrimonioController.clear();
    descricaoPatrimonioController.clear();
    nfePatrimonioController.clear();
    lotePatrimonioController.clear();
    dataEntradaController.clear();
    corModeloController.clear();
    descricaoModeloPatrimonioController.clear();

    _selectedModelo = null;
    _selectedMarca = null;
    _selectedFornecedor = null;
    _selectedSetorOrigem = null;
    _selectedSetorAtual = null;
    _selectedTipoPatrimonio = null;

    _imagemSelecionadaBytes = null;
    _nomeArquivoImagemSelecionada = null;
    _imagemModeloUrl = null;
    _editandoImagemFoiAlterada = false;
    _patrimonioEmEdicao = null;
    _bytesImagemOriginalCarregada = null;
    _isImageLoading = false;
    _setErro(null);
    notifyListeners();
  }

  Future<void> carregarDadosParaEdicao(Patrimonio patrimonio) async {
    _patrimonioEmEdicao = patrimonio;
    codigoPatrimonioController.text = patrimonio.codigoPatrimonio ?? '';
    _selectedTipoPatrimonio = TipoPatrimonio.fromString(patrimonio.tipoPatrimonio);
    descricaoPatrimonioController.text = patrimonio.descricaoPatrimonio ?? '';
    nfePatrimonioController.text = patrimonio.nfePatrimonio ?? '';
    lotePatrimonioController.text = patrimonio.lotePatrimonio ?? '';

    if (patrimonio.dataEntrada != null && patrimonio.dataEntrada!.isNotEmpty) {
      try {
        final DateTime parsedDate = DateTime.parse(patrimonio.dataEntrada!);
        dataEntradaController.text = DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (e) {
        debugPrint('Erro ao parsear data de aquisição: ${patrimonio.dataEntrada} - $e');
        dataEntradaController.text = '';
      }
    } else {
      dataEntradaController.text = '';
    }

    _selectedModelo = patrimonio.modelo;
    _selectedMarca = patrimonio.marca;
    _selectedFornecedor = patrimonio.fornecedor;
    _selectedSetorOrigem = patrimonio.setorOrigem;
    _selectedSetorAtual = patrimonio.setorAtual;

    corModeloController.text = patrimonio.modelo?.corModelo ?? '';
    descricaoModeloPatrimonioController.text = patrimonio.modelo?.descricaoModelo ?? '';

    _imagemSelecionadaBytes = null;
    _nomeArquivoImagemSelecionada = null;
    _editandoImagemFoiAlterada = false;
    _bytesImagemOriginalCarregada = null;
    _imagemModeloUrl = null;
    _setErro(null);

    if (patrimonio.imagemPatrimonio != null && patrimonio.imagemPatrimonio!.isNotEmpty) {
      _setImageLoading(true);
      try {
        final response = await http.get(Uri.parse(patrimonio.imagemPatrimonio!));
        if (response.statusCode == 200) {
          _imagemSelecionadaBytes = response.bodyBytes;
          _bytesImagemOriginalCarregada = response.bodyBytes;
          _nomeArquivoImagemSelecionada = _extractFileNameFromUrl(patrimonio.imagemPatrimonio!);
          debugPrint('Imagem ${patrimonio.imagemPatrimonio} carregada com sucesso da URL.');
        } else {
          debugPrint('Falha ao carregar imagem da URL: ${response.statusCode}');
          _setErro('Não foi possível carregar a imagem existente. Status: ${response.statusCode}');
          _imagemSelecionadaBytes = null;
          _bytesImagemOriginalCarregada = null;
          _nomeArquivoImagemSelecionada = null;
        }
      } catch (e) {
        debugPrint('Erro ao baixar imagem da URL: $e');
        _setErro('Erro de conexão ao carregar imagem existente.');
        _imagemSelecionadaBytes = null;
        _bytesImagemOriginalCarregada = null;
        _nomeArquivoImagemSelecionada = null;
      } finally {
        _setImageLoading(false);
        notifyListeners();
      }
    } else {
      if (patrimonio.modelo?.imagemUrl != null && patrimonio.modelo!.imagemUrl!.isNotEmpty) {
        _imagemModeloUrl = patrimonio.modelo!.imagemUrl;
        _imagemSelecionadaBytes = null;
        _nomeArquivoImagemSelecionada = null;
      } else {
        _imagemSelecionadaBytes = null;
        _bytesImagemOriginalCarregada = null;
        _nomeArquivoImagemSelecionada = null;
        _imagemModeloUrl = null;
      }
    }
    notifyListeners();
  }

  String? _extractFileNameFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      String lastSegment = Uri.parse(url).pathSegments.lastWhere(
            (segment) => segment.isNotEmpty,
            orElse: () => '',
          );
      return Uri.decodeComponent(lastSegment);
    } catch (_) {
      return null;
    }
  }

  void reverterDadosEdicao() {
    if (_patrimonioEmEdicao != null) {
      codigoPatrimonioController.text = _patrimonioEmEdicao!.codigoPatrimonio ?? '';
      _selectedTipoPatrimonio = TipoPatrimonio.fromString(_patrimonioEmEdicao!.tipoPatrimonio);
      descricaoPatrimonioController.text = _patrimonioEmEdicao!.descricaoPatrimonio ?? '';
      nfePatrimonioController.text = _patrimonioEmEdicao!.nfePatrimonio ?? '';
      lotePatrimonioController.text = _patrimonioEmEdicao!.lotePatrimonio ?? '';

      if (_patrimonioEmEdicao!.dataEntrada != null && _patrimonioEmEdicao!.dataEntrada!.isNotEmpty) {
        try {
          final DateTime parsedDate = DateTime.parse(_patrimonioEmEdicao!.dataEntrada!);
          dataEntradaController.text = DateFormat('dd/MM/yyyy').format(parsedDate);
        } catch (e) {
          debugPrint('Erro ao parsear data de aquisição ao reverter: ${_patrimonioEmEdicao!.dataEntrada} - $e');
          dataEntradaController.text = '';
        }
      } else {
        dataEntradaController.text = '';
      }

      _selectedModelo = _patrimonioEmEdicao!.modelo;
      _selectedMarca = _patrimonioEmEdicao!.marca;
      _selectedFornecedor = _patrimonioEmEdicao!.fornecedor;
      _selectedSetorOrigem = _patrimonioEmEdicao!.setorOrigem;
      _selectedSetorAtual = _patrimonioEmEdicao!.setorAtual;

      corModeloController.text = _patrimonioEmEdicao!.modelo?.corModelo ?? '';
      descricaoModeloPatrimonioController.text = _patrimonioEmEdicao!.modelo?.descricaoModelo ?? '';

      _imagemSelecionadaBytes = _bytesImagemOriginalCarregada;
      _nomeArquivoImagemSelecionada = (_patrimonioEmEdicao?.imagemPatrimonio != null && _patrimonioEmEdicao!.imagemPatrimonio!.isNotEmpty)
          ? _extractFileNameFromUrl(_patrimonioEmEdicao!.imagemPatrimonio!)
          : null;

      if (_imagemSelecionadaBytes == null && _patrimonioEmEdicao!.modelo?.imagemUrl != null) {
        _imagemModeloUrl = _patrimonioEmEdicao!.modelo!.imagemUrl;
      } else {
        _imagemModeloUrl = null;
      }

      _editandoImagemFoiAlterada = false;
      _isImageLoading = false;
      _setErro(null);
      notifyListeners();
    }
  }

  // --- Loading State ---
  void setLoading(bool value, {bool notify = true}) {
    _isLoading = value;
    if (notify) notifyListeners();
  }

  void _setErro(String? message, {bool notify = true}) {
    _erroGeral = message;
    if (notify) notifyListeners();
  }

  String? _formatarDataParaAPI(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      final DateTime parsedDate = DateFormat('dd/MM/yyyy').parseStrict(data);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      debugPrint('Erro ao parsear data para API: $data - $e');
      return null;
    }
  }

  // --- API Operations ---

  Future<void> buscarPatrimonios({bool mostrarLoading = true, int deletado = 0}) async {
    if (mostrarLoading) setLoading(true, notify: _todosOsPatrimonios.isEmpty);
    _setErro(null, notify: false);

    try {
      final response = await _patrimonioService.listarPatrimonios(deletado: deletado);

      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> listaJson = (response['data'] is Map<String, dynamic> && response['data'].containsKey('data'))
            ? (response['data'] as Map<String, dynamic>)['data'] ?? []
            : response['data'] ?? [];

        _todosOsPatrimonios = listaJson
            .map((data) => Patrimonio.fromJson(data as Map<String, dynamic>))
            .toList();
        _listaDePatrimoniosFiltrada = [..._todosOsPatrimonios]; // Inicialmente, a lista filtrada é a completa
        _totalPatrimoniosApi = (response['data'] is Map<String, dynamic> && response['data'].containsKey('total'))
            ? (response['data'] as Map<String, dynamic>)['total'] ?? _todosOsPatrimonios.length
            : _todosOsPatrimonios.length;
      } else {
        final errorMessage = response['message'] ?? 'Erro desconhecido ao listar patrimônios.';
        _setErro('Falha ao carregar: $errorMessage');
        _todosOsPatrimonios = [];
        _listaDePatrimoniosFiltrada = [];
        _totalPatrimoniosApi = 0;
      }
    } catch (e) {
      debugPrint("Erro ao buscar patrimônios no controller: $e");
      _setErro("Falha na comunicação: ${e.toString()}");
      _todosOsPatrimonios = [];
      _listaDePatrimoniosFiltrada = [];
      _totalPatrimoniosApi = 0;
    } finally {
      setLoading(false);
    }
  }

  // REMOVIDO: O método filtrarPatrimoniosLocalmente e _aplicarFiltroInterno
  // porque a lógica de filtragem foi movida para a ListaPatrimonioPage.
  /*
  void filtrarPatrimoniosLocalmente(String texto) {
    _textoPesquisaAtual = texto.toLowerCase().trim();
    _aplicarFiltroInterno();
    notifyListeners();
  }

  void _aplicarFiltroInterno() {
    if (_textoPesquisaAtual.isEmpty) {
      _listaDePatrimoniosFiltrada = List.from(_todosOsPatrimonios);
    } else {
      _listaDePatrimoniosFiltrada = _todosOsPatrimonios.where((patrimonio) {
        final codigo = (patrimonio.codigoPatrimonio ?? '').toLowerCase();
        final tipo = patrimonio.tipoPatrimonio.toLowerCase();
        final descricao = (patrimonio.descricaoPatrimonio ?? '').toLowerCase();
        final nfe = (patrimonio.nfePatrimonio ?? '').toLowerCase();
        final lote = (patrimonio.lotePatrimonio ?? '').toLowerCase();
        final dataEntrada = (patrimonio.dataEntrada ?? '').toLowerCase();
        final status = (patrimonio.statusPatrimonio).toLowerCase();

        final modeloNome = (patrimonio.modelo?.nomeModelo ?? '').toLowerCase();
        final marcaNome = (patrimonio.marca?.nome_marca ?? '').toLowerCase();
        final fornecedorNome = (patrimonio.fornecedor?.nome_fornecedor ?? '').toLowerCase();
        final setorOrigemNome = (patrimonio.setorOrigem?.nome_setor ?? '').toLowerCase();
        final setorAtualNome = (patrimonio.setorAtual?.nome_setor ?? '').toLowerCase();

        final modeloCor = (patrimonio.modelo?.corModelo ?? '').toLowerCase();
        final modeloDescricao = (patrimonio.modelo?.descricaoModelo ?? '').toLowerCase();

        return codigo.contains(_textoPesquisaAtual) ||
            tipo.contains(_textoPesquisaAtual) ||
            descricao.contains(_textoPesquisaAtual) ||
            nfe.contains(_textoPesquisaAtual) ||
            lote.contains(_textoPesquisaAtual) ||
            dataEntrada.contains(_textoPesquisaAtual) ||
            status.contains(_textoPesquisaAtual) ||
            modeloNome.contains(_textoPesquisaAtual) ||
            marcaNome.contains(_textoPesquisaAtual) ||
            fornecedorNome.contains(_textoPesquisaAtual) ||
            setorOrigemNome.contains(_textoPesquisaAtual) ||
            setorAtualNome.contains(_textoPesquisaAtual) ||
            modeloCor.contains(_textoPesquisaAtual) ||
            modeloDescricao.contains(_textoPesquisaAtual);
      }).toList();
    }
  }
  */

  // NOVO MÉTODO: Para a ListaPatrimonioPage definir qual lista deve ser exibida
  void defineListaExibida(List<Patrimonio> lista) {
    _listaDePatrimoniosFiltrada = lista;
    notifyListeners(); // Notifica que a lista exibida mudou
  }


  Future<bool> cadastrarPatrimonio(BuildContext context) async {
    final codigo = codigoPatrimonioController.text.trim();
    final tipo = _selectedTipoPatrimonio?.displayValue;
    final descricao = descricaoPatrimonioController.text.trim();
    final nfe = nfePatrimonioController.text.trim();
    final lote = lotePatrimonioController.text.trim();
    final dataEntradaApi = _formatarDataParaAPI(dataEntradaController.text);

    if (codigo.isEmpty || tipo == null || tipo.isEmpty || _selectedModelo == null ||
        _selectedMarca == null || _selectedFornecedor == null || _selectedSetorOrigem == null) {
      _showErrorSnackbar(context, 'Todos os campos obrigatórios (Código, Tipo, Modelo, Marca, Fornecedor, Setor de Origem) devem ser preenchidos.');
      return false;
    }

    setLoading(true, notify: true);
    _setErro(null, notify: false);

    try {
      final responseValidation = await _patrimonioService.verificarCodigoPatrimonioExistente(codigo);
      if (responseValidation.containsKey('exists') && responseValidation['exists'] == true) {
        _showErrorSnackbar(context, 'Já existe um patrimônio com este código.');
        return false;
      } else if (responseValidation.containsKey('status') && responseValidation['status'] == 'error') {
        _showErrorSnackbar(context, 'Erro ao verificar código do patrimônio: ${responseValidation['message'] ?? 'Erro desconhecido'}');
        return false;
      }

      Uint8List? finalImagemBytes;
      String? finalNomeArquivo;
      String? finalImagemUrlParaBackend;

      if (_imagemSelecionadaBytes != null) {
        finalImagemBytes = _imagemSelecionadaBytes;
        finalNomeArquivo = _nomeArquivoImagemSelecionada;
      } else if (_selectedModelo?.imagemUrl != null && _selectedModelo!.imagemUrl!.isNotEmpty) {
        finalImagemUrlParaBackend = _selectedModelo!.imagemUrl;
      }

      final response = await _patrimonioService.inserirPatrimonioPHP(
        codigoPatrimonio: codigo,
        tipoPatrimonio: tipo!,
        descricaoPatrimonio: descricao.isNotEmpty ? descricao : null,
        setorOrigemId: _selectedSetorOrigem!.id_setor!,
        nfePatrimonio: nfe.isNotEmpty ? nfe : null,
        lotePatrimonio: lote.isNotEmpty ? lote : null,
        dataEntrada: dataEntradaApi,
        idModelo: _selectedModelo!.idModelo!,
        idMarca: _selectedMarca!.id_marca!,
        idFornecedor: _selectedFornecedor!.id_fornecedor!,
        imagemBytes: finalImagemBytes,
        nomeArquivo: finalNomeArquivo,
        imagemUrlModelo: finalImagemUrlParaBackend,
      );

      if (response['status'] == 'success' || response['status'] == 'created') {
        _showSuccessSnackbar(context, response['message'] ?? 'Patrimônio cadastrado com sucesso!');
        // NÃO CHAME limparCampos() AQUI se o chamador (ListaPatrimonioPage) já fará isso.
        // O `PatrimonioListProvider` é quem coordena isso.
        // limparCampos(); // <--- COMENTADO / REMOVIDO

        if (response['data'] != null) {
          try {
            final novoPatrimonio = Patrimonio.fromJson(response['data'] as Map<String, dynamic>);
            // Adiciona diretamente à lista completa
            _todosOsPatrimonios.add(novoPatrimonio);
            // NÃO CHAME _aplicarFiltroInterno() AQUI. A ListaPatrimonioPage fará isso após o notifyListeners.
            // _aplicarFiltroInterno(); // <--- COMENTADO / REMOVIDO
            _totalPatrimoniosApi++;
          } catch (e) {
            debugPrint('Erro ao parsear dados do novo patrimônio da API: $e');
            _showErrorSnackbar(context, 'Patrimônio salvo, mas erro ao carregar detalhes.');
            // Se o parsing falhar, ainda é bom recarregar a lista completa para garantir a consistência.
            await buscarPatrimonios(mostrarLoading: false);
          }
        } else {
          debugPrint('API retornou sucesso mas sem dados do patrimônio. Recarregando lista completa.');
          await buscarPatrimonios(mostrarLoading: false);
        }
        return true;
      } else {
        _showErrorSnackbar(context, 'Erro ao cadastrar: ${response['message'] ?? 'Erro desconhecido da API'}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Erro de conexão: ${e.toString()}');
      _setErro(e.toString(), notify: false);
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> editarPatrimonio(BuildContext context) async {
    if (_patrimonioEmEdicao == null) {
      _showErrorSnackbar(context, 'Nenhum patrimônio selecionado para edição.');
      return false;
    }

    final idPatrimonio = _patrimonioEmEdicao!.idPatrimonio!;
    final codigo = codigoPatrimonioController.text.trim();
    final tipo = _selectedTipoPatrimonio?.displayValue;
    final descricao = descricaoPatrimonioController.text.trim();
    final nfe = nfePatrimonioController.text.trim();
    final lote = lotePatrimonioController.text.trim();
    final dataEntradaApi = _formatarDataParaAPI(dataEntradaController.text);

    if (codigo.isEmpty || tipo == null || tipo.isEmpty || _selectedModelo == null ||
        _selectedMarca == null || _selectedFornecedor == null || _selectedSetorOrigem == null ||
        _selectedSetorAtual == null) {
      _showErrorSnackbar(context, 'Todos os campos obrigatórios (Código, Tipo, Modelo, Marca, Fornecedor, Setor de Origem, Setor Atual) devem ser preenchidos.');
      return false;
    }

    Uint8List? imagemParaUpload;
    String? nomeArquivoParaUpload;
    String? imagemUrlModeloParaBackend;
    bool enviarImagemNoRequest = false;

    if (_editandoImagemFoiAlterada) {
      if (_imagemSelecionadaBytes != null) {
        imagemParaUpload = _imagemSelecionadaBytes;
        nomeArquivoParaUpload = _nomeArquivoImagemSelecionada;
        enviarImagemNoRequest = true;
      } else {
        imagemParaUpload = null;
        nomeArquivoParaUpload = null;
        enviarImagemNoRequest = true;
      }
    } else {
      if (_patrimonioEmEdicao!.imagemPatrimonio == null || _patrimonioEmEdicao!.imagemPatrimonio!.isEmpty) {
        if (_selectedModelo?.imagemUrl != null && _selectedModelo!.imagemUrl!.isNotEmpty) {
          imagemUrlModeloParaBackend = _selectedModelo!.imagemUrl;
          enviarImagemNoRequest = true;
        }
      }
    }

    setLoading(true, notify: true);
    _setErro(null, notify: false);

    try {
      if (_patrimonioEmEdicao!.codigoPatrimonio != codigo) {
        final responseValidation = await _patrimonioService.verificarCodigoPatrimonioExistenteEdicao(codigo, idPatrimonio);
        if (responseValidation.containsKey('exists') && responseValidation['exists'] == true) {
          _showErrorSnackbar(context, 'Já existe outro patrimônio com este código.');
          return false;
        } else if (responseValidation.containsKey('status') && responseValidation['status'] == 'error') {
          _showErrorSnackbar(context, 'Erro ao verificar código do patrimônio: ${responseValidation['message'] ?? 'Erro desconhecido'}');
          return false;
        }
      }

      final response = await _patrimonioService.atualizarPatrimonioPHP(
        idPatrimonio: idPatrimonio,
        codigoPatrimonio: codigo,
        tipoPatrimonio: tipo!,
        descricaoPatrimonio: descricao.isNotEmpty ? descricao : null,
        setorOrigemId: _selectedSetorOrigem!.id_setor!,
        nfePatrimonio: nfe.isNotEmpty ? nfe : null,
        lotePatrimonio: lote.isNotEmpty ? lote : null,
        dataEntrada: dataEntradaApi,
        idModelo: _selectedModelo!.idModelo!,
        idMarca: _selectedMarca!.id_marca!,
        idFornecedor: _selectedFornecedor!.id_fornecedor!,
        idSetorAtual: _selectedSetorAtual!.id_setor!,
        imagemBytes: imagemParaUpload,
        nomeArquivo: nomeArquivoParaUpload,
        imagemFoiAlterada: enviarImagemNoRequest,
        imagemUrlModelo: imagemUrlModeloParaBackend,
      );

      if (response['status'] == 'success' || response['status'] == 'info') {
        _showSuccessSnackbar(context, response['message'] ?? 'Patrimônio atualizado com sucesso!');

        if (response['data'] != null) {
          try {
            final patrimonioAtualizado = Patrimonio.fromJson(response['data'] as Map<String, dynamic>);
            int index = _todosOsPatrimonios.indexWhere((p) => p.idPatrimonio == patrimonioAtualizado.idPatrimonio);
            if (index != -1) {
              _todosOsPatrimonios[index] = patrimonioAtualizado;
            } else {
              _todosOsPatrimonios.add(patrimonioAtualizado);
            }
            // NÃO CHAME _aplicarFiltroInterno() AQUI. A ListaPatrimonioPage fará isso.
            // _aplicarFiltroInterno(); // <--- COMENTADO / REMOVIDO
          } catch (e) {
            debugPrint('Erro ao parsear dados do patrimônio atualizado da API: $e');
            _showErrorSnackbar(context, 'Patrimônio atualizado, mas erro ao carregar detalhes.');
            await buscarPatrimonios(mostrarLoading: false);
          }
        } else {
          debugPrint('API retornou sucesso sem dados do patrimônio. Recarregando lista completa.');
          await buscarPatrimonios(mostrarLoading: false);
        }

        _editandoImagemFoiAlterada = false;
        _patrimonioEmEdicao = null;
        // NÃO CHAME limparCampos() AQUI. O `PatrimonioListProvider` coordena.
        // limparCampos(); // <--- COMENTADO / REMOVIDO
        return true;
      } else {
        _showErrorSnackbar(context, 'Erro ao editar: ${response['message'] ?? 'Erro desconhecido'}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Erro de conexão: ${e.toString()}');
      _setErro(e.toString(), notify: false);
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> inativarPatrimonio(BuildContext context, int idPatrimonio) async {
    setLoading(true);
    _setErro(null);
    bool sucesso = false;

    try {
      final response = await _patrimonioService.inativarPatrimonio(idPatrimonio);

      if (response['status'] == 'success') {
        _showSuccessSnackbar(context, response['message'] ?? 'Patrimônio inativado com sucesso!');
        _todosOsPatrimonios.removeWhere((p) => p.idPatrimonio == idPatrimonio);
        // NÃO CHAME _aplicarFiltroInterno() AQUI. A ListaPatrimonioPage fará isso.
        // _aplicarFiltroInterno(); // <--- COMENTADO / REMOVIDO
        // notifyListeners(); // Já será chamado pelo setLoading(false)
        sucesso = true;
      } else {
        _showErrorSnackbar(context, 'Erro ao inativar: ${response['message'] ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Erro de conexão: ${e.toString()}');
      _setErro(e.toString());
    } finally {
      setLoading(false);
    }
    return sucesso;
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showInfoSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blueGrey),
    );
  }
}