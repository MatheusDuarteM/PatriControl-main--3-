import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:patricontrol/utils/conect.dart';

class FornecedorService {
  final String baseUrl = Conect.getBaseUrl(); 

  Future<Map<String, dynamic>> inserirFornecedor(
    String nome,
    String cnpj,
    String contato,
    String endereco,
  ) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'inserirFornecedor',
          'nome': nome,
          'cnpj': cnpj,
          'contato': contato,
          'endereco': endereco,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao inserir fornecedor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }
  
  Future<Map<String, dynamic>> listarFornecedores(int deletado) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'listarFornecedor',
          'deletado': deletado,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao listar fornecedores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> atualizarFornecedor(
        int? id,
        String nome,
        String cnpj,
        String contato,
        String endereco,
      ) async {
        final url = Uri.parse('$baseUrl/processa_bdCeet.php');
        try {
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode({
              'acao': 'atualizarFornecedor',
              'id': id,
              'nome': nome,
              'cnpj': cnpj,
              'contato': contato,
              'endereco': endereco,
            }),
          ).timeout(const Duration(seconds: 15));

          if (response.statusCode == 200) {
            return json.decode(response.body);
          } else {
            throw Exception('Erro ao atualizar fornecedor: ${response.statusCode}');
          }
        } catch (e) {
          throw Exception('Erro ao conectar com a API: $e');
        }
      }

  Future<Map<String, dynamic>> inativarFornecedor(int? id) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'inativarFornecedor',
          'id': id,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao deletar fornecedor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> carregarFornecedor(int id) async {
  final url = Uri.parse('$baseUrl/processa_bdCeet.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'acao': 'carregarFornecedor',
        'id': id,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao carregar fornecedor: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro ao conectar com a API: $e');
  }
  }

  Future<Map<String, dynamic>?> verificarCnpjExistente(String cnpj) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php'); // Adapte a URL
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'acao': 'verificarCnpjExistente','cnpj': cnpj}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Erro ao verificar CNPJ'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Erro de conexão'};
    }
  }

  Future<Map<String, dynamic>?> verificarCnpjExistenteEdicao(String cnpj, int idFornecedor) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'acao': 'verificarCnpjExistenteEdicao', 'cnpj': cnpj, 'id': idFornecedor}), // ADICIONAMOS 'acao'
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Erro ao verificar CNPJ na edição'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Erro de conexão'};
    }
  }


}