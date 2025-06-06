import 'package:flutter/material.dart';
import 'package:patricontrol/providers/modelo_list_provider.dart';
import 'package:patricontrol/widgets/modelo/barrapesquisamodelo.dart';
import 'package:patricontrol/widgets/modelo/itemlistamodelo.dart';
import 'package:provider/provider.dart';
import '../../model/modelo.dart';
import 'cadastro_modelo_dialog.dart';
import 'editar_modelo_dialog.dart';

class ListaModelosPage extends StatefulWidget {
  const ListaModelosPage({super.key});

  @override
  State<ListaModelosPage> createState() => _ListaModelosPageState();
}

class _ListaModelosPageState extends State<ListaModelosPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<ModeloListProvider>(context, listen: false).carregarModelos();
    });
  }

  // O método _recarregarModelos ainda é útil se você quiser
  // chamar o recarregamento por outros meios (ex: um botão de refresh no AppBar)
  Future<void> _recarregarModelos() async {
    await Provider.of<ModeloListProvider>(context, listen: false)
        .carregarModelos();
  }

  void _abrirDialogCadastroModelo() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const CadastroModeloDialog();
      },
    ).then((foiSalvo) {
      if (foiSalvo == true && mounted) {
        _recarregarModelos(); // <--- DESCOMENTE OU REATIVE ESTA CHAMADA!
      }
    });
  }

  void _abrirDialogEditarModelo(Modelo modelo) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return EditarModeloDialog(modeloParaEditar: modelo);
      },
    ).then((foiSalvo) {
      if (foiSalvo == true && mounted) {
        _recarregarModelos(); 
    }
  });
  }

  void _confirmarInativarModelo(Modelo modelo) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext confirmContext) => AlertDialog(
        title: const Text('Confirmar Inativação'),
        content: Text(
            'Tem certeza que deseja inativar o modelo "${modelo.nomeModelo}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(confirmContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(confirmContext).pop(true),
            child: const Text('Inativar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      // O inativarModelo no provider já cuida do refresh
      await Provider.of<ModeloListProvider>(context, listen: false)
          .inativarModelo(context, modelo.idModelo!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(226, 94, 99, 102),
        title: const Text('Modelos'),
        centerTitle: true,
        actions: [
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BarraPesquisaModelo(
              onSearchChanged: (texto) {
                Provider.of<ModeloListProvider>(context, listen: false)
                    .atualizarPesquisa(texto);
              },
            ),
          ),
          Expanded(
            child: Consumer<ModeloListProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.modelosFiltrados.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                      child: Text('Erro ao carregar dados: ${provider.error}'));
                }

                if (provider.modelosFiltrados.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.searchText.isEmpty
                                ? 'Nenhum modelo cadastrado.'
                                : 'Nenhum modelo encontrado para "${provider.searchText}".',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          // Botão opcional para recarregar caso não haja modelos
                          // ou em caso de erro, similar ao que foi feito antes.
                          if (provider.searchText.isEmpty && !provider.isLoading)
                            ElevatedButton.icon(
                              onPressed: _recarregarModelos,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Recarregar'),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.modelosFiltrados.length,
                  itemBuilder: (context, index) {
                    final modelo = provider.modelosFiltrados[index];
                    return ItemListaModelo(
                      modelo: modelo,
                      onModeloSelecionado: _abrirDialogEditarModelo,
                      onInativarModelo: _confirmarInativarModelo,
                    );
                  },
                );
              },
            ),
          ),
          // O SizedBox de 60 foi mantido, presumo que é para dar espaço para o FAB
          const SizedBox(height: 60),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogCadastroModelo,
        backgroundColor: const Color(0xFF1A1F71),
        tooltip: 'Cadastrar Modelo',
        child: const Icon(Icons.add),
      ),
    );
  }
}