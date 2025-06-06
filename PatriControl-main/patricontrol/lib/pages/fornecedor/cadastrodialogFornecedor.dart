import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:patricontrol/controller/fornecedor_controller.dart';
import 'package:patricontrol/utils/Validadores/cnpj_validator.dart';

class CadastroFornecedorDialog extends StatefulWidget {
  const CadastroFornecedorDialog({super.key});

  @override
  State<CadastroFornecedorDialog> createState() => _CadastroFornecedorDialogState();
}

class _CadastroFornecedorDialogState extends State<CadastroFornecedorDialog> {

  final _formKey = GlobalKey<FormState>();
  final _fornecedorController = FornecedorController(); // Instancia o controller
  bool _isLoading = false;

  final MaskTextInputFormatter _cnpjFormatter = MaskTextInputFormatter(
  mask: '##.###.###/####-##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastro Fornecedor'),
      content: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 300, minWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _fornecedorController.nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o nome do fornecedor';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _fornecedorController.cnpjController,
                  decoration: const InputDecoration(labelText: 'CNPJ'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cnpjFormatter],
                  validator: CnpjValidator.validate,
                ),
                TextFormField(
                  controller: _fornecedorController.contatoController,
                  decoration: const InputDecoration(labelText: 'Contato'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o contato';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _fornecedorController.enderecoController,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o endereço';
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

                            final sucesso = await _fornecedorController.cadastrarFornecedor(context);

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