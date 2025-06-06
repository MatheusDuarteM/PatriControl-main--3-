import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import para debugPrint

import '../services/marca_service.dart';
import '../model/marca.dart';

class MarcaController extends ChangeNotifier {
  final MarcaService _marcaService = MarcaService();
  final TextEditingController nomeCadastroController = TextEditingController();
  final TextEditingController nomeEdicaoController = TextEditingController();

  Future<bool> cadastrarMarca(BuildContext context) async {
    final nome = nomeCadastroController.text.trim();

    // 1. Validação de campo vazio (local na UI, mas também aqui para segurança)
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, digite o nome da marca.'),
            backgroundColor: Colors.red),
      );
      return false;
    }

    // 2. Verificação de nome existente antes de tentar inserir
    try {
      final nomeExistenteResponse =
          await _marcaService.verificarNomeMarcaExistente(nome);

      // --- DEBUG PRINT: Resposta da API para verificarNomeMarcaExistente ---
      debugPrint('>>> DEBUG: Resposta da API (Cadastro) - verificarNomeMarcaExistente: $nomeExistenteResponse');

      // AQUI ESTÁ A MUDANÇA: Acesse 'exists' dentro de 'data'
      if (nomeExistenteResponse['data'] != null && nomeExistenteResponse['data']['exists'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Já existe uma marca com este nome.'),
              backgroundColor: Colors.red),
        );
        return false; // Nome já existe, não prossegue com o cadastro
      }
    } catch (e) {
      // Erro ao verificar nome existente (ex: problema de conexão com a API)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao verificar nome da marca: $e'),
            backgroundColor: Colors.red),
      );
      return false; // Não prossegue com o cadastro devido ao erro na verificação
    }

    // 3. Se o nome não existe, prossegue com a inserção
    try {
      final response = await _marcaService.inserirMarca(nome);
      // --- DEBUG PRINT: Resposta da API para inserirMarca ---
      debugPrint('>>> DEBUG: Resposta da API (Cadastro) - inserirMarca: $response');

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        nomeCadastroController.clear();
        return true; // Sucesso no cadastro
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao cadastrar: ${response['message'] ?? 'Erro desconhecido'}'),
              backgroundColor: Colors.red),
        );
        return false; // Falha no cadastro (API retornou erro)
      }
    } catch (e) {
      // Erro durante a inserção (ex: problema de conexão com a API)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao conectar para cadastrar: $e'),
            backgroundColor: Colors.red),
      );
      return false; // Falha no cadastro devido ao erro de conexão
    }
  }

  Future<bool> editarMarca(BuildContext context, int? id, String nome) async {
    // 1. Validação de ID
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ID da marca inválido para edição.'),
            backgroundColor: Colors.red),
      );
      return false;
    }

    // 2. Validação de campo vazio (local na UI, mas também aqui para segurança)
    if (nome.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, digite o nome da marca.'),
            backgroundColor: Colors.red),
      );
      return false;
    }

    // 3. Verificação de nome existente para edição
    try {
      final nomeExistenteEdicaoResponse =
          await _marcaService.verificarNomeMarcaExistenteEdicao(nome, id);

      // --- DEBUG PRINT: Resposta da API para verificarNomeMarcaExistenteEdicao ---
      debugPrint('>>> DEBUG: Resposta da API (Edição) - verificarNomeMarcaExistenteEdicao: $nomeExistenteEdicaoResponse');

      if (nomeExistenteEdicaoResponse != null) {
        // AQUI ESTÁ A MUDANÇA: Acesse 'exists' dentro de 'data'
        if (nomeExistenteEdicaoResponse['data'] != null && nomeExistenteEdicaoResponse['data']['exists'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Já existe uma marca com este nome.'),
                backgroundColor: Colors.red),
          );
          return false; // Nome já existe, não prossegue com a edição
        } else if (nomeExistenteEdicaoResponse['status'] == 'error') {
          // Erro retornado pela API na verificação
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Erro ao verificar nome: ${nomeExistenteEdicaoResponse['message'] ?? 'Erro desconhecido'}'),
                backgroundColor: Colors.red),
          );
          return false; // Não prossegue devido a erro na verificação
        }
      } else {
        // Resposta nula da verificação
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao verificar nome (resposta nula).'),
              backgroundColor: Colors.red),
        );
        return false; // Não prossegue devido à resposta nula
      }
    } catch (e) {
      // Erro na chamada do serviço de verificação (ex: problema de conexão)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao verificar nome da marca na edição: $e'),
            backgroundColor: Colors.red),
      );
      return false; // Não prossegue devido ao erro na verificação
    }

    // 4. Se o nome é válido, prossegue com a atualização
    try {
      final response = await _marcaService.atualizarMarca(id, nome);
      // --- DEBUG PRINT: Resposta da API para atualizarMarca ---
      debugPrint('>>> DEBUG: Resposta da API (Edição) - atualizarMarca: $response');


      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marca atualizada com sucesso!')),
        );
        return true; // Sucesso na atualização
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao editar: ${response['message'] ?? 'Erro desconhecido'}'),
              backgroundColor: Colors.red),
        );
        return false; // Falha na atualização (API retornou erro)
      }
    } catch (e) {
      // Erro durante a atualização (ex: problema de conexão com a API)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro de conexão para editar: $e'),
            backgroundColor: Colors.red),
      );
      return false; // Falha na atualização devido ao erro de conexão
    }
  }

  // As outras funções permanecem as mesmas
  Future<List<Marca>> listarMarcas({int deletado = 0}) async {
    try {
      final response = await _marcaService.listarMarcas(deletado: deletado);
      // --- DEBUG PRINT: Resposta da API para listarMarcas ---
      debugPrint('>>> DEBUG: Resposta da API (ListarMarcas): $response');

      if (response['status'] == 'success' && response['data'] != null) {
        return (response['data']['marcas'] as List)
            .map((json) => Marca.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Erro ao carregar marcas');
      }
    } catch (e) {
      throw Exception('Erro ao carregar marcas: $e');
    }
  }

  Future<bool> deletarMarca(BuildContext context, int? id) async {
    try {
      final response = await _marcaService.inativarMarca(id!);
      // --- DEBUG PRINT: Resposta da API para inativarMarca ---
      debugPrint('>>> DEBUG: Resposta da API (DeletarMarca): $response');

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marca deletada com sucesso!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao deletar: ${response['message'] ?? 'Erro desconhecido'}'),
              backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro de conexão para deletar: $e'),
            backgroundColor: Colors.red),
      );
      return false;
    }
  }

  // Funções de verificação (pass-through para o service, com tratamento de erro no controller)
  Future<Map<String, dynamic>?> verificarNomeMarcaExistente(String nome) async {
    try {
      return await _marcaService.verificarNomeMarcaExistente(nome);
    } catch (e) {
      debugPrint('>>> DEBUG: Erro ao verificar nome da marca no Controller (catch): $e');
      return {'status': 'error', 'message': 'Erro ao verificar nome da marca'};
    }
  }

  Future<Map<String, dynamic>?> verificarNomeMarcaExistenteEdicao(
      String nome, int? idMarca) async {
    try {
      return await _marcaService.verificarNomeMarcaExistenteEdicao(
          nome, idMarca);
    } catch (e) {
      debugPrint('>>> DEBUG: Erro ao verificar nome da marca na Edição no Controller (catch): $e');
      return {'status': 'error', 'message': 'Erro ao verificar nome da marca'};
    }
  }

  @override
  void dispose() {
    nomeCadastroController.dispose();
    nomeEdicaoController.dispose();
    super.dispose();
  }
}