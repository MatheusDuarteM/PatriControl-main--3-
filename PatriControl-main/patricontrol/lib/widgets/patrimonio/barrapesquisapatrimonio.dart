// lib/pages/patrimonio/widgets/barrapesquisapatrimonio.dart
import 'package:flutter/material.dart';
import 'package:patricontrol/providers/patrimonio_list_provider.dart';
import 'package:provider/provider.dart';
import 'package:patricontrol/model/setor.dart'; // Importe o modelo Setor

class BarraPesquisaPatrimonio extends StatefulWidget {
  // A assinatura de onSearchChanged precisa mudar para aceitar o setor também
  const BarraPesquisaPatrimonio({
    super.key,
    required this.onSearchChanged,
  });

  // Alteramos a assinatura para passar o texto e o Setor
  final Function({String searchText, Setor? setor}) onSearchChanged;

  @override
  State<BarraPesquisaPatrimonio> createState() => _BarraPesquisaPatrimonioState();
}

class _BarraPesquisaPatrimonioState extends State<BarraPesquisaPatrimonio> {
  final TextEditingController _searchController = TextEditingController();
  bool _showClearButton = false;
  Setor? _selectedSetor; // Novo estado para o setor selecionado

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchInputChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchInputChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Método unificado para notificar a pesquisa e o filtro
  void _triggerSearchAndFilter() {
    widget.onSearchChanged(
      searchText: _searchController.text,
      setor: _selectedSetor,
    );
  }

  void _onSearchInputChanged() {
    setState(() {
      _showClearButton = _searchController.text.isNotEmpty;
    });
    _triggerSearchAndFilter(); // Chama o método unificado
  }

  void _clearSearch() {
    _searchController.clear();
    // _onSearchInputChanged já vai disparar _triggerSearchAndFilter com texto vazio
  }

  // Método para mostrar o diálogo de seleção de setor
  void _showSetorFilterDialog(BuildContext context) {
    final provider = Provider.of<PatrimonioListProvider>(context, listen: false);
    final List<Setor> setores = provider.setoresDisponiveis;

    showDialog<Setor?>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Filtrar por Setor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Opção para "Limpar Filtro" no início da lista
                RadioListTile<Setor?>(
                  title: const Text('Todos os Setores (Limpar Filtro)'),
                  value: null,
                  groupValue: _selectedSetor,
                  onChanged: (Setor? value) {
                    setState(() {
                      _selectedSetor = value;
                    });
                    Navigator.pop(dialogContext, value); // Fecha o diálogo e retorna null
                  },
                ),
                ...setores.map((setor) {
                  return RadioListTile<Setor>(
                    title: Text(setor.nome_setor),
                    value: setor,
                    groupValue: _selectedSetor,
                    onChanged: (Setor? value) {
                      setState(() {
                        _selectedSetor = value;
                      });
                      Navigator.pop(dialogContext, value); // Fecha o diálogo e retorna o setor
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    ).then((selectedSetor) {
      // Este .then é chamado quando o diálogo é fechado
      setState(() {
        _selectedSetor = selectedSetor; // Atualiza o estado local
      });
      _triggerSearchAndFilter(); // Re-aplica a pesquisa com o novo filtro de setor
    });
  }

  @override
  Widget build(BuildContext context) {
    // Você pode usar um Consumer aqui para reagir a mudanças nos setores disponíveis
    // do PatrimonioListProvider, caso eles sejam carregados dinamicamente ou mudem.
    // Por enquanto, vamos pegar a lista uma vez.
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 0),
        child: Row(
          children: [
            // Botão para abrir o filtro de setor
            IconButton(
              onPressed: () => _showSetorFilterDialog(context),
              icon: Icon(
                _selectedSetor != null ? Icons.filter_list : Icons.filter_list,
                size: 30,
                color: _selectedSetor != null ? Colors.blue : Colors.blueGrey, // Destaca se houver filtro
              ),
              tooltip: _selectedSetor != null
                  ? 'Filtro por Setor: ${_selectedSetor!.nome_setor}'
                  : 'Filtrar por Setor',
            ),
            const SizedBox(width: 5), // Espaçamento
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Digite o código, nome, marca ou descrição...",
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            if (_showClearButton) // Botão de limpar (se o texto não estiver vazio)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearSearch,
                tooltip: 'Limpar pesquisa',
              ),
            // O botão de pesquisa explícita no final da Row pode ser mantido
            // ou removido, dependendo se você quer que o usuário clique para pesquisar
            // ou se prefere o filtro automático ao digitar.
            // Se mantido, ele deve chamar _triggerSearchAndFilter()
            IconButton(
              onPressed: () {
                 _triggerSearchAndFilter(); // Chama o método unificado
              },
              icon: const Icon(Icons.search, size: 30, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}