// lib/services/patrimonio_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Necessário para Uint8List
import 'package:http_parser/http_parser.dart'; // Necessário para MediaType
import 'package:patricontrol/utils/conect.dart'; // Certifique-se de que este caminho está correto
import 'package:patricontrol/model/patrimonio.dart'; // Importe o modelo de Patrimônio

class PatrimonioService {
  final String baseUrl = Conect.getBaseUrl();
  final String _apiPath = '/processa_bdCeet.php'; // Caminho para o seu script PHP

  // --- FUNÇÕES DE INSERÇÃO E ATUALIZAÇÃO (MultipartRequest) ---

  Future<Map<String, dynamic>> inserirPatrimonioPHP({
    required String codigoPatrimonio,
    required String tipoPatrimonio,
    String? descricaoPatrimonio,
    required int setorOrigemId,
    String? nfePatrimonio,
    String? lotePatrimonio,
    String? dataEntrada, // Formato 'YYYY-MM-DD'
    required int idModelo,
    required int idMarca,
    required int idFornecedor,
    Uint8List? imagemBytes, // Opcional: para nova imagem de upload
    String? nomeArquivo,    // Nome do arquivo da imagem, se imagemBytes for fornecido
    String? imagemUrlModelo, // ADICIONADO: URL da imagem do modelo
  }) async {
    final url = Uri.parse('$baseUrl$_apiPath');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['acao'] = 'inserirPatrimonioPHP';
      request.fields['codigo_patrimonio'] = codigoPatrimonio;
      request.fields['tipo_patrimonio'] = tipoPatrimonio;
      request.fields['descricao_patrimonio'] = descricaoPatrimonio ?? ''; // Envia vazio se for null
      request.fields['setor_origem_id'] = setorOrigemId.toString();
      request.fields['nfe_patrimonio'] = nfePatrimonio ?? '';
      request.fields['lote_patrimonio'] = lotePatrimonio ?? '';
      request.fields['dataentrada_patrimonio'] = dataEntrada ?? '';
      request.fields['id_modelo'] = idModelo.toString();
      request.fields['id_marca'] = idMarca.toString();
      request.fields['id_fornecedor'] = idFornecedor.toString();
      // id_setorAtual é definido no PHP como o mesmo que setor_origem_id na inserção
      // status_patrimonio é definido no PHP como 'Alocado'

      // Adiciona a imagem do patrimônio se fornecida
      if (imagemBytes != null && nomeArquivo != null) {
        var multipartFile = http.MultipartFile.fromBytes(
          'imagem_patrimonio', // Nome do campo 'name' no formulário PHP para a imagem do PATRIMÔNIO
          imagemBytes,
          filename: nomeArquivo,
          contentType: MediaType('image', 'jpeg'), // Ajuste conforme o tipo de imagem
        );
        request.files.add(multipartFile);
      }

      // Adiciona a URL da imagem do modelo, se fornecida
      if (imagemUrlModelo != null && imagemUrlModelo.isNotEmpty) {
        request.fields['imagem_url_modelo'] = imagemUrlModelo;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Resposta PHP (inserirPatrimonioPHP): ${response.statusCode} - $responseBody');

      if (responseBody.isEmpty) {
        return {
          'status': 'error',
          'message': 'Resposta vazia do servidor. Verifique os logs do PHP.'
        };
      }

      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = json.decode(responseBody);
      } catch (e) {
        return {
          'status': 'error',
          'message': 'Erro ao decodificar resposta do servidor (não é JSON válido): $responseBody'
        };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['status'] == 'success' ||
            jsonResponse['status'] == 'info' ||
            jsonResponse['status'] == 'created' ||
            jsonResponse['status'] == 'not_found' // O PHP pode retornar not_found com 200 OK
        ) {
          return {
            'status': jsonResponse['status'],
            'message': jsonResponse['message'] ?? 'Operação realizada com sucesso!',
            'data': jsonResponse['data'] // Inclui 'data' se existir
          };
        } else {
          return {
            'status': jsonResponse['status'] ?? 'error',
            'message': jsonResponse['message'] ?? 'Erro desconhecido na API.'
          };
        }
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Erro no servidor (Status: ${response.statusCode})',
          'data': jsonResponse['data'] ?? null // Inclui 'data' se existir (para erros de validação etc)
        };
      }
    } catch (e) {
      print('Erro de conexão ou comunicação ao inserir patrimônio: $e');
      return {
        'status': 'error',
        'message': 'Erro de conexão ou comunicação com o servidor: $e'
      };
    }
  }

  Future<Map<String, dynamic>> atualizarPatrimonioPHP({
    required int idPatrimonio,
    required String codigoPatrimonio,
    required String tipoPatrimonio,
    String? descricaoPatrimonio,
    required int setorOrigemId,
    String? nfePatrimonio,
    String? lotePatrimonio,
    String? dataEntrada, // Formato 'YYYY-MM-DD'
    required int idModelo,
    required int idMarca,
    required int idFornecedor,
    required int idSetorAtual, // Campo explícito para atualização
    Uint8List? imagemBytes, // Opcional: para nova imagem de upload
    String? nomeArquivo,    // Nome do arquivo da imagem, se imagemBytes for fornecido
    required bool imagemFoiAlterada, // Se o usuário selecionou uma nova imagem (ou removeu)
    String? imagemUrlModelo, // ADICIONADO: URL da imagem do modelo
  }) async {
    final url = Uri.parse('$baseUrl$_apiPath');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['acao'] = 'atualizarPatrimonioPHP';
      request.fields['id_patrimonio'] = idPatrimonio.toString();
      request.fields['codigo_patrimonio'] = codigoPatrimonio;
      request.fields['tipo_patrimonio'] = tipoPatrimonio;
      request.fields['descricao_patrimonio'] = descricaoPatrimonio ?? '';
      request.fields['setor_origem_id'] = setorOrigemId.toString();
      request.fields['nfe_patrimonio'] = nfePatrimonio ?? '';
      request.fields['lote_patrimonio'] = lotePatrimonio ?? '';
      request.fields['dataentrada_patrimonio'] = dataEntrada ?? '';
      request.fields['id_modelo'] = idModelo.toString();
      request.fields['id_marca'] = idMarca.toString();
      request.fields['id_fornecedor'] = idFornecedor.toString();
      request.fields['id_setorAtual'] = idSetorAtual.toString();

      // Lógica para a imagem do patrimônio
      if (imagemFoiAlterada) {
        if (imagemBytes != null && nomeArquivo != null) {
          var multipartFile = http.MultipartFile.fromBytes(
            'imagem_patrimonio', // Nome do campo 'name' no formulário PHP para a imagem do PATRIMÔNIO
            imagemBytes,
            filename: nomeArquivo,
            contentType: MediaType('image', 'jpeg'), // Ajuste conforme o tipo
          );
          request.files.add(multipartFile);
        } else {
            // Se imagemFoiAlterada é true, mas imagemBytes é null,
            // isso indica que a imagem do patrimônio deve ser removida no backend.
            request.fields['remover_imagem'] = 'true';
        }
      }
      // Se imagemFoiAlterada for false, não adiciona campo de imagem nem de remoção, mantendo a atual no DB.

      // Adiciona a URL da imagem do modelo, se fornecida
      // IMPORTANTE: A lógica para limpar imagemUrlModelo no backend deve ser tratada
      // pelo campo 'remover_imagem_modelo_url' se você precisar disso explicitamente.
      // Caso contrário, se o id_modelo mudar e a nova URL for null/vazia, o backend
      // deve atualizar para null automaticamente.
      if (imagemUrlModelo != null && imagemUrlModelo.isNotEmpty) {
        request.fields['imagem_url_modelo'] = imagemUrlModelo;
      } else {
        // Se a imagemUrlModelo for explicitamente limpa ou não fornecida,
        // e você quer que isso zere no backend, pode enviar um campo para isso.
        // Por exemplo:
        // request.fields['remover_imagem_modelo_url'] = 'true';
        // A decisão aqui depende do comportamento desejado para imagem_url_modelo
        // no seu backend. Se ela é persistente com o modelo, talvez não precise disso.
        // Se ela é salva por patrimônio e pode ser limpa, então sim.
        // Por ora, vamos garantir que ela seja enviada quando existe.
      }


      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Resposta PHP (atualizarPatrimonioPHP): ${response.statusCode} - $responseBody');

      if (responseBody.isEmpty) {
        return {
          'status': 'error',
          'message': 'Resposta vazia do servidor. Verifique os logs do PHP.'
        };
      }

      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = json.decode(responseBody);
      } catch (e) {
        return {
          'status': 'error',
          'message': 'Erro ao decodificar resposta do servidor (não é JSON válido): $responseBody'
        };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['status'] == 'success' ||
            jsonResponse['status'] == 'info' ||
            jsonResponse['status'] == 'created' ||
            jsonResponse['status'] == 'not_found'
        ) {
          return {
            'status': jsonResponse['status'],
            'message': jsonResponse['message'] ?? 'Operação realizada com sucesso!',
            'data': jsonResponse['data']
          };
        } else {
          return {
            'status': jsonResponse['status'] ?? 'error',
            'message': jsonResponse['message'] ?? 'Erro desconhecido na API.'
          };
        }
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Erro no servidor (Status: ${response.statusCode})',
          'data': jsonResponse['data'] ?? null
        };
      }
    } catch (e) {
      print('Erro de conexão ou comunicação ao atualizar patrimônio: $e');
      return {
        'status': 'error',
        'message': 'Erro de conexão ou comunicação com o servidor: $e'
      };
    }
  }

  // --- FUNÇÕES QUE RECEBEM JSON (POST com body) ---

  Future<Map<String, dynamic>> listarPatrimonios({
    int page = 1,
    int limit = 10,
    int deletado = 0,
    Map<String, dynamic>? filtros, // Map para filtros adicionais
  }) async {
    final url = Uri.parse('$baseUrl$_apiPath');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'listarPatrimoniosPHP',
          'page': page,
          'limit': limit,
          'deletado': deletado,
          'filtros': filtros ?? {}, // Envia um map vazio se não houver filtros
        }),
      ).timeout(const Duration(seconds: 20)); // Aumentado timeout para listagens maiores

      print('Resposta PHP (listarPatrimonios): ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = json.decode(response.body);
        return responseJson;
      } else {
        return {
          'status': 'error',
          'message': 'Erro no servidor (${response.statusCode}): ${response.body}',
          'data': null
        };
      }
    } catch (e) {
      print('Erro ao conectar com a API (listarPatrimonios): $e');
      return {
        'status': 'error',
        'message': 'Erro de comunicação: ${e.toString()}',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> carregarPatrimonio(int idPatrimonio) async {
    final url = Uri.parse('$baseUrl$_apiPath');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'carregarPatrimonioPHP',
          'id_patrimonio': idPatrimonio,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Resposta PHP (carregarPatrimonio): ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Erro no servidor (${response.statusCode}): ${response.body}',
          'data': null
        };
      }
    } catch (e) {
      print('Erro ao conectar com a API (carregarPatrimonio): $e');
      return {
        'status': 'error',
        'message': 'Erro de comunicação: ${e.toString()}',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> inativarPatrimonio(int idPatrimonio) async {
    final url = Uri.parse('$baseUrl$_apiPath');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'inativarPatrimonioPHP',
          'id_patrimonio': idPatrimonio,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Resposta PHP (inativarPatrimonio): ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Erro no servidor (${response.statusCode}): ${response.body}',
          'data': null
        };
      }
    } catch (e) {
      print('Erro ao conectar com a API (inativarPatrimonio): $e');
      return {
        'status': 'error',
        'message': 'Erro de comunicação: ${e.toString()}',
        'data': null
      };
    };
  }

  Future<Map<String, dynamic>> verificarCodigoPatrimonioExistente(String codigoPatrimonio) async {
    final url = Uri.parse('$baseUrl$_apiPath');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'verificarCodigoPatrimonioExistentePHP',
          'codigo_patrimonio': codigoPatrimonio,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Resposta PHP (verificarCodigoPatrimonioExistente): ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Erro no servidor (${response.statusCode}): ${response.body}',
          'data': null
        };
      }
    } catch (e) {
      print('Erro ao conectar com a API (verificarCodigoPatrimonioExistente): $e');
      return {
        'status': 'error',
        'message': 'Erro de comunicação: ${e.toString()}',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> verificarCodigoPatrimonioExistenteEdicao(
    String codigoPatrimonio,
    int idPatrimonio,
  ) async {
    final url = Uri.parse('$baseUrl$_apiPath');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'verificarCodigoPatrimonioExistenteEdicaoPHP',
          'codigo_patrimonio': codigoPatrimonio,
          'id_patrimonio': idPatrimonio,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Resposta PHP (verificarCodigoPatrimonioExistenteEdicao): ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Erro no servidor (${response.statusCode}): ${response.body}',
          'data': null
        };
      }
    } catch (e) {
      print('Erro ao conectar com a API (verificarCodigoPatrimonioExistenteEdicao): $e');
      return {
        'status': 'error',
        'message': 'Erro de comunicação: ${e.toString()}',
        'data': null
      };
    }
  }
}