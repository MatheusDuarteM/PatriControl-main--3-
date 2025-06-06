import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:patricontrol/controller/fornecedor_controller.dart';
import '../../model/fornecedor.dart';
import 'package:provider/provider.dart';


class EditarFornecedorDialog extends StatefulWidget {
  final Fornecedor fornecedor;

  const EditarFornecedorDialog({Key? key, required this.fornecedor}) : super(key: key);

  @override
  State<EditarFornecedorDialog> createState() => _EditarFornecedorDialogState();
}

class _EditarFornecedorDialogState extends State<EditarFornecedorDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _contatoController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  bool _isEditing = false;

  final MaskTextInputFormatter _cnpjFormatter = MaskTextInputFormatter(
  mask: '##.###.###/####-##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.fornecedor.nome_fornecedor;
    _cnpjController.text = widget.fornecedor.cnpj_fornecedor;
    _contatoController.text = widget.fornecedor.contato_fornecedor ?? '';
    _enderecoController.text = widget.fornecedor.endereco_fornecedor ?? '';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _contatoController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

 Future<void> _salvarFornecedor(BuildContext context) async {
  if (_formKey.currentState!.validate()) {
    final fornecedorController = Provider.of<FornecedorController>(context, listen: false);
    final cnpjSemFormatacao = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Verificar se o CNPJ foi alterado
    if (cnpjSemFormatacao != widget.fornecedor.cnpj_fornecedor) {
      final cnpjExistenteResponse = await fornecedorController.verificarCnpjExistenteEdicao(cnpjSemFormatacao, widget.fornecedor.id_fornecedor!);
      if (cnpjExistenteResponse != null && cnpjExistenteResponse.containsKey('exists') && cnpjExistenteResponse['exists'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O CNPJ informado já está cadastrado.'), backgroundColor: Colors.red),
        );
        return; // Não salva se o CNPJ já existe em outro fornecedor
      } else if (cnpjExistenteResponse != null && cnpjExistenteResponse.containsKey('status') && cnpjExistenteResponse['status'] == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao verificar CNPJ: ${cnpjExistenteResponse['message'] ?? 'Erro desconhecido'}'), backgroundColor: Colors.red),
        );
        return; // Não salva se houve um erro na verificação
      } else if (cnpjExistenteResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao verificar CNPJ (resposta nula).'), backgroundColor: Colors.red),
        );
        return; // Não salva se a resposta foi nula
      }
    }

    final sucesso = await fornecedorController.editarFornecedor(
      context,
      widget.fornecedor.id_fornecedor,
      _nomeController.text.trim(),
      cnpjSemFormatacao,
      _contatoController.text.trim(),
      _enderecoController.text.trim(),
    );
    if (sucesso) {
      Navigator.of(context).pop(true); // Indica que a edição foi bem-sucedida
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ${widget.fornecedor.nome_fornecedor}'),
      content: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 300, minWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nomeController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'Nome *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o nome.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _cnpjController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'CNPJ *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o CNPJ.';
                    }
                    if (value.replaceAll(RegExp(r'[^0-9]'), '').length != 14) {
                      return 'CNPJ inválido.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contatoController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'Contato'),
                ),
                TextFormField(
                  controller: _enderecoController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                ),
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
            onPressed: () => _salvarFornecedor(context),
            child: const Text('Salvar'),
          ),
      ],
    );
  }
}