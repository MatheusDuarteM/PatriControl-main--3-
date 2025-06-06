import 'package:flutter/material.dart';
import 'package:patricontrol/controller/setor_controller.dart';
import 'package:patricontrol/model/setor.dart';

class SetorListProvider extends ChangeNotifier {
  final SetorController _setorController = SetorController();
  List<Setor> _listaSetores = [];
  bool _isLoading = false;
  String? _error;
  String _textoPesquisa = '';
  String? _filtroTipo;

  List<Setor> get listaSetores => _listaSetores;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get textoPesquisa => _textoPesquisa;
  String? get filtroTipo => _filtroTipo;

  SetorListProvider();

  Future<void> carregarSetores({int deletado = 0, String? searchText, String? tipoFiltro}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _listaSetores = await _setorController.listarSetores(deletado: deletado, searchText: searchText, interno: tipoFiltro);
    } catch (e) {
      _error = 'Erro ao carregar setores: $e';
      _listaSetores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void atualizarPesquisa(String texto) {
    _textoPesquisa = texto.toLowerCase();
    notifyListeners();
    carregarSetores(searchText: _textoPesquisa, tipoFiltro: _filtroTipo);
  }

  void atualizarFiltroTipo(String? tipo) {
    _filtroTipo = tipo;
    notifyListeners();
    carregarSetores(searchText: _textoPesquisa, tipoFiltro: _filtroTipo);
  }

  List<Setor> filtrarLocalmente() {
    if (_textoPesquisa.isEmpty && _filtroTipo == null) {
      return _listaSetores;
    }
    return _listaSetores.where((setor) {
      final nome = setor.nome_setor.toLowerCase();
      final responsavel = setor.responsavel_setor.toLowerCase();
      final descricao = setor.descricao_setor.toLowerCase();
      final pesquisaOk = nome.contains(_textoPesquisa) || responsavel.contains(_textoPesquisa) || descricao.contains(_textoPesquisa);
      final filtroOk = _filtroTipo == null || setor.tipo_setor.toLowerCase() == _filtroTipo?.toLowerCase();
      return pesquisaOk && filtroOk;
    }).toList();
  }

  Future<bool> inativarSetor(BuildContext context, int? id) async {
    final sucesso = await _setorController.inativarSetor(context, id);
    if (sucesso) {
      await carregarSetores();
      return true;
    }
    return false;
  }
}