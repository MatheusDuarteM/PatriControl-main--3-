import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:patricontrol/controller/movimentacao_controller.dart';
import 'package:patricontrol/model/movimentacao.dart'; // Seu model Movimentacao
//import 'package:patricontrol/pages/movimentacao/movimentacao_cadastro_page.dart';
//import 'package:patricontrol/widgets/filtro_movimentacao_dialog.dart'; // Seu diálogo de filtros
import 'package:patricontrol/widgets/movimentacao/filtro_movimentacao_dialog.dart';
import 'package:patricontrol/widgets/movimentacao/movimentacao_cadastro_page.dart';
import 'package:provider/provider.dart';

class MovimentacaoListPage extends StatefulWidget {
  const MovimentacaoListPage({super.key});

  static const routeName = '/movimentacoes'; // Rota para esta página

  @override
  State<MovimentacaoListPage> createState() => _MovimentacaoListPageState();
}

class _MovimentacaoListPageState extends State<MovimentacaoListPage> {
  @override
  void initState() {
    super.initState();
    // Carrega as movimentações ao iniciar a tela, se o controller ainda não o fez.
    // O controller já chama fetchMovimentacoes() em seu construtor.
    // Se precisar forçar uma recarga ao entrar na tela:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovimentacaoController>(
        context,
        listen: false,
      ).fetchMovimentacoes();
    });
  }

  void _abrirDialogoFiltrosAvancados(BuildContext context) {
    final controller = Provider.of<MovimentacaoController>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Certifique-se de que o FiltroMovimentacaoDialog está pegando o controller corretamente
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
        // O ícone de menu (hamburger) é adicionado automaticamente se esta tela
        // estiver dentro de um Scaffold que tem um Drawer (como o DashboardScreen).
        // Se esta for a tela raiz e você quiser um Drawer aqui, adicione `drawer: SeuWidgetDeDrawer(),` ao Scaffold.
      ),
      body: Column(
        children: [
          // --- BARRA DE PESQUISA E FILTRO RÁPIDO ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: movimentacaoController.filtroRapidoController,
              decoration: InputDecoration(
                hintText: 'Digite o nome ou código do patrimônio',
                // Ícone de filtro (funil) no início do campo
                prefixIcon: IconButton(
                  icon: const Icon(Icons.filter_list), // Ícone de funil
                  tooltip: 'Filtros Avançados',
                  onPressed: () => _abrirDialogoFiltrosAvancados(context),
                ),
                // Ícone de lupa no final do campo
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar',
                  onPressed: () {
                    // Esconder o teclado antes de buscar pode ser uma boa UX
                    FocusScope.of(context).unfocus();
                    movimentacaoController.fetchMovimentacoes();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                FocusScope.of(context).unfocus();
                movimentacaoController.fetchMovimentacoes();
              },
            ),
          ),

          // --- TABELA DE MOVIMENTAÇÕES ---
          Expanded(
            child:
                movimentacaoController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : movimentacaoController.errorMessage != null
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Erro: ${movimentacaoController.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    : movimentacaoController.movimentacoes.isEmpty
                    ? const Center(
                      child: Text('Nenhuma movimentação encontrada.'),
                    )
                    : SingleChildScrollView(
                      // Permite rolagem horizontal da tabela
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 18.0, // Espaçamento entre colunas
                        headingRowHeight: 40.0, // Altura do cabeçalho
                        dataRowMinHeight:
                            48.0, // Altura mínima da linha de dados
                        dataRowMaxHeight:
                            56.0, // Altura máxima da linha de dados
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700], // Cor do texto do cabeçalho
                        ),
                        columns: const [
                          DataColumn(label: Text('Código')),
                          DataColumn(label: Text('Descrição')),
                          DataColumn(label: Text('Origem')),
                          DataColumn(label: Text('Destino')),
                          DataColumn(label: Text('Data')),
                          DataColumn(label: Text('Movimentação')),
                          DataColumn(label: Text('Usuário')),
                        ],
                        rows:
                            movimentacaoController.movimentacoes.map((mov) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(mov.patrimonioCodigo)),
                                  DataCell(
                                    Text(
                                      mov.patrimonioDescricao,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DataCell(
                                    Text(mov.origemSetor?.nome ?? 'N/A'),
                                  ),
                                  DataCell(
                                    Text(mov.destinoSetor?.nome ?? 'N/A'),
                                  ),
                                  DataCell(
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(mov.dataMovimentacao),
                                    ),
                                  ),
                                  DataCell(Text(mov.tipoMovimentacao)),
                                  DataCell(Text(mov.usuarioNome)),
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
          // Limpa qualquer estado anterior do formulário de cadastro
          Provider.of<MovimentacaoController>(
            context,
            listen: false,
          ).limparFormularioCadastro();
          Navigator.of(context).pushNamed(MovimentacaoCadastroPage.routeName);
        },
        tooltip: 'Nova Movimentação',
        child: const Icon(Icons.add),
      ),
    );
  }
}
