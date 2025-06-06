// lib/pages/modelo/widgets/barrapesquisamodelo.dart (EDITADO PARA APARÊNCIA)
import 'package:flutter/material.dart';

class BarraPesquisaModelo extends StatefulWidget {
  const BarraPesquisaModelo({super.key, required this.onSearchChanged});
  final Function(String) onSearchChanged;

  @override
  State<BarraPesquisaModelo> createState() => _BarraPesquisaModeloState();
}

class _BarraPesquisaModeloState extends State<BarraPesquisaModelo> {
  final TextEditingController _searchController = TextEditingController();
  bool _showClearButton = false;

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

  void _onSearchInputChanged() {
    setState(() {
      _showClearButton = _searchController.text.isNotEmpty;
    });
    widget.onSearchChanged(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    // A chamada _onSearchInputChanged (via listener) já vai disparar
    // widget.onSearchChanged('') quando o campo for limpo.
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Mantendo a elevação como a do fornecedor
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Arredondamento como o fornecedor
      ),
      margin: const EdgeInsets.all(5), // Margem similar à do fornecedor
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 0), // Padding similar
        child: Row(
          children: [
            const SizedBox(width: 20), // Espaçamento inicial
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Digite o nome ou cor do modelo", // Texto de dica
                  border: InputBorder.none, // Remove a borda padrão do TextField
                  // contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                  // Se precisar ajustar o alinhamento vertical, use contentPadding.
                  // No entanto, o `Card` e `Padding` externos já devem dar o efeito.
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87, // Cor do texto digitado para boa visibilidade
                ),
              ),
            ),
            if (_showClearButton) // Botão de limpar visível apenas se houver texto
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearSearch,
                tooltip: 'Limpar pesquisa',
              ),
            // O ícone de pesquisa ficará no final do Row, conforme o layout do fornecedor
            IconButton(
              onPressed: () {
              },
              icon: const Icon(Icons.search, size: 30, color: Colors.blueGrey), // Ícone de pesquisa no final, com cor similar ao do fornecedor
            ),
          ],
        ),
      ),
    );
  }
}