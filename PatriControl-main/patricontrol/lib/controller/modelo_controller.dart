import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/modelo_service.dart';
import '../model/modelo.dart'; // Certifique-se que Modelo.fromJson existe e está correto
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Importe ImagePicker aqui

class ModeloController extends ChangeNotifier {
  final ModeloService _modeloService;

  // --- State for Form ---
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController corController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  Uint8List? _imagemSelecionadaBytes; // A imagem em bytes atualmente no seletor
  String?
      _nomeArquivoImagemSelecionada; // Nome do arquivo da imagem selecionada
  bool _editandoImagemFoiAlterada =
      false; // Flag para indicar se a imagem NO FORMULÁRIO mudou
  Modelo? _modeloEmEdicao; // O modelo que está sendo editado
  Uint8List?
      _bytesImagemOriginalCarregada; // ADICIONADO: Bytes da imagem original do DB (para comparação)

  // --- State for List/Loading/Error ---
  bool _isLoading = false;
  String? _erroGeral;
  List<Modelo> _todosOsModelos = [];
  List<Modelo> _listaDeModelosFiltrada = [];
  String _textoPesquisaAtual = '';
  int _totalModelosApi = 0;

  // --- Getters ---
  Uint8List? get imagemSelecionadaBytes => _imagemSelecionadaBytes;
  String? get nomeArquivoImagemSelecionada => _nomeArquivoImagemSelecionada;
  bool get isLoading => _isLoading;
  List<Modelo> get listaDeModelosExibida => _listaDeModelosFiltrada;
  String? get erroGeral => _erroGeral;
  String get textoPesquisaAtual => _textoPesquisaAtual;
  bool get editandoImagemFoiAlterada =>
      _editandoImagemFoiAlterada; // Getter para a flag

  ModeloController({ModeloService? modeloService})
      : _modeloService = modeloService ?? ModeloService();

  // --- Form/Image Handling ---
  void setImagemSelecionada(Uint8List? bytes, String? nomeArquivo) {
    _imagemSelecionadaBytes = bytes;
    _nomeArquivoImagemSelecionada = nomeArquivo;
    // IMPORTANTE: Aqui você define que a imagem foi alterada no formulário.
    // A lógica de _editandoImagemFoiAlterada agora se refere se o usuário selecionou uma nova.
    _editandoImagemFoiAlterada = true;
    notifyListeners();
  }

  void limparCampos() {
    nomeController.clear();
    corController.clear();
    descricaoController.clear();
    _imagemSelecionadaBytes = null;
    _nomeArquivoImagemSelecionada = null;
    _editandoImagemFoiAlterada = false;
    _modeloEmEdicao = null;
    _bytesImagemOriginalCarregada = null; // Limpa também a imagem original
    notifyListeners();
  }

  /// Prepara o formulário para edição.
  /// Assume que 'modelo' contém os dados necessários, incluindo imagem se aplicável.
  Future<void> carregarDadosParaEdicao(Modelo modelo) async {
    _modeloEmEdicao = modelo;
    nomeController.text = modelo.nomeModelo;
    corController.text = modelo.corModelo!;
    descricaoController.text = modelo.descricaoModelo ?? '';

    _imagemSelecionadaBytes = null; // Limpa qualquer imagem anterior no seletor
    _nomeArquivoImagemSelecionada = null;
    _editandoImagemFoiAlterada =
        false; // Começa sem alteração intencional da imagem
    _bytesImagemOriginalCarregada =
        null; // Limpa a imagem original pré-existente
    _setErro(null); // Limpa qualquer erro anterior de carregamento de imagem

    // --- LÓGICA CRÍTICA: Carrega a imagem da URL se ela existir ---
    if (modelo.imagemUrl != null && modelo.imagemUrl!.isNotEmpty) {
      setLoading(true, notify: true); // Mostra loading enquanto baixa a imagem
      try {
        final response = await http.get(Uri.parse(modelo.imagemUrl!));
        if (response.statusCode == 200) {
          _imagemSelecionadaBytes = response.bodyBytes;
          _bytesImagemOriginalCarregada =
              response.bodyBytes; // Guarda esta imagem como a "original"
          print('Imagem ${modelo.imagemUrl} carregada com sucesso da URL.');
        } else {
          print('Falha ao carregar imagem da URL: ${response.statusCode}');
          _setErro(
              'Não foi possível carregar a imagem existente. Status: ${response.statusCode}');
          _imagemSelecionadaBytes =
              null; // Garante que não haja imagem inválida
          _bytesImagemOriginalCarregada = null;
        }
      } catch (e) {
        print('Erro ao baixar imagem da URL: $e');
        _setErro('Erro de conexão ao carregar imagem existente.');
        _imagemSelecionadaBytes = null;
        _bytesImagemOriginalCarregada = null;
      } finally {
        setLoading(false); // Remove o loading
      }
    } else {
      // Se não há URL de imagem, certifica-se que os bytes estejam nulos
      _imagemSelecionadaBytes = null;
      _bytesImagemOriginalCarregada = null;
    }
    notifyListeners(); // Notifica a UI para exibir a imagem carregada ou o placeholder
  }

