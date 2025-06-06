// lib/ui/editar_marca_dialog.dart
import 'package:flutter/material.dart';
import 'package:patricontrol/controller/marca_controller.dart';
import 'package:patricontrol/model/marca.dart';
import 'package:provider/provider.dart';

class EditarMarcaDialog extends StatefulWidget {
  final Marca marca;

  const EditarMarcaDialog({super.key, required this.marca});

  @override
  State<EditarMarcaDialog> createState() => _EditarMarcaDialogState();
}

class _EditarMarcaDialogState extends State<EditarMarcaDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.marca.nome_marca;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final marcaController = Provider.of<MarcaController>(context, listen: false);

    return AlertDialog(
      title: const Text('Editar Marca'),
      content: SingleChildScrollView(
        child: Form( // Envolva com o widget Form
          key: _formKey, // Associe a _formKey ao Form
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField( // Use TextFormField para ter a funcionalidade de validação
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Marca',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome da marca não pode estar vazio.';
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
            if (_formKey.currentState!.validate()) { // Valide o formulário
              final nome = _nomeController.text.trim();
              final sucesso =
                  await marcaController.editarMarca(context, widget.marca.id_marca, nome);
              if (sucesso) {
                Navigator.of(context).pop(true); // Indica que a edição foi bem-sucedida
              }
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}