import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patricontrol/controller/movimentacao_controller.dart';
import 'package:patricontrol/model/movimentacao.dart';
//import 'package:patricontrol/pages/movimentacao/movimentacao_cadastro_page.dart';
//import 'package:patricontrol/widgets/filtro_movimentacao_dialog.dart'; // Criaremos este
import 'package:patricontrol/widgets/movimentacao/filtro_movimentacao_dialog.dart';
import 'package:patricontrol/widgets/movimentacao/movimentacao_cadastro_page.dart';
import 'package:provider/provider.dart';

class MovimentacaoListPage extends StatefulWidget {
  const MovimentacaoListPage({super.key});

  static const routeName = '/movimentacoes';

  @override
  State<MovimentacaoListPage> createState() => _MovimentacaoListPageState();
}

class _MovimentacaoListPageState extends State<MovimentacaoListPage> {
  @override
  void initState() {
    super.initState();
    // O controller já carrega no construtor, mas se precisar recarregar ao entrar na tela:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<MovimentacaoController>(context, listen: false).fetchMovimentacoes();
    // });
  }

  void _abrirDialogoFiltros(BuildContext context) {
    final controller = Provider.of<MovimentacaoController>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return FiltroMovimentacaoDialog(controller: controller);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movimentacaoController = Provider.of<MovimentacaoController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimentações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtros Avançados',
            onPressed: () => _abrirDialogoFiltros(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: movimentacaoController.filtroRapidoController,
              decoration: InputDecoration(
                labelText: 'Digite nome ou código do patrimônio',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    movimentacaoController.fetchMovimentacoes();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => movimentacaoController.fetchMovimentacoes(),
            ),
          ),
          if (movimentacaoController.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (movimentacaoController.errorMessage != null)
            Expanded(
              child: Center(
                child: Text('Erro: ${movimentacaoController.errorMessage}'),
              ),
            )
          else if (movimentacaoController.movimentacoes.isEmpty)
            const Expanded(
              child: Center(child: Text('Nenhuma movimentação encontrada.')),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                // Para a tabela ser rolável horizontalmente se necessário
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 15,
                  columns: const [
                    DataColumn(label: Text('Código')),
                    DataColumn(label: Text('Descrição Pat.')),
                    DataColumn(label: Text('Origem')),
                    DataColumn(label: Text('Destino')),
                    DataColumn(label: Text('Data')),
                    DataColumn(label: Text('Movimentação')),
                    DataColumn(label: Text('Usuário')),
                    DataColumn(label: Text('Obs.')),
                  ],
                  rows:
                      movimentacaoController.movimentacoes.map((mov) {
                        return DataRow(
                          cells: [
                            DataCell(Text(mov.patrimonioCodigo)),
                            DataCell(Text(mov.patrimonioDescricao)),
                            DataCell(Text(mov.origemSetor?.nome ?? 'N/A')),
                            DataCell(Text(mov.destinoSetor?.nome ?? 'N/A')),
                            DataCell(
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(mov.dataMovimentacao),
                              ),
                            ),
                            DataCell(Text(mov.tipoMovimentacao)),
                            DataCell(Text(mov.usuarioNome)),
                            DataCell(
                              Text(
                                mov.observacao ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          movimentacaoController
              .limparFormularioCadastro(); // Garante que o form esteja limpo
          Navigator.of(context).pushNamed(MovimentacaoCadastroPage.routeName);
        },
        child: const Icon(Icons.add),
        tooltip: 'Nova Movimentação',
      ),
    );
  }
}
