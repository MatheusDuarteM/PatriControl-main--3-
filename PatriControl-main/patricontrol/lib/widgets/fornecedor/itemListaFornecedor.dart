import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:patricontrol/model/fornecedor.dart';

class Itemlistafornecedor extends StatelessWidget {

  final Fornecedor fornecedor;
  final Function(Fornecedor)? onFornecedorSelecionado;
  final Function(Fornecedor)? onDeletarFornecedor;

  Itemlistafornecedor({
    super.key,
    required this.fornecedor,
    this.onFornecedorSelecionado,
    this.onDeletarFornecedor
  });

  final MaskTextInputFormatter _cnpjFormatter = MaskTextInputFormatter(
  mask: '##.###.###/####-##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
  );

  String _formatCnpj(String cnpj) {
    _cnpjFormatter.formatEditUpdate(
      const TextEditingValue(),
      TextEditingValue(text: cnpj),
    );
    return _cnpjFormatter.getMaskedText();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: 
              InkWell(
                onTap: onFornecedorSelecionado != null ? () => onFornecedorSelecionado!(fornecedor) : null,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nome: ${fornecedor.nome_fornecedor}"),
                      Text("CNPJ: ${_formatCnpj(fornecedor.cnpj_fornecedor)}"),
                      Text("Contato: ${fornecedor.contato_fornecedor}"),
                      Text("Endereço: ${fornecedor.endereco_fornecedor}")
                    ],
                  ),
                ),
              ),
            )
          ),
          SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: (){
              if (onDeletarFornecedor != null) {
                  onDeletarFornecedor!(fornecedor);
                }
            },
            icon: Icon(Icons.remove_circle_outline,size: 30),
            color: Colors.red,
          )
        ],
      ),
    );
  }
}
