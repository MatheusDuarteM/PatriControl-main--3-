// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../model/usuario.dart'; // Seu modelo de usuário
import '../services/usuario_service.dart'; // Seu serviço de usuário

// Enum para representar os diferentes estados de autenticação
enum StatusAutenticacao {
  inicializando, // Checando se há usuário logado (ex: auto-login)
  autenticado, // Usuário logado com sucesso
  naoAutenticado, // Nenhum usuário logado ou logout realizado
  falhaAutenticacao, // Ocorreu um erro durante a tentativa de login
  // Você pode remover StatusAutenticacao.carregando se _isLoadingLogin for suficiente
}

class AuthProvider extends ChangeNotifier {
  final UsuarioService _usuarioService;

  Usuario? _usuarioLogado;
  StatusAutenticacao _status = StatusAutenticacao.inicializando;
  String? _mensagemErroLogin;
  bool _isLoadingLogin = false;

  AuthProvider({required UsuarioService usuarioService})
      : _usuarioService = usuarioService {
    // Chama o método que agora se chama verificarLoginSalvo
    // verificarLoginSalvo(); // Esta linha seria chamada pelo main.dart na criação
  }

  Usuario? get usuarioLogado => _usuarioLogado;
  StatusAutenticacao get status => _status;
  bool get isAuthenticated => _status == StatusAutenticacao.autenticado;
  String? get mensagemErroLogin => _mensagemErroLogin;
  bool get isLoadingLogin => _isLoadingLogin; // Usado na LoginPage para o botão

  // RENOMEADO de _simularInicializacao para verificarLoginSalvo e tornado público
  Future<void> verificarLoginSalvo() async {
    _status = StatusAutenticacao.inicializando; // Define o status inicial
    // notifyListeners(); // Opcional notificar aqui, ou só no final

    await Future.delayed(
        const Duration(milliseconds: 500)); // Simula verificação

    // Lógica real de auto-login viria aqui (ex: ler de SharedPreferences/SecureStorage)
    // Se encontrar dados salvos e válidos:
    //   _usuarioLogado = ... (dados do usuário)
    //   _status = StatusAutenticacao.autenticado;
    // Senão:
    _status = StatusAutenticacao.naoAutenticado;
    notifyListeners();
  }

  Future<bool> login(String nomeUsuario, String senha) async {
    _isLoadingLogin = true;
    _mensagemErroLogin = null;
    // _status = StatusAutenticacao.carregando; // Opcional, se quiser um estado de loading global
    notifyListeners();

    try {
      final response = await _usuarioService.logar(nomeUsuario, senha);
      print('Resposta da API: $response');

      if (response['status'] == 'success' &&
          response.containsKey('data') &&
          response['data'] is Map &&
          (response['data'] as Map).containsKey('usuario')) {
        final Map<String, dynamic>? dadosUsuario =
            (response['data'] as Map)['usuario'] as Map<String, dynamic>?;

        if (dadosUsuario != null) {
          _usuarioLogado = Usuario.fromJson(dadosUsuario);
          _status = StatusAutenticacao.autenticado;
          _mensagemErroLogin = null;
          _isLoadingLogin = false;
          print('Status alterado para: $_status');
          notifyListeners();
          return true;
        } else {
          throw Exception(
              'Dados do usuário não encontrados na resposta da API (status success -> data -> usuario).');
        }
      } else {
        _mensagemErroLogin =
            response['message'] as String? ?? 'Usuário ou senha inválidos.';
        _status = StatusAutenticacao.falhaAutenticacao;
        _usuarioLogado = null;
        _isLoadingLogin = false;
        print('Status alterado para: $_status com erro: $_mensagemErroLogin');
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Erro no AuthProvider.login: $e');
      _mensagemErroLogin = 'Erro de conexão ou falha ao processar o login.';
      // if (e is Exception && e.toString().contains('Erro de conexão')) { // Isso é muito específico e frágil
      //   _mensagemErroLogin = 'Não foi possível conectar ao servidor.';
      // }
      // Melhor deixar a mensagem genérica ou tratar tipos específicos de exceção (SocketException, etc.)
      _status = StatusAutenticacao.falhaAutenticacao;
      _usuarioLogado = null;
      _isLoadingLogin = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _usuarioLogado = null;
    _status = StatusAutenticacao.naoAutenticado;
    _mensagemErroLogin = null;
    _isLoadingLogin = false;
    // Limpar dados de sessão persistidos (SharedPreferences/SecureStorage)
    notifyListeners();
  }

  void limparMensagemErroLogin() {
    if (_mensagemErroLogin != null) {
      _mensagemErroLogin = null;
      notifyListeners();
    }
  }
}
