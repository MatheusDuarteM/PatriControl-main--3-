// lib/controller/usuario_controller.dart
import 'package:flutter/material.dart';
import 'package:patricontrol/model/usuario.dart'; // Importe seu model Usuario
import '../services/usuario_service.dart'; // Importe seu service UsuarioService
import 'package:intl/intl.dart'; // Para formatar datas
import 'dart:io'; // Para SocketException

class UsuarioController extends ChangeNotifier {
  final UsuarioService _usuarioService = UsuarioService();

  // Mantenha os TextEditingControllers aqui se eles forem usados em outros lugares
  // ou se você quiser que o Controller gerencie o estado do formulário diretamente.
  // Para o fluxo de cadastro, os valores agora virão como parâmetros.
  final TextEditingController nomeUsuarioController = TextEditingController();
  final TextEditingController cpfUsuarioController = TextEditingController();
  final TextEditingController senhaUsuarioController = TextEditingController();
  final TextEditingController confirmarSenhaUsuarioController =
      TextEditingController();
  final TextEditingController dataNascimentoDisplayController =
      TextEditingController();

  // Variáveis de estado para o formulário (ex: data selecionada, tipo de usuário)
  // Essas variáveis podem ser úteis se o Controller tiver que pré-preencher
  // dados ou se tiver telas que interagem com o Controller para selecionar esses valores
  // de forma reativa. Para o fluxo de cadastro atual, os valores vêm via parâmetro.
  DateTime? _dataNascimentoSelecionada;
  String? _tipoUsuarioSelecionado;
  String? _erroGeral; // Para erros que podem ser acessados pela UI

  // Getters para as variáveis de estado
  DateTime? get dataNascimentoSelecionada => _dataNascimentoSelecionada;
  String? get tipoUsuarioSelecionado => _tipoUsuarioSelecionado;
  String? get erroGeral => _erroGeral;

  // Lista de tipos de usuário disponíveis (pode vir de uma constante ou API se necessário)
  final List<String> _tiposDeUsuario = [
    'Administrador',
    'Padrão',
    'Técnico',
    'Visitante'
  ];
  List<String> get tiposDeUsuario => _tiposDeUsuario;

  // Setter para a data de nascimento - pode ser usado se houver um picker de data
  // que atualiza o controller diretamente (e não via parâmetros como no dialog).
  void setDataNascimento(DateTime? date) {
    _dataNascimentoSelecionada = date;
    if (date != null) {
      dataNascimentoDisplayController.text =
          DateFormat('dd/MM/yyyy').format(date);
    } else {
      dataNascimentoDisplayController.clear();
    }
    notifyListeners(); // Notifica os listeners para atualizar a UI
  }

  // Setter para o tipo de usuário - similar ao setDataNascimento.
  void setTipoUsuario(String? tipo) {
    _tipoUsuarioSelecionado = tipo;
    notifyListeners(); // Notifica os listeners para atualizar a UI
  }

  // Limpa todos os campos e estados do formulário
  // Isso é útil se o Controller gerencia os TextEditingControllers diretamente
  // para um formulário na tela principal, por exemplo.
  void clearFormFields() {
    nomeUsuarioController.clear();
    cpfUsuarioController.clear();
    senhaUsuarioController.clear();
    confirmarSenhaUsuarioController.clear();
    dataNascimentoDisplayController.clear();
    _dataNascimentoSelecionada = null;
    _tipoUsuarioSelecionado = null; // Ou defina um valor padrão, se houver
    _erroGeral = null;
    notifyListeners();
  }

  // Método para carregar um único usuário para edição
  Future<Usuario?> carregarUsuario(int idUsuario) async {
    _erroGeral = null; // Limpa erros anteriores
    try {
      final response = await _usuarioService.carregarUsuario(idUsuario);
      if (response['status'] == 'success' && response['data'] != null) {
        final usuario =
            Usuario.fromJson(response['data'] as Map<String, dynamic>);
        _erroGeral = null; // Sucesso, limpa erro
        return usuario;
      } else {
        // Se a API retornar um status de erro, pega a mensagem diretamente
        _erroGeral = response['message'] ?? 'Erro ao carregar usuário.';
        throw Exception(_erroGeral); // Lança para que a UI possa tratar
      }
    } catch (e) {
      String errorMessage = _formatErrorMessage(e);
      _erroGeral = errorMessage;
      notifyListeners();
      throw Exception(_erroGeral); // Lança a exceção com a mensagem limpa
    }
  }

