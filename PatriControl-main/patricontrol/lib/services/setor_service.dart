import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:patricontrol/utils/conect.dart';

class SetorService {
  final String baseUrl = Conect.getBaseUrl();

  Future<Map<String, dynamic>> inserirSetor(
    String tipo,
    String nome,
    String resposavel,
    String descricao,
    String contato,
    String email,
  ) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'inserirSetor',
          'tipo_setor': tipo,
          'nome_setor': nome,
          'responsavel_setor': resposavel,
          'descricao_setor': descricao,
          'contato_setor': contato,
          'email_setor': email
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao inserir setor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> listarSetor({int deletado = 0, String? searchText, String? tipoFiltro}) async {
  final url = Uri.parse('$baseUrl/processa_bdCeet.php');
  try {
    final Map<String, dynamic> body = {
      'acao': 'listarSetor',
      'deletado_setor': deletado};
    if (searchText != null && searchText.isNotEmpty) {
      body['nome_setor'] = searchText;
    }
    if (tipoFiltro != null && (tipoFiltro == 'Interno' || tipoFiltro == 'Externo')) {
      body['tipo_setor'] = tipoFiltro;
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(body),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao listar setores: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro ao conectar com a API: $e');
  }
}

  Future<Map<String, dynamic>> atualizarSetor(
    int? id,
    String tipo,
    String nome,
    String resposavel,
    String descricao,
    String contato,
    String email,
  ) async {
    print('Valor de "tipo" enviado no Service: $tipo');
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'atualizarSetor',
          'tipo_setor': tipo,
          'nome_setor': nome,
          'responsavel_setor': resposavel,
          'descricao_setor': descricao,
          'contato_setor': contato,
          'email_setor': email,
          'id_setor': id,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao atualizar setor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> inativarSetor(int? id) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'inativarSetor',
          'id_setor': id,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao deletar setor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> carregarSetor(int id) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'carregarSetor',
          'id_setor': id,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar setor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>?> verificarSetorExistente(String nome) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php'); // Adapte a URL
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'acao': 'verificarSetorExistente',
          'nome_setor': nome
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Erro ao verificar Nome'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Erro de conexão'};
    }
  }

  Future<Map<String, dynamic>?> verificarSetorExistenteEdicao(String nome, int id) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'acao': 'verificarSetorExistenteEdicao',
          'nome_setor': nome,
          'id_setor': id
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Erro ao verificar nome do setor na edição'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Erro de conexão'};
    }
  }
}