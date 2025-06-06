import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:patricontrol/model/movimentacao.dart';
// Importe seu model Setor se precisar listar setores aqui,
// mas idealmente você usaria um SetorService existente.
// import 'package:patricontrol/model/setor.dart';

class MovimentacaoService {
  // AJUSTE ESTA URL BASE PARA A SUA API
  final String _baseUrl =
      'https://sua-api.com/api'; // Ex: http://localhost:3000/api

  // Método para buscar patrimônios (versão resumida para seleção)
  // Se você já tem um PatrimonioService com uma função similar, use-o.
  Future<List<PatrimonioParaSelecao>> buscarPatrimoniosParaSelecao(
    String termo,
  ) async {
    if (termo.isEmpty) return [];
    try {
      // Adapte o endpoint conforme sua API
      final uri = Uri.parse(
        '$_baseUrl/patrimonios/buscar-para-movimentacao',
      ).replace(queryParameters: {'termo': termo});

      // Adicionar headers de autenticação se necessário
      // final String? token = await SeuServicoDeAuth.getToken();
      // final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

      final response = await http.get(uri /*, headers: headers*/);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        // Supondo que a API retorna { "status": "success", "data": [...] }
        if (decodedResponse is Map &&
            decodedResponse['status'] == 'success' &&
            decodedResponse['data'] != null) {
          final List<dynamic> patrimoniosJson = decodedResponse['data'] as List;
          return patrimoniosJson
              .map(
                (json) => PatrimonioParaSelecao.fromJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
        } else if (decodedResponse is List) {
          // Se a API retorna a lista diretamente
          final List<dynamic> patrimoniosJson = decodedResponse;
          return patrimoniosJson
              .map(
                (json) => PatrimonioParaSelecao.fromJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }
      print(
        'Erro ao buscar patrimônios: ${response.statusCode} ${response.body}',
      );
      return [];
    } catch (e) {
      print('Exceção ao buscar patrimônios: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> listarMovimentacoes(
    Map<String, String?> filtros,
  ) async {
    try {
      final queryParams = Map<String, String>.fromEntries(
        filtros.entries
            .where((entry) => entry.value != null && entry.value!.isNotEmpty)
            .map((e) => MapEntry(e.key, e.value!)),
      );

      final uri = Uri.parse(
        '$_baseUrl/movimentacoes',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      // Adicione headers se necessário
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        // Supondo que a API retorna { "status": "success", "data": { "movimentacoes": [...] } }
        // ou { "status": "success", "data": [...] }
        if (decodedResponse['status'] == 'success') {
          if (decodedResponse['data'] is Map &&
              decodedResponse['data']['movimentacoes'] != null) {
            return {
              'status': 'success',
              'data': decodedResponse['data']['movimentacoes'],
            };
          } else if (decodedResponse['data'] is List) {
            return {'status': 'success', 'data': decodedResponse['data']};
          }
        }
        return {
          'status': 'error',
          'message':
              decodedResponse['message'] ??
              'Resposta inesperada da API ao listar movimentações',
        };
      } else {
        return {
          'status': 'error',
          'message':
              'Erro na API ao listar movimentações: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erro de conexão ao listar movimentações: $e',
      };
    }
  }

  Future<Map<String, dynamic>> cadastrarMovimentacao(
    Map<String, dynamic> dadosMovimentacaoJson,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/movimentacoes');
      // Adicione headers se necessário
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dadosMovimentacaoJson),
      );

      final decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'status': decodedResponse['status'] ?? 'success',
          'message':
              decodedResponse['message'] ??
              'Movimentação cadastrada com sucesso',
        };
      } else {
        return {
          'status': 'error',
          'message':
              decodedResponse['message'] ??
              'Erro ao cadastrar movimentação: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erro de conexão ao cadastrar movimentação: $e',
      };
    }
  }
}
