// lib/screens/patrimonio/lista_patrimonio_page.dart

import 'package:flutter/material.dart';
import 'package:patricontrol/widgets/patrimonio/barrapesquisapatrimonio.dart';
import 'package:patricontrol/widgets/patrimonio/itemlistapatrimonio.dart';
import 'package:provider/provider.dart';
import '../../../model/patrimonio.dart';
import '../../../providers/patrimonio_list_provider.dart'; // O provider que gerencia a lista e o controller
import '../../../model/setor.dart'; // <--- Importe o modelo Setor aqui
import 'editar_patrimonio_dialog.dart'; // Seu dialog de edição
import 'cadastro_patrimonio_dialog.dart'; // Seu dialog de cadastro

class ListaPatrimonioPage extends StatefulWidget {
  const ListaPatrimonioPage({super.key});

  @override
  State<ListaPatrimonioPage> createState() => _ListaPatrimonioPageState();
}

class _ListaPatrimonioPageState extends State<ListaPatrimonioPage> {
  // Estados locais para os filtros aplicados na página
  String _currentSearchText = '';
  Setor? _currentSelectedSetor; // <--- Adicionado estado para o setor selecionado

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatrimonioListProvider>(context, listen: false).init();
    });
  }

  // Método que será chamado pela BarraPesquisaPatrimonio quando houver mudanças
  // AGORA RECEBE PARAMETROS NOMEADOS
  void _onSearchAndFilterChanged({String searchText = '', Setor? setor}) {
    setState(() {
      _currentSearchText = searchText;
      _currentSelectedSetor = setor;
    });
    _applyLocalFilters(); // Aplica os filtros na lista de patrimônios
  }

  // Método para aplicar a filtragem localmente na lista de patrimônios
  void _applyLocalFilters() {
    final provider = Provider.of<PatrimonioListProvider>(context, listen: false);
    final controller = provider.patrimonioController;

    // Obtém a lista original completa do controller
    // Certifique-se de que `todosOsPatrimonios` exista e esteja populado no seu PatrimonioController
    List<Patrimonio> listaOriginal = controller.todosOsPatrimonios;

    List<Patrimonio> listaFiltrada = List.from(listaOriginal);

    // Aplica o filtro de texto, se houver
    if (_currentSearchText.isNotEmpty) {
      final termoPesquisa = _currentSearchText.toLowerCase().trim();
      listaFiltrada = listaFiltrada.where((patrimonio) {
        return patrimonio.codigoPatrimonio!.toLowerCase().contains(termoPesquisa) ||
               patrimonio.descricaoPatrimonio!.toLowerCase().contains(termoPesquisa) ||
               (patrimonio.marca?.nome_marca.toLowerCase().contains(termoPesquisa) ?? false) ||
               (patrimonio.modelo?.nomeModelo.toLowerCase().contains(termoPesquisa) ?? false) ||
               (patrimonio.setorAtual?.nome_setor.toLowerCase().contains(termoPesquisa) ?? false);
      }).toList();
    }

    // Aplica o filtro por setor, se houver
    if (_currentSelectedSetor != null) {
      listaFiltrada = listaFiltrada.where((patrimonio) {
        // Certifique-se de que id_setor é o campo correto para comparação
        return patrimonio.setorAtual?.id_setor == _currentSelectedSetor!.id_setor;
      }).toList();
    }

    // Atualiza a lista exibida no controller, que por sua vez notificará a UI
    controller.defineListaExibida(listaFiltrada);
  }


  Future<void> _abrirEditarPatrimonioDialog(Patrimonio patrimonio) async {
    final patrimonioListProvider = Provider.of<PatrimonioListProvider>(context, listen: false);

    await patrimonioListProvider.carregarDadosParaEdicao(patrimonio);

    final result = await showDialog(
      context: context,
      builder: (ctx) => PatrimonioEditDialog(),
    );

    if (result == true) {
      await patrimonioListProvider.buscarPatrimonios(mostrarLoading: false);
      // Após recarregar, aplique os filtros novamente para manter o estado da tela
      _applyLocalFilters();
    } else {
      patrimonioListProvider.reverterDadosEdicao();
    }
  }

  void _confirmarExclusao(Patrimonio patrimonio) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja inativar o patrimônio "${patrimonio.codigoPatrimonio}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final patrimonioListProvider = Provider.of<PatrimonioListProvider>(
                  context,
                  listen: false,
                );

                if (patrimonio.idPatrimonio == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro: ID do patrimônio não encontrado para inativação.')),
                  );
                  return;
                }
                final int? id = patrimonio.idPatrimonio;
                if (id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erro: ID do patrimônio inválido.')),
                    );
                    return;
                }
                await patrimonioListProvider.inativarPatrimonio(context, id);
                // Após inativar, recarregue e aplique os filtros
                _applyLocalFilters();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Inativar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _abrirDialogCadastroPatrimonio() {
    final patrimonioListProvider = Provider.of<PatrimonioListProvider>(context, listen: false);
    patrimonioListProvider.limparCampos();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const CadastroPatrimonioDialog();
      },
    ).then((foiSalvo) async {
      if (foiSalvo == true && mounted) {
        await patrimonioListProvider.buscarPatrimonios(mostrarLoading: false);
        // Após cadastrar, aplique os filtros novamente
        _applyLocalFilters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Patrimônios'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(226, 94, 99, 102),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BarraPesquisaPatrimonio(
              // AGORA ESTÁ PASSANDO A FUNÇÃO CORRETA COM OS PARÂMETROS NOMEADOS
              onSearchChanged: _onSearchAndFilterChanged, // <--- CUIDADO AQUI: Removido o lambda, passando o método diretamente
            ),
          ),
          Expanded(
            child: Consumer<PatrimonioListProvider>(
              builder: (context, patrimonioListProvider, child) {
                final controller = patrimonioListProvider.patrimonioController;

                if (patrimonioListProvider.isLoading && controller.listaDePatrimoniosExibida.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (patrimonioListProvider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 50),
                          const SizedBox(height: 10),
                          Text(
                            'Erro ao carregar dados: ${patrimonioListProvider.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              patrimonioListProvider.init();
                              _applyLocalFilters(); // Re-aplica filtros após tentar novamente
                            },
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.erroGeral != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 50),
                          const SizedBox(height: 10),
                          Text(
                            'Alerta: ${controller.erroGeral}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.orange, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              controller.buscarPatrimonios();
                              _applyLocalFilters(); // Re-aplica filtros após tentar recarregar
                            },
                            child: const Text('Tentar Recarregar Patrimônios'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.listaDePatrimoniosExibida.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 80),
                        const SizedBox(height: 10),
                        Text(
                          _currentSearchText.isEmpty && _currentSelectedSetor == null // Ajustado para verificar o setor
                              ? 'Nenhum patrimônio cadastrado ainda.'
                              : 'Nenhum patrimônio encontrado com os filtros aplicados.', // Mensagem mais genérica para filtros
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: controller.listaDePatrimoniosExibida.length,
                  itemBuilder: (context, index) {
                    final patrimonio = controller.listaDePatrimoniosExibida[index];
                    return ItemListaPatrimonio(
                      patrimonio: patrimonio,
                      onPatrimonioSelecionado: _abrirEditarPatrimonioDialog,
                      onInativarPatrimonio: _confirmarExclusao,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogCadastroPatrimonio,
        backgroundColor: const Color(0xFF1A1F71),
        tooltip: 'Cadastrar Patrimônio',
        child: const Icon(Icons.add),
      ),
    );
  }
}