// lib/ui/cadastro_marca_dialog.dart
import 'package:flutter/material.dart';
import 'package:patricontrol/controller/marca_controller.dart';
import 'package:provider/provider.dart';

class CadastroMarcaDialog extends StatefulWidget {
  const CadastroMarcaDialog({super.key});

  @override
  State<CadastroMarcaDialog> createState() => _CadastroMarcaDialogState();
}

class _CadastroMarcaDialogState extends State<CadastroMarcaDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final marcaController =
        Provider.of<MarcaController>(context, listen: false);

    return AlertDialog(
      title: const Text('Cadastrar Marca'),
      content: SingleChildScrollView(
        child: Form( // Adicione o widget Form aqui
          key: _formKey, // Associe a _formKey ao Form
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: marcaController.nomeCadastroController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Marca',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              setState(() {
                _isLoading = true;
              });

              final sucesso =
                  await marcaController.cadastrarMarca(context);

              setState(() {
                _isLoading = false;
              });

              if (sucesso) {
                Navigator.of(context).pop(true);
              }
            }
          },
          child: _isLoading ? const CircularProgressIndicator() : const Text('Salvar'),
        ),
      ],
    );
  }
}