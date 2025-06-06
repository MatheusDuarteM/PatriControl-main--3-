import 'package:flutter/material.dart';
import 'package:patricontrol/pages/fornecedor/editardialogFornecedor.dart';
import 'package:patricontrol/providers/fornecedor_list_provider.dart';
import 'package:patricontrol/model/fornecedor.dart';
import 'package:patricontrol/pages/fornecedor/cadastrodialogFornecedor.dart';
import 'package:patricontrol/widgets/fornecedor/itemListaFornecedor.dart';
import 'package:patricontrol/widgets/fornecedor/barraPesquisaFornecedor.dart';
import 'package:provider/provider.dart';

class listaFornecedor extends StatefulWidget {
  const listaFornecedor({super.key});

  @override
  State<listaFornecedor> createState() => _listaFornecedorState();
}

class _listaFornecedorState extends State<listaFornecedor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Provider.of<FornecedorListProvider>(context, listen: false)
        .carregarFornecedores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Fornecedores'),
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
            child: Barrapesquisafornecedor(
                onSearchChanged:
                    Provider.of<FornecedorListProvider>(context, listen: false)
                        .atualizarPesquisa),
          ),
          Expanded(
            child: Consumer<FornecedorListProvider>(
              builder: (context, provider, child) {
                final listaFiltrada = provider.filtrarFornecedores();

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
                      'Nenhum fornecedor encontrado',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, index) {
                    final fornecedor = listaFiltrada[index];
                    return Itemlistafornecedor(
                      fornecedor: fornecedor,
                      onFornecedorSelecionado: (forn) =>
                          _abrirEditarFornecedor(context, forn),
                      onDeletarFornecedor: (forn) =>
                          _inativarFornecedor(context, forn),
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
        tooltip: 'Cadastrar Fornecedor',
        backgroundColor: const Color(0xFF1A1F71),
        onPressed: () {
          showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return const CadastroFornecedorDialog();
            },
          ).then((result) {
            if (result == true) {
              Provider.of<FornecedorListProvider>(context, listen: false)
                  .carregarFornecedores();
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

  void _abrirEditarFornecedor(BuildContext context, Fornecedor fornecedor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditarFornecedorDialog(fornecedor: fornecedor);
      },
    ).then((result) {
      if (result == true) {
        Provider.of<FornecedorListProvider>(context, listen: false)
            .carregarFornecedores();
      }
    });
  }

  Future<void> _inativarFornecedor(
      BuildContext contextDaTela, Fornecedor fornecedor) async {
    final confirmarExclusao = await showDialog<bool>(
      context: contextDaTela,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content:
              const Text('Tem certeza que deseja inativar este fornecedor?'),
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
      final sucesso = await Provider.of<FornecedorListProvider>(contextDaTela,
              listen: false)
          .inativarFornecedor(contextDaTela, fornecedor.id_fornecedor);
      if (sucesso && _scaffoldKey.currentState != null) {
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
          const SnackBar(content: Text('Fornecedor inativado com sucesso!')),
        );
        // O provider já cuida da atualização ao inativar
      } else if (_scaffoldKey.currentState != null) {
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
          const SnackBar(content: Text('Erro ao inativar o fornecedor.')),
        );
      }
    }
  }
}
