import 'package:flutter/material.dart';

class LastNumbersInputDialog extends StatefulWidget {
  const LastNumbersInputDialog({super.key});

  @override
  State<LastNumbersInputDialog> createState() => _LastNumbersInputDialogState();
}

class _LastNumbersInputDialogState extends State<LastNumbersInputDialog> {
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  String _formatPatrimonio(String input) {
    input = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (input.length > 12) {
      input = input.substring(0, 12);
    }

    int zerosToPad = 12 - input.length;
    return '32' + '0' * zerosToPad + input;
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final String formattedPatrimonio = _formatPatrimonio(_inputController.text);
      Navigator.of(context).pop(formattedPatrimonio); // Retorna o patrimônio formatado
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Últimos Números'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              decoration: const InputDecoration(
                labelText: 'Últimos Números do Patrimônio',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira os últimos números.';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Apenas números são permitidos.';
                }
                return null;
              },
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}