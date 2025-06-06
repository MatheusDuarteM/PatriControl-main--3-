import 'package:flutter/material.dart';
import 'package:patricontrol/controller/usuario_controller.dart';
import '../model/usuario.dart';

class UsuarioListProvider extends ChangeNotifier {

  final UsuarioController _usuarioController = UsuarioController();

  List<Usuario> _usuarios = [];
  bool _isLoading = false;
  String? _error;
  String _currentSearchTerm = '';

  List<Usuario> get usuarios => _usuarios; 
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentSearchTerm => _currentSearchTerm;

  UsuarioListProvider();


  Future<void> carregarUsuarios({int deletado = 0, String? searchText}) async {
    _isLoading = true;
    _error = null; 
    notifyListeners();
    try {
      _usuarios = await _usuarioController.listarUsuarios(deletado: deletado, searchText: searchText);
    } catch (e) {
      _error = 'Erro ao carregar usuarios: $e';
      _usuarios = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void atualizarPesquisa(String searchTerm) {
    _currentSearchTerm = searchTerm.toLowerCase();
    notifyListeners();
    carregarUsuarios(searchText: _currentSearchTerm);
  }
  
  List<Usuario> filtrarUsuarios() {
    return _usuarios;
  }

  Future<bool> inativarUsuario(BuildContext context, int? id) async {
    if (id == null) {
      _error = 'ID do usuário inválido para inativação.';
      notifyListeners();
      return false;
    }
    _isLoading = true; 
    notifyListeners(); 
    final sucesso = await _usuarioController.inativarUsuario(context, id);
    if (sucesso) {
      await carregarUsuarios(); 
      return true;
    } else {
      _error = _usuarioController.erroGeral;
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}