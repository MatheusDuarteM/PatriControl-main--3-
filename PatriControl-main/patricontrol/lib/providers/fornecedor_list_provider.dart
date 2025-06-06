import 'package:flutter/material.dart';
import 'package:patricontrol/controller/fornecedor_controller.dart';
import '../model/fornecedor.dart';

class FornecedorListProvider extends ChangeNotifier {
  final FornecedorController _fornecedorController = FornecedorController(); // Use o Controller
  List<Fornecedor> _listaFornecedores = [];
  bool _isLoading = false;
  String? _error;
  String _textoPesquisa = '';

  List<Fornecedor> get listaFornecedores => _listaFornecedores;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get textoPesquisa => _textoPesquisa;

  FornecedorListProvider();

  Future<void> carregarFornecedores({int deletado = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _listaFornecedores = await _fornecedorController.listarFornecedores(deletado: deletado);
    } catch (e) {
      _error = 'Erro ao carregar fornecedores: $e';
      _listaFornecedores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void atualizarPesquisa(String texto) {
    _textoPesquisa = texto.toLowerCase();
    notifyListeners();
  }

  List<Fornecedor> filtrarFornecedores() {
    if (_textoPesquisa.isEmpty) {
      return _listaFornecedores;
    }
    return _listaFornecedores.where((fornecedor) {
      final nome = fornecedor.nome_fornecedor.toLowerCase();
      final cnpj = fornecedor.cnpj_fornecedor.toLowerCase();
      return nome.contains(_textoPesquisa) || cnpj.contains(_textoPesquisa);
    }).toList();
  }

  Future<bool> inativarFornecedor(BuildContext context, int? id) async {
    final sucesso = await _fornecedorController.inativarFornecedor(context, id);
    if (sucesso) {
      await carregarFornecedores(); // Recarrega a lista após a inativação
      return true;
    }
    return false;
  }
}