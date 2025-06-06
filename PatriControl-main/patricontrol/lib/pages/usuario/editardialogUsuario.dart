// lib/pages/usuario/editarusuario_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:patricontrol/controller/usuario_controller.dart';
import '../../model/usuario.dart';
import 'package:patricontrol/utils/Validadores/cpf_validator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditarUsuarioDialog extends StatefulWidget {
  final Usuario usuario;

  const EditarUsuarioDialog({Key? key, required this.usuario})
      : super(key: key);

  @override
  State<EditarUsuarioDialog> createState() => _EditarUsuarioDialogState();
}

class _EditarUsuarioDialogState extends State<EditarUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  late UsuarioController _usuarioController;
  bool _isEditing = false;
  bool _isLoading = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final TextEditingController _dataNascimentoDisplayController =
      TextEditingController();

  DateTime? _dataNascimentoAtual;
  String? _tipoUsuarioAtual;

  final MaskTextInputFormatter _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    _usuarioController = Provider.of<UsuarioController>(context, listen: false);
    _populateFields();
  }

  void _populateFields() {
    _nomeController.text = widget.usuario.nomeUsuario;
    _cpfController.text = _cpfFormatter.maskText(widget.usuario.cpfUsuario);

    _dataNascimentoAtual = widget.usuario.nascUsuario;
    _dataNascimentoDisplayController.text =
        DateFormat('dd/MM/yyyy').format(_dataNascimentoAtual!);

    // Ajuste para o Dropdown: Garante que o valor inicial seja válido
    final String tipoUsuarioDaAPI = widget.usuario.tipoUsuario;
    if (_usuarioController.tiposDeUsuario.contains(tipoUsuarioDaAPI)) {
      _tipoUsuarioAtual = tipoUsuarioDaAPI;
    } else {
      // Se o tipo vindo da API não for encontrado na sua lista local,
      // você pode definir um valor padrão que exista na lista,
      // ou o primeiro da lista, ou null se seu Dropdown permitir null
      // e lidar com o estado "vazio" na UI.
      // Exemplo: _tipoUsuarioAtual = _usuarioController.tiposDeUsuario.first;
      _tipoUsuarioAtual = null; // Mantendo como null para ser explícito se não houver correspondência
    }
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

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _senhaController.clear();
        _confirmarSenhaController.clear();
      }
    });
  }

  Future<void> _salvarUsuario(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String cpfSemFormatacao =
          _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');

      String? novaSenha = _senhaController.text.trim().isEmpty
          ? null
          : _senhaController.text.trim();

      // Pegue o valor da confirmação de senha
      String? confirmarNovaSenha = _confirmarSenhaController.text.trim().isEmpty
          ? null
          : _confirmarSenhaController.text.trim();

      try {
        final sucesso = await _usuarioController.editarUsuario(
          context,
          widget.usuario.idUsuario!,
          _nomeController.text.trim(),
          novaSenha, // novaSenha já está com .trim() se não for nula
          confirmarNovaSenha, // <--- NOVO: Passa o valor da confirmação de senha
          cpfSemFormatacao,
          _dataNascimentoAtual!,
          _tipoUsuarioAtual!,
        );

        if (!mounted) return;

        if (sucesso) {
          Navigator.of(context).pop(true);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ${widget.usuario.nomeUsuario}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 300, minWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nomeController,
                  enabled: _isEditing,
                  decoration:
                      const InputDecoration(labelText: 'Nome Completo *'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) { // Adicionado .trim()
                      return 'Por favor, digite o nome do usuário.';
                    }
                    // Validação de nome completo (pelo menos duas palavras)
                    final names = value.trim().split(RegExp(r'\s+'));
                    if (names.length < 2 || names.any((name) => name.isEmpty)) {
                      return 'Por favor, insira pelo menos nome e sobrenome.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _cpfController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'CPF *'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfFormatter],
                  validator: (value) {
                    // CpfValidator.validate já deve lidar com trim internamente
                    // mas podemos garantir que o valor passado é trimado
                    return CpfValidator.validate(value?.trim()); 
                  },
                ),
                TextFormField(
                  controller: _dataNascimentoDisplayController,
                  decoration: InputDecoration(
                    labelText: 'Data de Nascimento *',
                    suffixIcon: _isEditing
                        ? IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    _dataNascimentoAtual ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null &&
                                  picked != _dataNascimentoAtual) {
                                setState(() {
                                  _dataNascimentoAtual = picked;
                                  _dataNascimentoDisplayController.text =
                                      DateFormat('dd/MM/yyyy').format(picked);
                                });
                              }
                            },
                          )
                        : null,
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (_dataNascimentoAtual == null) {
                      return 'Por favor, selecione a data de nascimento.';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _tipoUsuarioAtual,
                  decoration:
                      const InputDecoration(labelText: 'Tipo de Usuário *'),
                  items: _usuarioController.tiposDeUsuario.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: _isEditing
                      ? (String? newValue) {
                          setState(() {
                            _tipoUsuarioAtual = newValue;
                          });
                        }
                      : null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione o tipo de usuário.';
                    }
                    return null;
                  },
                ),
                if (_isEditing) ...[
                  TextFormField(
                    controller: _senhaController,
                    decoration: const InputDecoration(
                        labelText: 'Nova Senha (opcional)'),
                    obscureText: true,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          value.trim().length < 6) { // Adicionado .trim()
                        return 'A senha deve ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmarSenhaController,
                    decoration: const InputDecoration(
                        labelText: 'Confirmar Nova Senha'),
                    obscureText: true,
                    validator: (value) {
                      // Adicionado .trim() em ambas as comparações
                      if (_senhaController.text.trim().isNotEmpty &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Por favor, confirme a nova senha.';
                      }
                      if (value != null &&
                          value.trim() != _senhaController.text.trim()) { // Adicionado .trim()
                        return 'As senhas não coincidem.';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        if (!_isEditing)
          TextButton(
            onPressed: _toggleEdit,
            child: const Text('Editar'),
          ),
        if (_isEditing)
          TextButton(
            onPressed: _isLoading ? null : () => _salvarUsuario(context),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Salvar'),
          ),
      ],
    );
  }
}