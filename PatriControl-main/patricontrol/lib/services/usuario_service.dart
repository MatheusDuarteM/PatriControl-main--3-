import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:patricontrol/utils/conect.dart';

class UsuarioService {
  final String baseUrl = Conect.getBaseUrl();
  final String _endpoint = "/processa_bdCeet.php";

  Uri _getApiUrl() => Uri.parse('$baseUrl$_endpoint');

  Map<String, String> _getHeaders() => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // Helper para tratamento de erro comum - AGORA RETORNA APENAS A MENSAGEM LIMPA
  String _handleError(dynamic e, String operation) {
    if (e is http.Response) {
      String errorMessage = 'Erro no servidor: ${e.statusCode}'; // Default message
      try {
        final decodedBody = json.decode(e.body);
        if (decodedBody is Map && decodedBody.containsKey('message')) {
          errorMessage = decodedBody['message'] as String;
        } else if (e.body.isNotEmpty) {
          // Se não houver 'message' mas houver body, usa o body
          errorMessage = e.body;
        }
      } catch (_) {
        // Ignora erro de decodificação, usa a mensagem default ou o corpo bruto se existir
        if (e.body.isNotEmpty) {
          errorMessage = e.body;
        }
      }
      return errorMessage; // RETORNA APENAS A MENSAGEM
    } else if (e is Exception) {
      // Para exceções lançadas diretamente como Exception, remove o "Exception: "
      return e.toString().replaceFirst('Exception: ', '');
    } else {
      // Para outros tipos de erro, ou erros de conexão
      return 'Erro de conexão ou inesperado ao $operation: ${e.toString()}';
    }
  }

  /// Cria um novo usuário.
  Future<Map<String, dynamic>> criarUsuario({
    required String nome,
    required String senha,
    required String cpf,
    required DateTime nasc,
    required String tipo,
  }) async {
    final url = _getApiUrl();
    try {
      final String dataNascimentoFormatada =
          "${nasc.year.toString().padLeft(4, '0')}-${nasc.month.toString().padLeft(2, '0')}-${nasc.day.toString().padLeft(2, '0')}";

      final Map<String, dynamic> requestBody = {
        'acao': 'inserirUsuarioCompletoPHP',
        'nome_usuario': nome,
        'senha_usuario': senha,
        'cpf_usuario': cpf,
        'nasc_usuario': dataNascimentoFormatada,
        'tipo_usuario': tipo,
      };

      final response = await http
          .post(
            url,
            headers: _getHeaders(),
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        if (decodedResponse['status'] == 'success' ||
            decodedResponse['status'] == 'created') {
          return decodedResponse;
        } else {
          // Se a API retornar um status não-sucesso, lançamos uma exceção
          // com a mensagem contida na resposta da API, sem prefixo
          throw Exception(decodedResponse['message'] ?? 'Erro desconhecido da API ao criar usuário.');
        }
      } else {
        // Se o status HTTP não for 200/201, lançamos a resposta HTTP diretamente
        throw response;
      }
    } catch (e) {
      // Agora, _handleError retorna a mensagem limpa
      throw Exception(_handleError(e, 'criar usuário'));
    }
  }

  /// Atualiza um usuário existente.
  Future<Map<String, dynamic>> atualizarUsuario({
    required int id,
    required String nome,
    required String cpf,
    required String tipo,
    required DateTime nasc,
    String? novaSenha,
  }) async {
    final url = _getApiUrl();
    try {
      final String dataNascimentoFormatada =
          "${nasc.year.toString().padLeft(4, '0')}-${nasc.month.toString().padLeft(2, '0')}-${nasc.day.toString().padLeft(2, '0')}";
      final Map<String, dynamic> requestBody = {
        'acao': 'atualizarUsuarioCompletoPHP',
        'id_usuario': id,
        'nome_usuario': nome,
        'cpf_usuario': cpf,
        'nasc_usuario': dataNascimentoFormatada,
        'tipo_usuario': tipo,
      };

      if (novaSenha != null && novaSenha.isNotEmpty) {
        requestBody['senha_usuario'] = novaSenha;
      }

      final response = await http
          .post(
            url,
            headers: _getHeaders(),
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        if (decodedResponse['status'] == 'success') {
          return decodedResponse;
        } else {
          throw Exception(decodedResponse['message'] ??
              'Erro ao atualizar usuário: Status da API indica falha');
        }
      } else {
        throw response;
      }
    } catch (e) {
      throw Exception(_handleError(e, 'atualizar usuário'));
    }
  }

  /// Lista usuários com paginação e filtro opcional.
  Future<Map<String, dynamic>> listarUsuarios({
    int deletado = 0,
    String? searchText
  }) async {
    final url = _getApiUrl();
    Map<String, dynamic> body = {
      'acao': 'listarUsuariosPHP',
      'deletado': deletado,
    };
    if (searchText != null && searchText.isNotEmpty) {
      body['filtro_nome_usuario'] = searchText;
    }
    try {
      final response = await http
          .post(
            url,
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData['status'] == 'success') {
          return {
            'status': 'success',
            'message': responseData['message'],
            'data': responseData['data'] ?? [],
            'total': responseData['total'] ?? 0,
          };
        } else {
          throw Exception(
              responseData['message'] ?? 'Erro desconhecido da API');
        }
      } else {
        throw response;
      }
    } catch (e) {
      throw Exception(_handleError(e, 'listar usuários'));
    }
  }

  /// Inativa um usuário (Soft Delete).
  Future<Map<String, dynamic>> inativarUsuario(int idUsuario) async {
    final url = _getApiUrl();
    try {
      final response = await http
          .post(
            url,
            headers: _getHeaders(),
            body: json.encode({
              'acao': 'inativarUsuarioPHP',
              'id_usuario': idUsuario,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        if (decodedResponse['status'] == 'success') {
          return decodedResponse;
        } else {
          throw Exception(decodedResponse['message'] ??
              'Erro ao inativar usuário: Status da API indica falha');
        }
      } else {
        throw response;
      }
    } catch (e) {
      throw Exception(_handleError(e, 'inativar usuário'));
    }
  }

  /// Carrega dados de um usuário específico pelo ID.
  Future<Map<String, dynamic>> carregarUsuario(int idUsuario) async {
    final url = _getApiUrl();
    try {
      final response = await http
          .post(
            url,
            headers: _getHeaders(),
            body: json.encode({
              'acao': 'carregarUsuarioPHP',
              'id_usuario': idUsuario,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        if (decodedResponse['status'] == 'success') {
          return decodedResponse;
        } else {
          throw Exception(decodedResponse['message'] ??
              'Erro ao carregar usuário: Status da API indica falha');
        }
      } else {
        throw response;
      }
    } catch (e) {
      throw Exception(_handleError(e, 'carregar usuário'));
    }
  }

  Future<Map<String, dynamic>> logar(String nomeUsuario, String senha) async {
    final url = _getApiUrl();
    try {
      final response = await http
          .post(
            url,
            headers: _getHeaders(),
            body: json.encode({
              'acao': 'logarPHP',
              'usuario': nomeUsuario,
              'senha': senha,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body) as Map<String, dynamic>;
        // A API de login retorna status diferente, então vamos retornar o body direto
        return decodedBody;
      } else {
        throw response;
      }
    } catch (e) {
      throw Exception(_handleError(e, 'logar'));
    }
  }
}