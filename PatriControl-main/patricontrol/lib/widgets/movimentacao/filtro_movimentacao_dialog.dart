import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patricontrol/controller/movimentacao_controller.dart';
import 'package:patricontrol/model/setor.dart';

class FiltroMovimentacaoDialog extends StatefulWidget {
  final MovimentacaoController controller;

  const FiltroMovimentacaoDialog({super.key, required this.controller});

  @override
  State<FiltroMovimentacaoDialog> createState() =>
      _FiltroMovimentacaoDialogState();
}

class _FiltroMovimentacaoDialogState extends State<FiltroMovimentacaoDialog> {
  TextEditingController _usuarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preencher campos com valores atuais do controller, se houver
    _usuarioController.text = widget.controller.filtroUsuarioNome ?? '';
  }

  Future<void> _selecionarData(BuildContext context, bool isInicio) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate:
          (isInicio
              ? widget.controller.filtroDataInicio
              : widget.controller.filtroDataFim) ??
          DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (dataSelecionada != null) {
      if (isInicio) {
        widget.controller.setFiltroDataInicio(dataSelecionada);
      } else {
        widget.controller.setFiltroDataFim(dataSelecionada);
      }
      setState(() {}); // Para atualizar a UI do diálogo
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use um Consumer ou Selector para reconstruir apenas partes se necessário
    // mas para um diálogo, reconstruir tudo ao mudar estado local é aceitável.
    return AlertDialog(
      title: const Text('Filtros Avançados'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Filtro por Código (já está no filtro rápido, mas pode ser adicionado aqui)

            // Filtro por Origem (Setor)
            DropdownButtonFormField<Setor?>(
              decoration: const InputDecoration(labelText: 'Setor de Origem'),
              value: widget.controller.filtroOrigemSetor,
              hint: const Text('Selecione a origem'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<Setor?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...widget.controller.setoresDisponiveis.map((Setor setor) {
                  return DropdownMenuItem<Setor>(
                    value: setor,
                    child: Text(setor.nome),
                  );
                }).toList(),
              ],
              onChanged: (Setor? novoValor) {
                widget.controller.setFiltroOrigemSetor(novoValor);
                setState(() {});
              },
            ),
            const SizedBox(height: 10),

            // Filtro por Destino (Setor)
            DropdownButtonFormField<Setor?>(
              decoration: const InputDecoration(labelText: 'Setor de Destino'),
              value: widget.controller.filtroDestinoSetor,
              hint: const Text('Selecione o destino'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<Setor?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...widget.controller.setoresDisponiveis.map((Setor setor) {
                  return DropdownMenuItem<Setor>(
                    value: setor,
                    child: Text(setor.nome),
                  );
                }).toList(),
              ],
              onChanged: (Setor? novoValor) {
                widget.controller.setFiltroDestinoSetor(novoValor);
                setState(() {});
              },
            ),
            const SizedBox(height: 10),

            // Filtro por Data (Início e Fim)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Data Início: ${widget.controller.filtroDataInicio != null ? DateFormat('dd/MM/yyyy').format(widget.controller.filtroDataInicio!) : 'N/A'}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selecionarData(context, true),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Data Fim:     ${widget.controller.filtroDataFim != null ? DateFormat('dd/MM/yyyy').format(widget.controller.filtroDataFim!) : 'N/A'}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selecionarData(context, false),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Filtro por Tipo de Movimentação
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Tipo de Movimentação',
              ),
              value: widget.controller.filtroTipoMovimentacao,
              hint: const Text('Selecione o tipo'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...widget.controller.tiposDeMovimentacao.map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
              ],
              onChanged: (String? novoValor) {
                widget.controller.setFiltroTipoMovimentacao(novoValor);
                setState(() {});
              },
            ),
            const SizedBox(height: 10),

            // Filtro por Usuário
            TextFormField(
              controller: _usuarioController,
              decoration: const InputDecoration(labelText: 'Nome do Usuário'),
              onChanged: (valor) {
                widget.controller.setFiltroUsuarioNome(
                  valor.trim().isNotEmpty ? valor.trim() : null,
                );
                // Não precisa setState aqui se não houver feedback visual imediato no dialog
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Limpar Filtros'),
          onPressed: () {
            widget.controller.limparFiltrosAvancados();
            _usuarioController.clear(); // Limpa o controller local também
            setState(() {}); // Atualiza a UI do diálogo para refletir a limpeza
            // Navigator.of(context).pop(); // Opcional: fechar dialog após limpar
          },
        ),
        ElevatedButton(
          child: const Text('Filtrar'),
          onPressed: () {
            widget.controller.aplicarFiltrosAvancados();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