  /// Reverte os dados do formulário para os valores do modelo em edição.
  void reverterDadosEdicao() {
    if (_modeloEmEdicao != null) {
      nomeController.text = _modeloEmEdicao!.nomeModelo!;
      corController.text = _modeloEmEdicao!.corModelo!;
      descricaoController.text = _modeloEmEdicao!.descricaoModelo ?? '';

      // Ao reverter, restaura a imagem original que foi baixada
      _imagemSelecionadaBytes = _bytesImagemOriginalCarregada;
      _nomeArquivoImagemSelecionada =
          null; // Não temos o nome do arquivo original
      _editandoImagemFoiAlterada =
          false; // Reseta a flag de alteração da imagem no formulário
      _setErro(null); // Limpa qualquer erro de imagem
      notifyListeners();
    }
  }

  // --- Loading State ---
  // --- Loading State ---
  // Tornando o método público para que os dialogs possam ativá-lo
  void setLoading(bool value, {bool notify = true}) {
    _isLoading = value;
    if (notify) notifyListeners();
  }

  void _setErro(String? message, {bool notify = true}) {
    _erroGeral = message;
    if (notify) notifyListeners();
  }

  // --- API Operations ---

  /// Busca modelos da API (busca todos os ativos).
  Future<void> buscarModelos({bool mostrarLoading = true}) async {
    if (mostrarLoading) setLoading(true, notify: _todosOsModelos.isEmpty);
    _setErro(null, notify: false); // Limpa erro antes de tentar

    try {
      final response = await _modeloService.listarModelos(deletado: 0);

      if (response['status'] == 'success') {
        final List<dynamic> listaJson =
            (response['data'] as Map<String, dynamic>)['data'] ?? [];
        _todosOsModelos = listaJson
            .map((data) => Modelo.fromJson(data as Map<String, dynamic>))
            .toList();
        _listaDeModelosFiltrada = [..._todosOsModelos];
        _totalModelosApi = (response['data'] as Map<String, dynamic>)['total'] ?? 0;
      } else {
        final errorMessage =
            response['message'] ?? 'Erro desconhecido ao listar modelos.';
        _setErro('Falha ao carregar: $errorMessage');
        _todosOsModelos = [];
        _listaDeModelosFiltrada = [];
        _totalModelosApi = 0;
      }
    } on Exception catch (e) {
      print("Erro ao buscar modelos no controller: $e");
      _setErro("Falha na comunicação: ${e.toString()}");
      _todosOsModelos = [];
      _listaDeModelosFiltrada = [];
      _totalModelosApi = 0;
    } finally {
      setLoading(false); // Garante que o loading termine
    }
  }

  // Método para a UI chamar quando o texto da pesquisa mudar
  void filtrarModelosLocalmente(String texto) {
    _textoPesquisaAtual = texto.toLowerCase().trim();
    _aplicarFiltroInterno();
    notifyListeners();
  }

  void _aplicarFiltroInterno() {
    if (_textoPesquisaAtual.isEmpty) {
      _listaDeModelosFiltrada = List.from(_todosOsModelos);
    } else {
      _listaDeModelosFiltrada = _todosOsModelos.where((modelo) {
        final nome = modelo.nomeModelo!.toLowerCase();
        final cor = modelo.corModelo!.toLowerCase();
        final descricao = (modelo.descricaoModelo ?? '').toLowerCase();
        return nome.contains(_textoPesquisaAtual) ||
            cor.contains(_textoPesquisaAtual) ||
            descricao.contains(_textoPesquisaAtual);
      }).toList();
    }
  }

