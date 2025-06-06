import 'package:flutter/material.dart';
import 'package:patricontrol/providers/setor_list_provider.dart';
import 'package:provider/provider.dart';

class Barrapesquisasetor extends StatefulWidget {
  const Barrapesquisasetor({super.key});

  @override
  State<Barrapesquisasetor> createState() => _BarrapesquisasetorState();
}

class _BarrapesquisasetorState extends State<Barrapesquisasetor> {
  final TextEditingController _searchController = TextEditingController();
  String? _filtroTipo;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final filtro = _filtroTipo;
    Provider.of<SetorListProvider>(context, listen: false).carregarSetores(searchText: _searchController.text, tipoFiltro: filtro);
  }

  void _mostrarFiltroDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar por Tipo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: const Text('Interno'),
                value: 'Interno',
                groupValue: _filtroTipo,
                onChanged: (String? value) {
                  setState(() {
                    _filtroTipo = value;
                  });
                  Navigator.pop(context);
                  _onSearchChanged(); // Refazer a pesquisa com o filtro
                },
              ),
              RadioListTile<String>(
                title: const Text('Externo'),
                value: 'Externo',
                groupValue: _filtroTipo,
                onChanged: (String? value) {
                  setState(() {
                    _filtroTipo = value;
                  });
                  Navigator.pop(context);
                  _onSearchChanged(); // Refazer a pesquisa com o filtro
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filtroTipo = null; // Remover filtro
                  });
                  Navigator.pop(context);
                  _onSearchChanged(); // Refazer a pesquisa sem filtro
                },
                child: const Text('Remover Filtro'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            IconButton(
              onPressed: () => _mostrarFiltroDialog(context),
              icon: const Icon(Icons.filter_list, size: 30),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (text) {
                  Provider.of<SetorListProvider>(context, listen: false).atualizarPesquisa(text);
                },
                decoration: const InputDecoration(
                  hintText: "Digite o nome do setor",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Provider.of<SetorListProvider>(context, listen: false).carregarSetores(
                  searchText: _searchController.text,
                  tipoFiltro: _filtroTipo,
                );
              },
              icon: const Icon(Icons.search, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}