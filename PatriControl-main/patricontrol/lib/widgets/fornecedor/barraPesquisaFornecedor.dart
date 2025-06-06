import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fornecedor_list_provider.dart'; // Importe o Provider

class Barrapesquisafornecedor extends StatefulWidget {
  const Barrapesquisafornecedor({super.key, required this.onSearchChanged});
  final Function(String) onSearchChanged;

  @override
  State<Barrapesquisafornecedor> createState() => _BarrapesquisafornecedorState();
}

class _BarrapesquisafornecedorState extends State<Barrapesquisafornecedor> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged); // Adiciona um listener ao controlador
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged); // Remove o listener ao descartar o widget
    _searchController.dispose(); // Libera os recursos do controlador
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearchChanged(_searchController.text); // Chama a função passada com o texto atual
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 0),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: widget.onSearchChanged,
                decoration: const InputDecoration(
                  hintText: "Digite o nome do fornecedor",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Provider.of<FornecedorListProvider>(context, listen: false).carregarFornecedores();
              },
              icon: const Icon(Icons.search, size: 30),
            )
          ],
        ),
      ),
    );
  }
}