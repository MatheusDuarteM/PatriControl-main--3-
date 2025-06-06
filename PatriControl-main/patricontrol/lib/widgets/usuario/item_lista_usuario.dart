import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:patricontrol/model/usuario.dart'; // Importe o model Usuario
import 'package:intl/intl.dart'; // Para formatar a data

class ItemListaUsuario extends StatelessWidget {
  final Usuario usuario;
  final Function(Usuario)? onUsuarioSelecionado;
  final Function(Usuario)? onDeletarUsuario;

  ItemListaUsuario({
    super.key,
    required this.usuario,
    this.onUsuarioSelecionado,
    this.onDeletarUsuario,
  });

  // Formatador para o CPF
  final MaskTextInputFormatter _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Método auxiliar para formatar o CPF
  String _formatCpf(String cpf) {
    // Aplica a máscara no CPF. É importante garantir que o CPF original seja apenas dígitos.
    _cpfFormatter.clear(); // Limpa formatação anterior
    _cpfFormatter.formatEditUpdate(
      const TextEditingValue(),
      TextEditingValue(text: cpf),
    );
    return _cpfFormatter.getMaskedText();
  }

  // Método auxiliar para formatar a data de nascimento
  String _formatDataNascimento(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
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
              child: InkWell(
                onTap: onUsuarioSelecionado != null
                    ? () => onUsuarioSelecionado!(usuario)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nome: ${usuario.nomeUsuario}"),
                      Text("CPF: ${_formatCpf(usuario.cpfUsuario)}"),
                      Text("Data Nascimento: ${_formatDataNascimento(usuario.nascUsuario)}"),
                      Text("Tipo: ${usuario.tipoUsuario}"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () {
              if (onDeletarUsuario != null) {
                onDeletarUsuario!(usuario);
              }
            },
            icon: const Icon(Icons.remove_circle_outline, size: 30),
            color: Colors.red,
          )
        ],
      ),
    );
  }
}