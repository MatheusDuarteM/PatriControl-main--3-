// lib/services/marca_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:patricontrol/utils/conect.dart';

class MarcaService {
  final String baseUrl = Conect.getBaseUrl();

  Future<Map<String, dynamic>> inserirMarca(String nome) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'inserirMarca',
          'nome_marca': nome,
        }),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
         print('Corpo da resposta da API (inserirMarca): ${response.body}');
        try {
          return json.decode(response.body);
        } catch (e) {
          print('Erro ao decodificar JSON na inserção: $e');
          return {'status': 'error', 'message': 'Erro ao decodificar a resposta da API'};
        }
      } else {
        throw Exception('Erro ao inserir marca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
}

  Future<Map<String, dynamic>> listarMarcas({int deletado = 0}) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'listarMarcas',
          'deletado_marca': deletado,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao listar Marcas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> atualizarMarca(
      int? id,
      String nome,
      ) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'atualizarMarca',
          'id_marca': id,
          'nome_marca': nome,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao atualizar Marca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> inativarMarca(int id) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'inativarMarca',
          'id_marca': id,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao inativar a Marca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> carregarMarca(int id) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'carregarMarca',
          'id_marca': id,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar Marca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> verificarNomeMarcaExistente(String nome) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'verificarNomeMarcaExistente',
          'nome_marca': nome,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao verificar nome da marca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>?> verificarNomeMarcaExistenteEdicao(String nome, int? idMarca) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'acao': 'verificarNomeMarcaExistenteEdicao', 'nome_marca': nome, 'id_marca': idMarca}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Erro ao verificar nome da marca na edição'};
      }
    } catch (e) {
      print('Erro de conexão ao verificar nome da marca na edição: $e');
      return {'status': 'error', 'message': 'Erro de conexão'};
    }
  }
}