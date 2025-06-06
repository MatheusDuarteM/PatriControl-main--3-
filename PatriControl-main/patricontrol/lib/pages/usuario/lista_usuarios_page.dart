import 'package:flutter/material.dart';
import 'package:patricontrol/pages/usuario/editardialogUsuario.dart'; // Importe seu EditarUsuarioDialog
import 'package:patricontrol/providers/usuario_list_provider.dart'; // Importe seu UsuarioListProvider
import 'package:patricontrol/model/usuario.dart'; // Importe seu model Usuario
import 'package:patricontrol/pages/usuario/cadastrodialogUsuario.dart'; // Importe seu CadastroUsuarioDialog
import 'package:patricontrol/widgets/usuario/barra_pesquisa_usuario.dart';
import 'package:patricontrol/widgets/usuario/item_lista_usuario.dart';
import 'package:provider/provider.dart';

class listaUsuario extends StatefulWidget {
  const listaUsuario({super.key});

  @override
  State<listaUsuario> createState() => _listaUsuarioState();
}

class _listaUsuarioState extends State<listaUsuario> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Carrega os usuários ao iniciar a tela
    Provider.of<UsuarioListProvider>(context, listen: false)
        .carregarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Usuários'),
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
            child: BarraPesquisaUsuario( // Usando o widget de barra de pesquisa para Usuário
                onSearchChanged:
                    Provider.of<UsuarioListProvider>(context, listen: false)
                        .atualizarPesquisa),
          ),
          Expanded(
            child: Consumer<UsuarioListProvider>(
              builder: (context, provider, child) {
                final listaFiltrada = provider.filtrarUsuarios();

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
                      'Nenhum usuário encontrado',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, index) {
                    final usuario = listaFiltrada[index];
                    return ItemListaUsuario( // Usando o widget de item de lista para Usuário
                      usuario: usuario,
                      onUsuarioSelecionado: (user) =>
                          _abrirEditarUsuario(context, user),
                      onDeletarUsuario: (user) =>
                          _inativarUsuario(context, user),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 60), // Espaçamento para o FloatingActionButton
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Cadastrar Usuário',
        backgroundColor: const Color(0xFF1A1F71), // Cor do botão (exemplo)
        onPressed: () {
          showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return const CadastroUsuarioDialog(); // Abre o diálogo de cadastro de Usuário
            },
          ).then((result) {
            // Se o cadastro foi bem-sucedido (retornou true do diálogo), recarrega a lista
            if (result == true) {
              Provider.of<UsuarioListProvider>(context, listen: false)
                  .carregarUsuarios();
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

  /// Abre o diálogo de edição de usuário quando um item da lista é selecionado.
  void _abrirEditarUsuario(BuildContext context, Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditarUsuarioDialog(usuario: usuario); // Abre o diálogo de edição de Usuário
      },
    ).then((result) {
      // Se a edição foi bem-sucedida (retornou true do diálogo), recarrega a lista
      if (result == true) {
        Provider.of<UsuarioListProvider>(context, listen: false)
            .carregarUsuarios();
      }
    });
  }

  /// Confirma e inativa um usuário.
  Future<void> _inativarUsuario(
      BuildContext contextDaTela, Usuario usuario) async {
    final confirmarExclusao = await showDialog<bool>(
      context: contextDaTela,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Inativação'),
          content:
              const Text('Tem certeza que deseja inativar este usuário?'),
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
      final sucesso = await Provider.of<UsuarioListProvider>(contextDaTela,
              listen: false)
          .inativarUsuario(contextDaTela, usuario.idUsuario); // Chama o método do provider

      if (sucesso && _scaffoldKey.currentState != null) {
        // A mensagem de sucesso já deve ter sido mostrada pelo controller,
        // mas você pode adicionar outra aqui se desejar um feedback adicional.
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
          const SnackBar(content: Text('Usuário inativado com sucesso!')),
        );
        // O provider.inativarUsuario já cuida da atualização da lista
        // (ele chama carregarUsuarios internamente se for sucesso).
      } else if (_scaffoldKey.currentState != null) {
        // A mensagem de erro já deve ter sido mostrada pelo controller.
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
          const SnackBar(content: Text('Erro ao inativar o usuário.')),
        );
      }
    }
  }
}