  /// Tenta cadastrar um novo modelo.
  Future<bool> cadastrarModelo(BuildContext context) async {
    final nome = nomeController.text.trim();
    final cor = corController.text.trim();
    final descricao = descricaoController.text.trim();

    // Validações
    if (nome.isEmpty || cor.isEmpty) {
      _showErrorSnackbar(context, 'Nome e Cor são obrigatórios.');
      return false;
    }
    if (_imagemSelecionadaBytes == null) {
      // A imagem é obrigatória pela definição do banco (NOT NULL)
      _showErrorSnackbar(context, 'Por favor, selecione uma imagem.');
      return false;
    }

    setLoading(true, notify: true); // Notifica o loading para a UI
    _setErro(null, notify: false); // Limpa erro anterior, sem notificar ainda

    try {
      // Chama o serviço para inserir o modelo
      final response = await _modeloService.inserirModeloPHP(
        nome,
        cor,
        descricao.isNotEmpty ? descricao : null,
        imagemBytes: _imagemSelecionadaBytes!,
        nomeArquivo: _nomeArquivoImagemSelecionada!,
      );

      if (response['status'] == 'success' || response['status'] == 'created') {
        _showSuccessSnackbar(
            context, response['message'] ?? 'Modelo cadastrado com sucesso!');
        limparCampos(); // Limpa o formulário após sucesso

        // *** ALTERAÇÃO CRÍTICA AQUI: Adiciona o novo modelo à lista local ***
        if (response['data'] != null) {
          try {
            final novoModelo =
                Modelo.fromJson(response['data'] as Map<String, dynamic>);
            _todosOsModelos.add(novoModelo);
            _aplicarFiltroInterno(); // Re-aplica filtro para incluir o novo modelo na lista exibida
            _totalModelosApi++; // Incrementa o contador total
            print(
                'Modelo cadastrado e adicionado localmente: ${novoModelo.nomeModelo}');
          } catch (e) {
            // Caso haja um erro no parseamento do 'data' (improvável com sua API atual, mas seguro)
            print('Erro ao parsear dados do novo modelo da API: $e');
            _showErrorSnackbar(
                context, 'Modelo salvo, mas erro ao carregar detalhes.');
            // Se falhar o parse, ainda é melhor buscar tudo novamente para garantir a consistência
            await buscarModelos(mostrarLoading: false);
          }
        } else {
          // Se a API não retornou 'data' por algum motivo (menos comum, mas possível)
          print(
              'API retornou sucesso mas sem dados do modelo. Recarregando lista completa.');
          await buscarModelos(
              mostrarLoading: false); // Fallback: recarrega tudo
        }
        // *** FIM DA ALTERAÇÃO CRÍTICA ***

        return true; // Retorna true para que o Dialog possa fechar
      } else {
        _showErrorSnackbar(context,
            'Erro ao cadastrar: ${response['message'] ?? 'Erro desconhecido da API'}');
        return false;
      }
    } on Exception catch (e) {
      _showErrorSnackbar(context, 'Erro de conexão: ${e.toString()}');
      _setErro(e.toString(), notify: false); // Não notifica ainda
      return false;
    } finally {
      setLoading(false,
          notify: true); // Garante que o loading termine e notifica
      // notifyListeners(); // Já chamado por setLoading(false, notify: true)
    }
  }

