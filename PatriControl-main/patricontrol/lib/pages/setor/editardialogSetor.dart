import 'package:flutter/material.dart';
import 'package:patricontrol/controller/setor_controller.dart';
import '../../model/setor.dart';
import 'package:provider/provider.dart';

class EditarSetorDialog extends StatefulWidget {
  final Setor setor; // O setor a ser editado

  const EditarSetorDialog({Key? key, required this.setor}) : super(key: key);

  @override
  State<EditarSetorDialog> createState() => _EditarSetorDialogState();
}

class _EditarSetorDialogState extends State<EditarSetorDialog> {
  final _formKey = GlobalKey<FormState>();
  // Controladores já são inicializados no initState com os dados do setor
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _responsavelController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _contatoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _tipoSelecionado; // Para o Dropdown
  bool _isLoading = false; // Estado de carregamento para o botão de salvar
  final List<String> _tipos = ['Interno', 'Externo']; // Opções para o tipo de setor

  @override
  void initState() {
    super.initState();
    // Preenche os controladores e o dropdown com os dados do setor passado para edição
    _tipoSelecionado = widget.setor.tipo_setor;
    _nomeController.text = widget.setor.nome_setor;
    _responsavelController.text = widget.setor.responsavel_setor;
    _descricaoController.text = widget.setor.descricao_setor;
    _contatoController.text = widget.setor.contato_setor;
    _emailController.text = widget.setor.email_setor;
  }

  @override
  void dispose() {
    // Descartar os controladores quando o widget for removido da árvore
    _nomeController.dispose();
    _responsavelController.dispose();
    _descricaoController.dispose();
    _contatoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Método para salvar as alterações do setor
  Future<void> _salvarSetor(BuildContext context) async {
    // Valida o formulário e verifica se um tipo foi selecionado
    if (_formKey.currentState!.validate() && _tipoSelecionado != null) {
      setState(() {
        _isLoading = true; // Ativa o estado de carregamento
      });

      final setorController = Provider.of<SetorController>(context, listen: false);
      final nomeAtual = _nomeController.text.trim();

      // Verificar se o nome foi alterado e se o novo nome já existe (exceto para o próprio setor)
      if (nomeAtual != widget.setor.nome_setor) {
        final nomeExistenteResponse = await setorController.verificarNomeExistenteEdicao(nomeAtual, widget.setor.id_setor);
        if (nomeExistenteResponse != null && nomeExistenteResponse['exists'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('O nome informado já está cadastrado para outro setor.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false; // Desativa o carregamento em caso de erro
          });
          return; // Aborta a operação se o nome já existe
        } else if (nomeExistenteResponse != null && nomeExistenteResponse['status'] == 'error') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao verificar o nome: ${nomeExistenteResponse['message'] ?? 'Erro desconhecido'}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        } else if (nomeExistenteResponse == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao verificar o nome (resposta nula).'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Tenta editar o setor usando o controller
      final sucesso = await setorController.editarSetor(
        context,
        widget.setor.id_setor, // Passa o ID do setor a ser editado
        _tipoSelecionado!,
        nomeAtual,
        _responsavelController.text.trim(),
        _descricaoController.text.trim(),
        _contatoController.text.trim(),
        _emailController.text.trim(),
      );

      setState(() {
        _isLoading = false; // Desativa o estado de carregamento
      });

      if (sucesso) {
        Navigator.of(context).pop(true); // Retorna true para indicar sucesso na edição
      }
    } else if (_tipoSelecionado == null) {
      // Caso o tipo não tenha sido selecionado e o formulário seja validado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione o tipo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ${widget.setor.nome_setor}'), // Título dinâmico
      content:
          // O widget Material foi adicionado aqui para fornecer o contexto necessário para DropdownButtonFormField
          Material(
        type: MaterialType.card, // Define o tipo para 'card' para manter a aparência de um cartão/diálogo
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 300, minWidth: 400),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Adicionado para melhor controle do tamanho
                // Use SizedBox para espaçamento entre os widgets
                children: <Widget>[
                  // Dropdown para Tipo de Setor
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo *',
                      border: OutlineInputBorder(), // Adicionado para consistência visual
                    ),
                    value: _tipoSelecionado,
                    items: _tipos.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.substring(0, 1).toUpperCase() + value.substring(1)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _tipoSelecionado = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione o tipo.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15), // Espaçamento

                  // Campo Nome do Setor
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite o nome.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Campo Responsável
                  TextFormField(
                    controller: _responsavelController,
                    decoration: const InputDecoration(
                      labelText: 'Responsável',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Campo Descrição
                  TextFormField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3, // Permitir múltiplas linhas para descrição
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 15),

                  // Campo Contato
                  TextFormField(
                    controller: _contatoController,
                    decoration: const InputDecoration(
                      labelText: 'Contato',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Campo Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress, // Teclado para email
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        // Botão Cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Retorna false ao cancelar
          child: const Text('Cancelar'),
        ),
        // Botão Salvar (com indicador de carregamento)
        ElevatedButton( // Alterado para ElevatedButton para consistência e estilo
          onPressed: _isLoading
              ? null // Desabilita o botão enquanto estiver carregando
              : () => _salvarSetor(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey, // Cor de fundo
            foregroundColor: Colors.white, // Cor do texto
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white, // Cor do progresso
                    strokeWidth: 2, // Espessura da linha
                  ),
                )
              : const Text('Salvar Alterações'), // Texto do botão
        ),
      ],
    );
  }
}