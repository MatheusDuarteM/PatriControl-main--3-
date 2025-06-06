import 'package:flutter/material.dart';
import 'package:patricontrol/model/fornecedor.dart';
import '../services/fornecedor_service.dart';
import 'modelo_controller.dart';

class FornecedorController extends ChangeNotifier {
  final FornecedorService _fornecedorService = FornecedorService();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();
  final TextEditingController contatoController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();

  Future<bool> cadastrarFornecedor(BuildContext context) async {
    final nome = nomeController.text.trim();
    final cnpjComFormatacao = cnpjController.text.trim();
    final cnpjSemFormatacao = cnpjComFormatacao.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final contato = contatoController.text.trim();
    final endereco = enderecoController.text.trim();

    if (nome.isEmpty ||
        cnpjSemFormatacao.isEmpty ||
        cnpjSemFormatacao.length != 14 ||
        contato.isEmpty ||
        endereco.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos corretamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final cnpjExistenteResponse = await _fornecedorService
        .verificarCnpjExistente(cnpjSemFormatacao);
    print(
      'Resposta verificarCnpjExistente no Controller: $cnpjExistenteResponse',
    );

    if (cnpjExistenteResponse != null) {
      if (cnpjExistenteResponse.containsKey('exists') &&
          cnpjExistenteResponse['exists'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O CNPJ informado já está cadastrado.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      } else if (cnpjExistenteResponse.containsKey('status') &&
          cnpjExistenteResponse['status'] == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao verificar CNPJ: ${cnpjExistenteResponse['message'] ?? 'Erro desconhecido'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao verificar CNPJ (resposta nula).'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    try {
      final response = await _fornecedorService.inserirFornecedor(
        nome,
        cnpjSemFormatacao,
        contato,
        endereco,
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'])));
        nomeController.clear();
        cnpjController.clear();
        contatoController.clear();
        enderecoController.clear();
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao cadastrar: ${response['message'] ?? 'Erro desconhecido'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao conectar: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> editarFornecedor(
    BuildContext context,
    int? id,
    String nome,
    String cnpj,
    String contato,
    String endereco,
  ) async {
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID do fornecedor inválido para edição.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final cnpjExistenteResponse = await _fornecedorService
        .verificarCnpjExistenteEdicao(cnpj, id);
    if (cnpjExistenteResponse != null) {
      if (cnpjExistenteResponse.containsKey('exists') &&
          cnpjExistenteResponse['exists'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O CNPJ informado já está cadastrado.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      } else if (cnpjExistenteResponse.containsKey('status') &&
          cnpjExistenteResponse['status'] == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao verificar CNPJ: ${cnpjExistenteResponse['message'] ?? 'Erro desconhecido'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao verificar CNPJ (resposta nula).'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    try {
      final response = await _fornecedorService.atualizarFornecedor(
        id,
        nome,
        cnpj,
        contato,
        endereco,
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fornecedor atualizado com sucesso!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao editar: ${response['message'] ?? 'Erro desconhecido'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<List<Fornecedor>> listarFornecedores({int deletado = 0}) async {
    try {
      final response = await _fornecedorService.listarFornecedores(deletado);
      if (response['status'] == 'success' && response['data'] != null) {
        // AQUI ESTÁ A CORREÇÃO!
        // Como o backend agora retorna data: { "fornecedores": [...] },
        // você precisa acessar a lista dentro da chave 'fornecedores'.
        final List<dynamic> fornecedoresJsonList =
            response['data']['fornecedores'] as List;

        return fornecedoresJsonList
            .map((json) => Fornecedor.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Erro ao carregar fornecedores');
      }
    } catch (e) {
      throw Exception('Erro ao carregar fornecedores: $e');
    }
  }

  Future<bool> inativarFornecedor(BuildContext context, int? id) async {
    try {
      final response = await _fornecedorService.inativarFornecedor(id);
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fornecedor inativado com sucesso!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao inativar: ${response['message'] ?? 'Erro desconhecido'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> verificarCnpjExistente(String cnpj) async {
    try {
      return await _fornecedorService.verificarCnpjExistente(cnpj);
    } catch (e) {
      debugPrint('Erro ao verificar CNPJ no Controller: $e');
      return {'status': 'error', 'message': 'Erro ao verificar CNPJ'};
    }
  }

  Future<Map<String, dynamic>?> verificarCnpjExistenteEdicao(
    String cnpj,
    int? idFornecedor,
  ) async {
    try {
      return await _fornecedorService.verificarCnpjExistenteEdicao(
        cnpj,
        idFornecedor!,
      );
    } catch (e) {
      debugPrint('Erro ao verificar CNPJ para edição no Controller: $e');
      return {
        'status': 'error',
        'message': 'Erro ao verificar CNPJ para edição',
      };
    }
  }
}
