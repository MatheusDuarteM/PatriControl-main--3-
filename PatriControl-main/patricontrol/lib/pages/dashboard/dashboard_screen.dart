import 'package:flutter/material.dart';
import 'package:patricontrol/pages/movimentacao/movimentacao_list_page.dart'; // Importe a página de listagem
// Importe outras páginas que você vai navegar a partir do drawer
// import 'package:patricontrol/providers/authProvider.dart'; // Se precisar para logout ou nome do usuário
// import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard'; // Se você definir rotas assim

  @override
  Widget build(BuildContext context) {
    // Exemplo de como pegar o nome do usuário se AuthProvider estiver disponível
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final nomeUsuario = authProvider.usuarioLogado?.nomeUsuario ?? 'Usuário';
    // final privilegioUsuario = authProvider.usuarioLogado?.tipoUsuario ?? 'Privilégio';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'), // Ou o título da tela atual
      ),
      drawer: Drawer(
        // AQUI VOCÊ COLOCA O CÓDIGO DO SEU DRAWER
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey[700]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 60, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Usuário', // Substitua por: nomeUsuario,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    'Privilégio', // Substitua por: privilegioUsuario,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_box_outlined),
              title: const Text('Cadastro de Patrimônio'),
              onTap: () {
                Navigator.of(context).pop();
                // Exemplo: Navigator.of(context).pushNamed('/cadastro-patrimonio');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navegar para Cadastro de Patrimônio'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.search_outlined),
              title: const Text('Consulta de Patrimônio'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navegar para Consulta de Patrimônio'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.handshake_outlined),
              title: const Text('Cadastro de Fornecedor'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navegar para Cadastro de Fornecedor'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.sync_alt_outlined),
              title: const Text('Movimentações'),
              tileColor:
                  ModalRoute.of(context)?.settings.name ==
                          MovimentacaoListPage.routeName
                      ? Colors.blueGrey[100]
                      : null,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(MovimentacaoListPage.routeName);
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart_outlined),
              title: const Text('Relatórios'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navegar para Relatórios')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add_alt_1_outlined),
              title: const Text('Cadastro de Usuários'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navegar para Cadastro de Usuários'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.door_front_door_outlined),
              title: const Text('Cadastro de Setor'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navegar para Cadastro de Setor'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                Navigator.of(context).pop();
                // Lógica de logout
                // final auth = Provider.of<AuthProvider>(context, listen: false);
                // auth.logout();
                // Navigator.of(context).pushReplacementNamed('/login');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Ação de Sair')));
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Conteúdo do Dashboard Aqui')),
    );
  }
}