  /// Tenta atualizar um modelo existente.
  Future<bool> editarModelo(BuildContext context, int idModelo) async {
    final nome = nomeController.text.trim();
    final cor = corController.text.trim();
    final descricao = descricaoController.text.trim();

    if (nome.isEmpty || cor.isEmpty) {
      _showErrorSnackbar(context, 'Nome e Cor são obrigatórios.');
      return false;
    }

    Uint8List? imagemParaUpload;
    String? nomeArquivoParaUpload;
    bool enviarImagemNoRequest = false;

    // Se o usuário selecionou uma NOVA imagem no formulário
    if (_editandoImagemFoiAlterada) {
      // E a imagem selecionada não é nula (ou seja, ele escolheu um arquivo)
      if (_imagemSelecionadaBytes != null) {
        imagemParaUpload = _imagemSelecionadaBytes;
        nomeArquivoParaUpload = _nomeArquivoImagemSelecionada;
        enviarImagemNoRequest = true; // Sim, envie a imagem para o PHP
      } else {
        // Isso ocorreria se o usuário tentou "remover" a imagem,
        // mas como a imagem é obrigatória, isso deve ser evitado na UI.
        // Se ocorrer, é um estado inválido para a atualização.
        _showErrorSnackbar(context, 'A imagem do modelo é obrigatória.');
        return false;
      }
    } else {
      // Se _editandoImagemFoiAlterada é false, significa que o usuário NÃO INTERAGIU com a imagem
      // Ele quer manter a imagem original.
      // Neste caso, não enviamos os campos de imagem no MultipartRequest,
      // e o PHP irá manter a imagem existente no banco.
      enviarImagemNoRequest = false;
    }

    setLoading(true, notify: true); // Notifica o loading para a UI
    _setErro(null, notify: false); // Limpa erro anterior, sem notificar ainda

    try {
      final response = await _modeloService.atualizarModelo(
        idModelo,
        nome,
        cor,
        descricao.isNotEmpty ? descricao : null,
        imagemParaUpload, // Será null se 'enviarImagemNoRequest' for false
        nomeArquivo:
            nomeArquivoParaUpload, // Será null se 'enviarImagemNoRequest' for false
        imagemFoiAlterada:
            enviarImagemNoRequest, // Diz ao Service se o campo 'imagem_modelo' deve ser enviado
        sinalizarRemocaoImagem: false, // Sempre false, pois não há remoção
      );

      if (response['status'] == 'success' || response['status'] == 'info') {
        _showSuccessSnackbar(
            context, response['message'] ?? 'Modelo atualizado com sucesso!');

        // *** ALTERAÇÃO CRÍTICA AQUI: Atualiza o modelo na lista local ***
        if (response['data'] != null) {
          try {
            final modeloAtualizado =
                Modelo.fromJson(response['data'] as Map<String, dynamic>);
            // Encontra e substitui o modelo na lista principal (_todosOsModelos)
            int index = _todosOsModelos
                .indexWhere((m) => m.idModelo == modeloAtualizado.idModelo);
            if (index != -1) {
              _todosOsModelos[index] = modeloAtualizado;
            } else {
              // Se o modelo não for encontrado (ex: erro inesperado ou lista não carregada)
              // Adiciona ele para garantir que ele esteja na lista.
              _todosOsModelos.add(modeloAtualizado);
            }
            _aplicarFiltroInterno(); // Re-aplica filtro para atualizar a lista exibida
            print(
                'Modelo atualizado e lista local atualizada: ${modeloAtualizado.nomeModelo}');
          } catch (e) {
            print('Erro ao parsear dados do modelo atualizado da API: $e');
            _showErrorSnackbar(
                context, 'Modelo atualizado, mas erro ao carregar detalhes.');
            // Fallback: se houver erro no parse, recarrega a lista completa
            await buscarModelos(mostrarLoading: false);
          }
        } else {
          // Se a API retornou sucesso mas sem 'data' (menos comum)
          print(
              'API retornou sucesso sem dados do modelo. Recarregando lista completa.');
          await buscarModelos(
              mostrarLoading: false); // Fallback: recarrega tudo
        }
        // *** FIM DA ALTERAÇÃO CRÍTICA ***

        // Reseta as flags da imagem e o modelo em edição após o sucesso
        _editandoImagemFoiAlterada = false;
        _modeloEmEdicao = null; // Limpa o modelo que estava sendo editado
        limparCampos(); // Limpa o formulário após a edição bem-sucedida

        return true; // Retorna true para que o Dialog possa fechar
      } else {
        _showErrorSnackbar(context,
            'Erro ao editar: ${response['message'] ?? 'Erro desconhecido'}');
        return false;
      }
    } on Exception catch (e) {
      _showErrorSnackbar(context, 'Erro de conexão: ${e.toString()}');
      _setErro(e.toString(), notify: false); // Não notifica ainda
      return false;
    } finally {
      setLoading(false,
          notify: true); // Garante que o loading termine e notifica
      // notifyListeners(); // Já chamado por setLoading(false, notify: true)
    }
  }

  /// Tenta inativar (soft delete) um modelo.
  Future<bool> inativarModelo(BuildContext context, int idModelo) async {
    setLoading(true);
    _setErro(null);
    bool sucesso = false;

    try {
      final response = await _modeloService.inativarModelo(idModelo);

      if (response['status'] == 'success') {
        _showSuccessSnackbar(
            context, response['message'] ?? 'Modelo inativado com sucesso!');
        _todosOsModelos.removeWhere((m) => m.idModelo == idModelo);
        _aplicarFiltroInterno();
        notifyListeners();
        sucesso = true;
      } else {
        _showErrorSnackbar(context,
            'Erro ao inativar: ${response['message'] ?? 'Erro desconhecido'}');
      }
    } on Exception catch (e) {
      _showErrorSnackbar(context, 'Erro de conexão: ${e.toString()}');
      _setErro(e.toString());
    } finally {
      setLoading(false);
    }
    return sucesso;
  }

  // --- Helpers ---
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
