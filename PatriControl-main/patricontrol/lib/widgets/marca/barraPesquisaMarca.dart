import 'package:flutter/material.dart';
import 'package:patricontrol/providers/marca_list_provider.dart';
import 'package:provider/provider.dart';

class BarraPesquisaMarca extends StatefulWidget {
  const BarraPesquisaMarca({super.key, required this.onSearchChanged});
  final Function(String) onSearchChanged;

  @override
  State<BarraPesquisaMarca> createState() => _BarraPesquisaMarcaState();
}

class _BarraPesquisaMarcaState extends State<BarraPesquisaMarca> {
  final TextEditingController _searchController = TextEditingController();

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
                controller: _searchController,
                onChanged: widget.onSearchChanged,
                decoration: const InputDecoration(
                  hintText: "Digite o nome da marca",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Provider.of<MarcaListProvider>(context,listen: false).carregarMarcas();
              },
              icon: const Icon(Icons.search, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}