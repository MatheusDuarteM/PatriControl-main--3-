import 'package:flutter/material.dart';
import '../model/modelo.dart';
import '../services/modelo_service.dart';
import 'dart:typed_data';
// import 'package:image_picker/image_picker.dart'; // Não é necessário aqui no provider

class ModeloListProvider extends ChangeNotifier {
  final ModeloService _modeloService = ModeloService();
  List<Modelo> _modelos = [];
  List<Modelo> _modelosFiltrados = [];
  bool _isLoading = false;
  String? _error;
  String _searchText = '';

  List<Modelo> get modelosFiltrados => _modelosFiltrados;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchText => _searchText;

  get errorMessage => null;

  Future<void> carregarModelos() async {
    print('ModeloListProvider.carregarModelos() chamado.');
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _modeloService.listarModelos(deletado: 0);
      print('DEBUG - Resposta API para listarModelos (no ModeloListProvider): $response'); // ADICIONE ESTE PRINT PARA DEPURAR

      if (response['status'] == 'success' && response['data'] != null) {
        // Acessa 'data' de 'data' que é onde está a lista de modelos
        // AQUI ESTÁ A LINHA DE CORREÇÃO!
        final List<dynamic> listaJson = (response['data'] as Map<String, dynamic>)['modelos'] ?? [];
        _modelos = listaJson.map((data) => Modelo.fromJson(data as Map<String, dynamic>)).toList();
        _filtrarModelos();
        print('--- Modelos Carregados e suas URLs ---');
        for (var modelo in _modelosFiltrados) {
          print('ID: ${modelo.idModelo}, Nome: ${modelo.nomeModelo}, URL da Imagem: ${modelo.imagemUrl}');
        }
        print('--- Fim das URLs ---');
      } else {
        _error = response['message'] ?? 'Erro ao carregar modelos.';
        _modelos = [];
        _modelosFiltrados = [];
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _modelos = [];
      _modelosFiltrados = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void atualizarPesquisa(String text) {
    _searchText = text.toLowerCase();
    _filtrarModelos();
    notifyListeners();
  }

  void _filtrarModelos() {
    if (_searchText.isEmpty) {
      _modelosFiltrados = List.from(_modelos);
    } else {
      _modelosFiltrados = _modelos.where((modelo) {
        final nome = modelo.nomeModelo.toLowerCase();
        final cor = modelo.corModelo!.toLowerCase();
        final descricao = (modelo.descricaoModelo ?? '').toLowerCase();
        return nome.contains(_searchText) || cor.contains(_searchText) || descricao.contains(_searchText);
      }).toList();
    }
  }

  // MÉTODO DE CADASTRO ATUALIZADO
  Future<bool> cadastrarModelo(BuildContext context, String nome, String cor, String? descricao, Uint8List? imagemBytes, String? nomeArquivo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _modeloService.inserirModeloPHP(nome, cor, descricao, imagemBytes: imagemBytes, nomeArquivo: nomeArquivo);
      // *** CHAMA O NOVO MÉTODO PARA TRATAR A RESPOSTA ***
      return await _handleApiResponse(context, response);
    } catch (e) {
      _error = 'Erro na comunicação com o servidor ao cadastrar: $e';
      _showErrorSnackbar(context, _error!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MÉTODO DE EDIÇÃO ATUALIZADO
  Future<bool> editarModelo(BuildContext context, int idModelo, String nome, String cor, String? descricao, Uint8List? imagemBytes, bool imagemFoiAlterada) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _modeloService.atualizarModelo(idModelo, nome, cor, descricao, imagemBytes, imagemFoiAlterada: imagemFoiAlterada);
      // *** CHAMA O NOVO MÉTODO PARA TRATAR A RESPOSTA ***
      return await _handleApiResponse(context, response);
    } catch (e) {
      _error = 'Erro na comunicação com o servidor ao editar: $e';
      _showErrorSnackbar(context, _error!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para inativar modelo (mantido como está, mas pode se beneficiar do _handleApiResponse)
  Future<bool> inativarModelo(BuildContext context, int idModelo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _modeloService.inativarModelo(idModelo);
      if (response['status'] == 'success') {
        _showSuccessSnackbar(context, response['message'] ?? 'Modelo inativado com sucesso!');
        _modelos.removeWhere((m) => m.idModelo == idModelo);
        _filtrarModelos();
        // Não é necessário chamar carregarModelos completo aqui, pois removemos da lista local.
        notifyListeners();
        return true;
      } else {
        _showErrorSnackbar(context, response['message'] ?? 'Erro desconhecido ao inativar.');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Erro de conexão: $e');
      _error = 'Erro de conexão: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- NOVO MÉTODO CENTRALIZADO PARA TRATAR RESPOSTAS DA API ---
  Future<bool> _handleApiResponse(BuildContext context, Map<String, dynamic> response) async {
    final String status = response['status'] as String? ?? 'error_unknown'; // Garante que status não é nulo
    final String message = response['message'] as String? ?? 'Operação concluída.';

    switch (status) {
      case 'success':
      case 'created': // Tratar 'created' do cadastro como sucesso
      case 'info':    // Tratar 'info' da edição (sem alteração) como sucesso
        // Exibir SnackBar com base no status
        if (status == 'success' || status == 'created') {
          _showSuccessSnackbar(context, message);
        } else { // status == 'info'
          _showInfoSnackbar(context, message);
        }
        await carregarModelos(); // Sempre recarrega a lista após uma operação "bem-sucedida"
        return true; // Retorna true para fechar o diálogo
      case 'error_client':
      case 'not_found':
      case 'error_server':
      case 'error_unknown': // Catch-all para status desconhecidos
      default: // Qualquer outro status não explicitamente tratado é um erro
        _error = message;
        _showErrorSnackbar(context, _error!);
        // notifyListeners(); // Já é chamado pelo setError ou showSnackbar em alguns casos, mas pode ser adicionado
        return false; // Retorna false para manter o diálogo aberto
    }
  }

  // --- MÉTODOS AUXILIARES PARA SNACKBARS (DENTRO DA CLASSE ModeloListProvider) ---
  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueGrey, // Cor para informação
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}