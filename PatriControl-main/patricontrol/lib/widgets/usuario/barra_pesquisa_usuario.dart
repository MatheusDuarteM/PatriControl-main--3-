import 'package:flutter/material.dart';
import 'dart:async'; // Importe para usar Timer

import 'package:patricontrol/providers/usuario_list_provider.dart';
import 'package:provider/provider.dart';

class BarraPesquisaUsuario extends StatefulWidget {
  const BarraPesquisaUsuario({super.key, required this.onSearchChanged});
  final Function(String) onSearchChanged;

  @override
  State<BarraPesquisaUsuario> createState() => _BarraPesquisaUsuarioState();
}

class _BarraPesquisaUsuarioState extends State<BarraPesquisaUsuario> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Este listener disparará a função 'onSearchChanged' (do provider) a cada digitação, com debounce.
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearchChanged(_searchController.text);
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
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                onChanged: (text) {
                  Provider.of<UsuarioListProvider>(context, listen: false).atualizarPesquisa(text);
                },
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Digite o nome do usuário",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Provider.of<UsuarioListProvider>(context, listen: false)
                    .carregarUsuarios(searchText: _searchController.text);
              },
              icon: const Icon(Icons.search, size: 30),
            )
          ],
        ),
      ),
    );
  }
}