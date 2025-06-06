import 'package:flutter/material.dart';
import 'package:patricontrol/model/marca.dart';
import 'package:patricontrol/pages/marca/cadastroMarcaDialog.dart';
import 'package:patricontrol/pages/marca/editarMarcaDialog.dart';
import 'package:patricontrol/providers/marca_list_provider.dart';
import 'package:patricontrol/widgets/marca/barraPesquisaMarca.dart';
import 'package:patricontrol/widgets/marca/itemPesquisaMarca.dart';
import 'package:provider/provider.dart';

class ListaMarcaPage extends StatefulWidget {
  const ListaMarcaPage({super.key});

  @override
  State<ListaMarcaPage> createState() => _ListaMarcaPageState();
}

class _ListaMarcaPageState extends State<ListaMarcaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Provider.of<MarcaListProvider>(context, listen: false)
        .carregarMarcas();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Marcas'),
        backgroundColor: const Color.fromARGB(226, 94, 99, 102),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: BarraPesquisaMarca(
                onSearchChanged:
                    Provider.of<MarcaListProvider>(context, listen: false)
                        .atualizarPesquisa),
          ),
          Expanded(
            child: Consumer<MarcaListProvider>(
              builder: (context, provider, child) {
                final listaFiltrada = provider.filtrarMarcas();

                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                      child: Text('Erro ao carregar dados: ${provider.error}'));
                }

                if (listaFiltrada.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma marca encontrada',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, index) {
                    final marca = listaFiltrada[index];
                    return ItemListaMarca(
                      marca: marca,
                      onMarcaSelecionado: (marc) =>
                          _abrirEditarMarca(context, marc),
                      onDeletarMarca: (marc) =>
                          _inativarMarca(context, marc),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Cadastrar Marca',
        backgroundColor: const Color(0xFF1A1F71),
        onPressed: () {
          showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return const CadastroMarcaDialog();
            },
          ).then((result) {
            if (result == true) {
              Provider.of<MarcaListProvider>(context, listen: false)
                  .carregarMarcas();
            }
          });
        },
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  void _abrirEditarMarca(BuildContext context, Marca marca) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditarMarcaDialog(marca: marca);
      },
    ).then((result) {
      if (result == true) {
        Provider.of<MarcaListProvider>(context, listen: false)
        .carregarMarcas();
      }
    });
  }

  Future<void> _inativarMarca(BuildContext contextDaTela, Marca marca) async {
    final confirmarExclusao = await showDialog<bool>(
      context: contextDaTela,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja inativar este marca?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmarExclusao == true) {
      final sucesso =
          await Provider.of<MarcaListProvider>(contextDaTela, listen: false)
              .inativarMarca(contextDaTela, marca.id_marca);
      if (sucesso && _scaffoldKey.currentState != null) {
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
          const SnackBar(content: Text('Marca inativada com sucesso!')),
        );
        // O provider já cuida da atualização ao inativar
      } else if (_scaffoldKey.currentState != null) {
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
          const SnackBar(content: Text('Erro ao inativar a marca.')),
        );
      }
    }
  }
}
