// lib/providers/marca_list_provider.dart
import 'package:flutter/material.dart';
import '../controller/marca_controller.dart';
import '../model/marca.dart';

class MarcaListProvider extends ChangeNotifier {
  final MarcaController _marcaController = MarcaController();
  List<Marca> _listaMarcas = [];
  bool _isLoading = false;
  String? _error;
  String _textoPesquisa = '';

  List<Marca> get listaMarcas => _listaMarcas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get textoPesquisa => _textoPesquisa;

  MarcaListProvider();

  Future<void> carregarMarcas({int deletado = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _listaMarcas = await _marcaController.listarMarcas(deletado: deletado);
      } catch (e) {
      _error = 'Erro ao carregar marcas: $e';
      _listaMarcas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void atualizarPesquisa(String texto) {
    _textoPesquisa = texto.toLowerCase();
    notifyListeners();
  }

  List<Marca> filtrarMarcas() {
    if (_textoPesquisa.isEmpty) {
      return _listaMarcas;
    }
    return _listaMarcas.where((marca) {
      final nome = marca.nome_marca.toLowerCase();
      return nome.contains(_textoPesquisa);
    }).toList();
  }

  Future<bool> inativarMarca(BuildContext context, int? id) async {
    final sucesso = await _marcaController.deletarMarca(context, id!);
    if (sucesso) {
      await carregarMarcas();
      return true;
    }
    return false;
  }
}