// lib/pages/usuario/cadastrodialogUsuario.dart
import 'package:flutter/material.dart';
import 'package:patricontrol/controller/usuario_controller.dart'; // Importe o controller
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

class CadastroUsuarioDialog extends StatefulWidget {
  const CadastroUsuarioDialog({super.key});

  @override
  State<CadastroUsuarioDialog> createState() => _CadastroUsuarioDialogState();
}

class _CadastroUsuarioDialogState extends State<CadastroUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _dataNascimentoDisplayController = TextEditingController();
  DateTime? _dataNascimentoSelecionada;
  String? _tipoUsuarioSelecionado;

  final MaskTextInputFormatter _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  late UsuarioController _usuarioController; // Adicionado

  @override
  void initState() {
    super.initState();
    _usuarioController = Provider.of<UsuarioController>(context, listen: false);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _dataNascimentoDisplayController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataNascimento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimentoSelecionada ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataNascimentoSelecionada) {
      setState(() {
        _dataNascimentoSelecionada = picked;
        _dataNascimentoDisplayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _cadastrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      final String nome = _nomeController.text.trim(); // Coleta o nome
      final String cpf = _cpfFormatter.unmaskText(_cpfController.text); // Coleta o CPF sem máscara
      final String senha = _senhaController.text; // Coleta a senha
      final String confirmarSenha = _confirmarSenhaController.text; // Coleta a confirmação de senha
      final DateTime? dataNascimento = _dataNascimentoSelecionada; // Coleta a data
      final String? tipoUsuario = _tipoUsuarioSelecionado; // Coleta o tipo

      // Validações adicionais para garantir que data e tipo não são nulos antes de passar
      if (dataNascimento == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Por favor, selecione a data de nascimento.'),
                backgroundColor: Colors.red),
          );
        }
        return;
      }

      if (tipoUsuario == null || tipoUsuario.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Por favor, selecione o tipo de usuário.'),
                backgroundColor: Colors.red),
          );
        }
        return;
      }

      // ATENÇÃO: AQUI ESTÁ A MUDANÇA PRINCIPAL
      // Chame o método cadastrarUsuario do controller passando TODOS os parâmetros
      final sucesso = await _usuarioController.cadastrarUsuario(
        context,
        nome, // Passa o nome coletado
        cpf,  // Passa o CPF sem máscara coletado
        senha, // Passa a senha coletada
        confirmarSenha, // Passa a confirmação de senha coletada
        dataNascimento, // Passa a data de nascimento coletada
        tipoUsuario, // Passa o tipo de usuário coletado
      );

      if (!mounted) return;

      if (sucesso) {
        Navigator.of(context).pop(true);
      }
      // Se `sucesso` for falso, o `UsuarioController` já exibiu o SnackBar.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastro de Usuário'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Completo *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome completo.';
                  }
                  final names = value.trim().split(RegExp(r'\s+'));
                  if (names.length < 2 || names.any((name) => name.isEmpty)) {
                    return 'Por favor, insira pelo menos nome e sobrenome.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: 'CPF *'),
                keyboardType: TextInputType.number,
                inputFormatters: [_cpfFormatter],
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 14) { // 14 é o comprimento com máscara
                    return 'Por favor, insira um CPF válido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dataNascimentoDisplayController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento *',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selecionarDataNascimento(context),
                  ),
                ),
                validator: (value) {
                  if (_dataNascimentoSelecionada == null) {
                    return 'Por favor, selecione a data de nascimento.';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _tipoUsuarioSelecionado,
                decoration: const InputDecoration(labelText: 'Tipo de Usuário *'),
                // Acessa os tipos de usuário do controller
                items: _usuarioController.tiposDeUsuario.map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoUsuarioSelecionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o tipo de usuário.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha *'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha.';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmarSenhaController,
                decoration: const InputDecoration(labelText: 'Confirmar Senha *'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme a senha.';
                  }
                  if (value != _senhaController.text) {
                    return 'As senhas não coincidem.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _cadastrarUsuario,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}