  // MÉTODO ATUALIZADO PARA CADASTRO DE USUÁRIO
  Future<bool> cadastrarUsuario(
    BuildContext context,
    String nome,
    String cpf,
    String senha,
    String confirmarSenha,
    DateTime dataNascimento,
    String tipoUsuario,
  ) async {
    _erroGeral = null; // Limpa erros anteriores

    // Os parâmetros 'nome', 'cpf', 'senha', 'confirmarSenha', 'dataNascimento', 'tipoUsuario'
    // JÁ vêm do CadastroUsuarioDialog, e o CPF já vem sem máscara.
    final cpfSemMascara = cpf; // Já foi desmascarado no Dialog

    // 1. Validações básicas do formulário (agora usando os parâmetros)
    // As validações de is.Empty para nome, cpf, senha já deveriam ter passado
    // no Form.validate() do Dialog. Mas é bom ter uma camada extra de segurança.
    if (nome.isEmpty ||
        cpfSemMascara.isEmpty ||
        dataNascimento == null || // dataNascimento já é non-nullable aqui.
        tipoUsuario.isEmpty) {
      _erroGeral = 'Por favor, preencha todos os campos obrigatórios.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    }

    if (cpfSemMascara.length != 11) {
      _erroGeral = 'CPF inválido. Deve conter 11 dígitos.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    }

    if (senha.isEmpty) { // O validator no Dialog já deveria pegar isso.
      _erroGeral = 'A senha não pode estar vazia.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    }

    // Usando senhas já trimadas para comparação
    if (senha != confirmarSenha) { // O validator no Dialog já deveria pegar isso.
      _erroGeral = 'A senha e a confirmação de senha não coincidem.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    }

    // Validação de comprimento mínimo da senha no cadastro
    if (senha.length < 6) { // O validator no Dialog já deveria pegar isso.
      _erroGeral = 'A senha deve ter pelo menos 6 caracteres.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    }

    try {
      // 2. Chamada ao service para criar usuário
      final response = await _usuarioService.criarUsuario(
        nome: nome,
        senha: senha,
        cpf: cpfSemMascara,
        nasc: dataNascimento,
        tipo: tipoUsuario,
      );

      if (response['status'] == 'success' || response['status'] == 'created') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    response['message'] ?? 'Usuário cadastrado com sucesso!')),
          );
        }
        // Não chame clearFormFields() aqui, pois os controladores pertencem ao diálogo
        // e serão descartados quando o diálogo for fechado.
        return true;
      } else {
        String serverMessage =
            response['message'] ?? 'Erro desconhecido ao cadastrar usuário.';

        // Tenta simplificar a mensagem da API diretamente aqui
        if (serverMessage.contains('CPF já cadastrado')) {
          _erroGeral = 'CPF já cadastrado.'; // Mensagem simplificada
        }
        // Adicione outras condições específicas da API aqui se necessário
        else {
          _erroGeral = serverMessage; // Usa a mensagem original da API
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
          );
        }
        notifyListeners();
        return false; // Retorna false, não lança exceção para erros da API
      }
    } on SocketException catch (e) {
      _erroGeral = 'Erro de conexão: Verifique sua internet ou o servidor.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    } catch (e) {
      _erroGeral =
          'Ocorreu um erro inesperado: ${e.toString()}'; // Fallback para outros erros
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    }
  }

  // Método para editar um usuário existente (mantido como estava, pois ele recebe parâmetros)
  Future<bool> editarUsuario(
    BuildContext context,
    int idUsuario,
    String nome,
    String? novaSenha, // Pode ser null se a senha não for alterada
    String? confirmarNovaSenha, // <--- NOVO PARÂMETRO: Confirmação de senha
    String cpf,
    DateTime nasc,
    String tipo,
  ) async {
    _erroGeral = null; // Limpa erros anteriores

    final cpfSemFormatacao = cpf.replaceAll(RegExp(r'[^\d]'), '');

    // 1. Validações básicas para edição
    if (nome.isEmpty ||
        cpfSemFormatacao.isEmpty ||
        nasc == null ||
        tipo.isEmpty) {
      _erroGeral = 'Por favor, preencha todos os campos obrigatórios.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    }

    if (cpfSemFormatacao.length != 11) {
      _erroGeral = 'CPF inválido. Deve conter 11 dígitos.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    }

    // Validação de nova senha
    if (novaSenha != null && novaSenha.isNotEmpty) {
      // Usar senhas já trimadas para comparação
      if (novaSenha.trim() != confirmarNovaSenha?.trim()) {
        _erroGeral = 'A nova senha e a confirmação de senha não coincidem.';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
          );
        }
        notifyListeners();
        return false;
      }
      // Validação de comprimento mínimo para a nova senha
      if (novaSenha.trim().length < 6) {
        _erroGeral = 'A nova senha deve ter pelo menos 6 caracteres.';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
          );
        }
        notifyListeners();
        return false;
      }
    }

    try {
      // 2. Chamada ao service para atualizar usuário
      final response = await _usuarioService.atualizarUsuario(
        id: idUsuario,
        nome: nome,
        cpf: cpfSemFormatacao,
        nasc: nasc,
        tipo: tipo,
        novaSenha: novaSenha?.trim(),
      );

      if (response['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    response['message'] ?? 'Usuário atualizado com sucesso!')),
          );
        }
        return true;
      } else {
        String serverMessage =
            response['message'] ?? 'Erro desconhecido ao atualizar usuário.';

        if (serverMessage.contains('CPF já cadastrado para outro usuário')) {
          _erroGeral = 'CPF já cadastrado.';
        } else if (serverMessage
            .contains('A nova senha e a confirmação de senha não coincidem')) {
          _erroGeral = 'As senhas não coincidem.';
        }
        else {
          _erroGeral = serverMessage;
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
          );
        }
        notifyListeners();
        return false;
      }
    } on SocketException catch (e) {
      _erroGeral = 'Erro de conexão: Verifique sua internet ou o servidor.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
        return false;
      }
      notifyListeners();
      return false;
    } catch (e) {
      _erroGeral =
          'Ocorreu um erro inesperado: ${e.toString()}';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    }
  }

  // Método para inativar um usuário
  Future<bool> inativarUsuario(BuildContext context, int idUsuario) async {
    _erroGeral = null; // Limpa erros anteriores
    try {
      final response = await _usuarioService.inativarUsuario(idUsuario);
      if (response['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    response['message'] ?? 'Usuário inativado com sucesso!')),
          );
        }
        return true;
      } else {
        _erroGeral =
            response['message'] ?? 'Erro desconhecido ao inativar usuário.';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
          );
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      String errorMessage = _formatErrorMessage(e);
      _erroGeral = errorMessage;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroGeral!), backgroundColor: Colors.red),
        );
      }
      notifyListeners();
      return false;
    }
  }

  Future<List<Usuario>> listarUsuarios(
      {int deletado = 0, String? searchText}) async {
    try {
      final response = await _usuarioService.listarUsuarios(
          deletado: deletado, searchText: searchText);
      if (response['status'] == 'success' && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Usuario.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Erro ao carregar usuarios');
      }
    } catch (e) {
      throw Exception('Erro ao carregar usuarios: $e');
    }
  }

  // Método auxiliar para formatar mensagens de erro de exceções
  String _formatErrorMessage(dynamic e) {
    String errorMessage = e.toString();

    if (e is SocketException) {
      return 'Erro de conexão: Verifique sua internet ou o servidor. Detalhes: ${e.message}';
    } else if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.replaceFirst('Exception: ', '');
    }

    final RegExp regex = RegExp(
        r'\b\d{3}\b - (.+)');
    final match = regex.firstMatch(errorMessage);
    if (match != null && match.groupCount > 0) {
      return match.group(1)!;
    }

    return 'Ocorreu um erro inesperado: $errorMessage';
  }

  @override
  void dispose() {
    // É importante dispor os controllers aqui para evitar vazamento de memória
    nomeUsuarioController.dispose();
    cpfUsuarioController.dispose();
    senhaUsuarioController.dispose();
    confirmarSenhaUsuarioController.dispose();
    dataNascimentoDisplayController.dispose();
    super.dispose();
  }
}