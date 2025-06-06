import 'package:flutter/material.dart';
import 'package:patricontrol/pages/setor/editardialogSetor.dart';
import 'package:patricontrol/providers/setor_list_provider.dart';
import 'package:patricontrol/model/setor.dart';
import 'package:patricontrol/pages/setor/cadastrodialogSetor.dart';
import 'package:patricontrol/widgets/setor/itemListaSetor.dart';
import 'package:patricontrol/widgets/setor/barraPesquisaSetor.dart';
import 'package:provider/provider.dart';

class listaSetor extends StatefulWidget {
  const listaSetor({super.key});

  @override
  State<listaSetor> createState() => _listaSetorState();
}

class _listaSetorState extends State<listaSetor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Provider.of<SetorListProvider>(context, listen: false).carregarSetores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Setores'),
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
            child: Barrapesquisasetor(), // Removi o onSearchChanged daqui
          ),
          Expanded(
            child: Consumer<SetorListProvider>(
              builder: (context, provider, child) {
                final listaFiltrada = provider.listaSetores; // Use o getter 'listaSetores'

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
                      'Nenhum setor encontrado',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, index) {
                    final setor = listaFiltrada[index];
                    return Itemlistasetor(
                      setor: setor,
                      onSetorSelecionado: (forn) =>
                          _abrirEditarSetor(context, forn),
                      onDeletarSetor: (forn) =>
                          _inativarSetor(context, forn),
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
        tooltip: 'Cadastrar Setor',
        backgroundColor: const Color(0xFF1A1F71),
        onPressed: () {
          showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return const CadastroSetorDialog();
            },
          ).then((result) {
            if (result == true) {
              Provider.of<SetorListProvider>(context, listen: false)
                  .carregarSetores();
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

  void _abrirEditarSetor(BuildContext context, Setor setor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditarSetorDialog(setor: setor);
      },
    ).then((result) {
      if (result == true) {
        Provider.of<SetorListProvider>(context, listen: false)
            .carregarSetores();
      }
    });
  }

  Future<void> _inativarSetor(
      BuildContext contextDaTela, Setor setor) async {
    final confirmarExclusao = await showDialog<bool>(
      context: contextDaTela,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content:
              const Text('Tem certeza que deseja inativar este setor?'),
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
      final sucesso = await Provider.of<SetorListProvider>(contextDaTela,
              listen: false)
          .inativarSetor(contextDaTela, setor.id_setor);
      if (sucesso && _scaffoldKey.currentState != null) {
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
          const SnackBar(content: Text('Setor inativado com sucesso!')),
        );
        // O provider já cuida da atualização ao inativar
      } else if (_scaffoldKey.currentState != null) {
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
          const SnackBar(content: Text('Erro ao inativar o setor.')),
        );
      }
    }
  }
}