import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:patricontrol/utils/conect.dart';

class ModeloService {
  final String baseUrl = Conect.getBaseUrl();

  Future<Map<String, dynamic>> inserirModeloPHP(
    String nome,
    String cor,
    String? descricao, {
    Uint8List? imagemBytes,
    String? nomeArquivo,
  }) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['acao'] = 'inserirModeloPHP';
      request.fields['nome_modelo'] = nome;
      request.fields['cor_modelo'] = cor;
      request.fields['descricao_modelo'] = descricao ?? '';

      if (imagemBytes != null && nomeArquivo != null) {
        var stream = Stream<List<int>>.fromIterable([imagemBytes]);
        var length = imagemBytes.length;
        var multipartFile = http.MultipartFile(
          'imagem_modelo',
          stream,
          length,
          filename: nomeArquivo,
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Erro ao inserir modelo: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> atualizarModelo(
    int idModelo,
    String nomeModelo,
    String corModelo,
    String? descricaoModelo,
    Uint8List? imagemBytes, {
    String? nomeArquivo, // Mantenha este, se você passar o nome do arquivo do XFile
    required bool imagemFoiAlterada, // Se o usuário selecionou uma nova imagem (ou removeu)
    bool sinalizarRemocaoImagem = false, // <--- ADIÇÃO AQUI: NOVA FLAG
  }) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['acao'] = 'atualizarModeloPHP';
      request.fields['id_modelo'] = idModelo.toString();
      request.fields['nome_modelo'] = nomeModelo;
      request.fields['cor_modelo'] = corModelo;
      if (descricaoModelo != null) {
        request.fields['descricao_modelo'] = descricaoModelo;
      }

      // <--- ALTERAÇÃO PRINCIPAL AQUI (LÓGICA DA IMAGEM) --->
      if (imagemFoiAlterada) {
        if (imagemBytes != null && nomeArquivo != null) {
          // Caso 1: Nova imagem selecionada (e você tem os bytes e o nome)
          var multipartFile = http.MultipartFile.fromBytes(
            'imagem_modelo',
            imagemBytes,
            filename: nomeArquivo, // Usando o nomeArquivo passado
            contentType: MediaType('image', 'jpeg'), // Ajuste o tipo se necessário (png, etc.)
          );
          request.files.add(multipartFile);
        } else if (sinalizarRemocaoImagem) {
          // Caso 2: Usuário clicou em remover a imagem
          request.fields['imagem_modelo_removida'] = 'true'; // Sinaliza ao PHP para remover
        }
        // Caso 3: imagemFoiAlterada é true, mas imagemBytes é null e NÃO sinalizou remoção.
        // Isso seria um cenário de erro ou intenção ambígua. Não adicionamos nada para a imagem,
        // o PHP não alterará a imagem. Você pode adicionar um `throw` aqui se for um erro crítico.
      }
      // Se imagemFoiAlterada for false, NENHUM CAMPO RELACIONADO À IMAGEM É ADICIONADO.
      // Isso indica ao PHP para MANTER a imagem existente no servidor.
      // <--- FIM DA ALTERAÇÃO PRINCIPAL (LÓGICA DA IMAGEM) --->


      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // <--- ADIÇÃO AQUI PARA DEPURAR E TRATAR RESPOSTAS VAZIAS/INVÁLIDAS --->
      print('Resposta PHP (atualizarModelo): $responseBody'); // Ajuda na depuração!

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
          'message':
              'Erro ao decodificar resposta do servidor (não é JSON válido): $responseBody'
        };
      }
      // <--- FIM DA ADIÇÃO PARA DEPURAR E TRATAR RESPOSTAS VAZIAS/INVÁLIDAS --->


      // <--- ALTERAÇÃO AQUI (TRATAMENTO DE STATUS DA API) --->
      if (response.statusCode == 200) {
        // Assume que o PHP sempre retorna 'status' e 'message'
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
          // Se o status HTTP é 200, mas o status da API é 'error_client', 'error_server', etc.
          return {
            'status': jsonResponse['status'] ?? 'error',
            'message': jsonResponse['message'] ?? 'Erro desconhecido na API.'
          };
        }
      } else {
        // Se o status HTTP não é 200 (ex: 404, 500)
        return {
          'status': 'error',
          'message':
              jsonResponse['message'] ?? 'Erro no servidor (Status: ${response.statusCode})'
        };
      }
      // <--- FIM DA ALTERAÇÃO (TRATAMENTO DE STATUS DA API) --->

    } catch (e) {
      // Captura erros de rede, timeout, etc.
      print('Erro de conexão ou comunicação ao atualizar modelo: $e');
      return {
        'status': 'error',
        'message': 'Erro de conexão ou comunicação com o servidor: $e'
      };
    }
  }

  Future<Map<String, dynamic>> listarModelos({
    int deletado = 0,
    String? filtroNome,
}) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
        final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode({
                'acao': 'listarModelosPHP',
                'deletado': deletado,
                if (filtroNome != null && filtroNome.isNotEmpty) 'filtro_nome_modelo': filtroNome,
            }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
            return json.decode(response.body);
        } else {
            throw Exception('Erro ao listar modelos: ${response.statusCode}');
        }
    } catch (e) {
        throw Exception('Erro ao conectar com a API: $e');
    }
}

  Future<Map<String, dynamic>> inativarModelo(int idModelo) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'inativarModeloPHP',
          'id_modelo': idModelo,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao inativar modelo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> carregarModelo(int idModelo) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'carregarModeloPHP',
          'id_modelo': idModelo,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar modelo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> verificarNomeModeloExistente(String nomeModelo) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'verificarNomeModeloExistente',
          'nome_modelo': nomeModelo,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao verificar nome do modelo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> verificarNomeModeloExistenteEdicao(int idModelo, String nomeModelo) async {
    final url = Uri.parse('$baseUrl/processa_bdCeet.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'acao': 'verificarNomeModeloExistenteEdicao',
          'id_modelo': idModelo,
          'nome_modelo': nomeModelo,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao verificar nome do modelo para edição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }
}