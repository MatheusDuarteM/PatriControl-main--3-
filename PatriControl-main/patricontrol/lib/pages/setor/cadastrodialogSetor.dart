import 'package:flutter/material.dart';
import 'package:patricontrol/controller/setor_controller.dart';

class CadastroSetorDialog extends StatefulWidget {
  const CadastroSetorDialog({super.key});

  @override
  State<CadastroSetorDialog> createState() => _CadastroSetorDialogState();
}

class _CadastroSetorDialogState extends State<CadastroSetorDialog> {

  final _formKey = GlobalKey<FormState>();
  final _setorController = SetorController(); // Instancia o controller
  bool _isLoading = false;
  String? _tipoSelecionado;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastro Setor'),
      content: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 300, minWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  value: _tipoSelecionado,
                  items: <String>['Interno', 'Externo']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione o tipo do setor';
                    }
                    return null;
                  },
                  onChanged: (String? newValue) {
                    setState(() {
                      _tipoSelecionado = newValue;
                      _setorController.tipoController.text = newValue ?? '';
                    });
                  },
                ),
                TextFormField(
                  controller: _setorController.nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o nome do setor';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _setorController.responsavelController,
                  decoration: const InputDecoration(labelText: 'Responsavel'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o nome do responsavel';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _setorController.descricaoController,
                  decoration: const InputDecoration(labelText: 'Descricao'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite a descricao';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _setorController.contatoController,
                  decoration: const InputDecoration(labelText: 'Contato'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o contato do setor';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _setorController.emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true; // Se você tiver um indicador de carregamento
                            });

                            final sucesso = await _setorController.cadastrarSetor(context);

                            setState(() {
                              _isLoading = false; // Se você tiver um indicador de carregamento
                            });

                            if (sucesso) {
                              Navigator.of(context).pop(true); // Retorna true para a tela da lista
                            }
                            // Se 'sucesso' for false, o SnackBar já foi mostrado no controller
                          }
                      },
                      child: _isLoading ? const CircularProgressIndicator() : const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}