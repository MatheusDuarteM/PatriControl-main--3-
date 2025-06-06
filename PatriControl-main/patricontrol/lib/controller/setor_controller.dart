import 'package:flutter/material.dart';
import 'package:patricontrol/model/setor.dart';
import 'package:patricontrol/services/setor_service.dart';

class SetorController extends ChangeNotifier {
  final SetorService _setorService = SetorService();
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController responsavelController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController contatoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<bool> cadastrarSetor(BuildContext context) async {
    final tipo = tipoController.text.trim();
    final nome = nomeController.text.trim();
    final responsavel = responsavelController.text.trim();
    final descricao = descricaoController.text.trim();
    final contato = contatoController.text.trim();
    final email = emailController.text.trim();

    if (tipo.isEmpty || nome.isEmpty || responsavel.isEmpty || descricao.isEmpty || contato.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos corretamente.'), backgroundColor: Colors.red),
      );
      return false;
    }

    final nomeSetorExistente = await _setorService.verificarSetorExistente(nome);

  if (nomeSetorExistente != null) {
      if (nomeSetorExistente.containsKey('exists') && nomeSetorExistente['exists'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O nome informado já está cadastrado.'), backgroundColor: Colors.red),
        );
        return false;
      } else if (nomeSetorExistente.containsKey('status') && nomeSetorExistente['status'] == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao verificar o nome: ${nomeSetorExistente['message'] ?? 'Erro desconhecido'}'), backgroundColor: Colors.red),
        );
        return false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao verificar nome (resposta nula).'), backgroundColor: Colors.red),
      );
      return false;
    }
    try {
      final response = await _setorService.inserirSetor(
        tipo,
        nome,
        responsavel,
        descricao,
        contato,
        email,
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        tipoController.clear();
        nomeController.clear();
        responsavelController.clear();
        descricaoController.clear();
        contatoController.clear();
        emailController.clear();
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar: ${response['message'] ?? 'Erro desconhecido'}'), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar: $e'), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<bool> editarSetor(
    BuildContext context,
    int? id,
    String tipo,
    String nome,
    String responsavel,
    String descricao,
    String contato,
    String email,
  ) async {
    print('Valor de "tipo" recebido no Controller: $tipo');
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do setor inválido para edição.'), backgroundColor: Colors.red),
      );
      return false;
    }

    final nomeExistenteResponse = await _setorService.verificarSetorExistenteEdicao(nome, id);
    if (nomeExistenteResponse != null) {
      if (nomeExistenteResponse.containsKey('exists') && nomeExistenteResponse['exists'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O nome informado já está cadastrado.'), backgroundColor: Colors.red),
        );
        return false;
      } else if (nomeExistenteResponse.containsKey('status') && nomeExistenteResponse['status'] == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao verificar nome: ${nomeExistenteResponse['message'] ?? 'Erro desconhecido'}'), backgroundColor: Colors.red),
        );
        return false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao verificar nome (resposta nula).'), backgroundColor: Colors.red),
      );
      return false;
    }
    try {
      final response = await _setorService.atualizarSetor(
        id,
        tipo,
        nome,
        responsavel,
        descricao,
        contato,
        email,
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Setor atualizado com sucesso!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao editar: ${response['message'] ?? 'Erro desconhecido'}'), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e'), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<List<Setor>> listarSetores({int deletado = 0, String? searchText, String? interno}) async {
  try {
    final response = await _setorService.listarSetor(deletado: deletado, searchText: searchText, tipoFiltro: interno);
    if (response['status'] == 'success' && response['data'] != null && response['data']['setores'] != null) {
      return (response['data']['setores'] as List).map((json) => Setor.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Erro ao carregar setores');
    }
  } catch (e) {
    throw Exception('Erro ao carregar setores: $e');
  }
}

  Future<bool> inativarSetor(BuildContext context, int? id) async {
    try {
      final response = await _setorService.inativarSetor(id);
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Setor inativado com sucesso!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao inativar: ${response['message'] ?? 'Erro desconhecido'}'), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e'), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> verificarNomeExistente(String nome) async {
    try {
      return await _setorService.verificarSetorExistente(nome);
    } catch (e) {
      debugPrint('Erro ao verificar nome no Controller: $e');
      return {'status': 'error', 'message': 'Erro ao verificar nome'};
    }
  }

  Future<Map<String, dynamic>?> verificarNomeExistenteEdicao(String nome, int? id) async {
    try {
      return await _setorService.verificarSetorExistenteEdicao(nome, id!);
    } catch (e) {
      debugPrint('Erro ao verificar nome para edição no Controller: $e');
      return {'status': 'error', 'message': 'Erro ao verificar nome para edição'};
    }
  }
}