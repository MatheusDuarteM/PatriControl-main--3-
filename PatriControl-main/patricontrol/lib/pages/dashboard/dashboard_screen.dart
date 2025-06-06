import 'package:flutter/material.dart';
import 'package:patricontrol/pages/fornecedor/listaFornecedor.dart';
import 'package:patricontrol/pages/marca/listaMarca.dart';
import 'package:patricontrol/pages/modelo/lista_modelos_page.dart';
import 'package:patricontrol/pages/patrimonio/listaPatrimonio.dart';
import 'package:patricontrol/pages/setor/listaSetor.dart';
import 'package:patricontrol/pages/usuario/lista_usuarios_page.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Teste'),
        backgroundColor: Colors.grey[300], // Cinza claro
        iconTheme: IconThemeData(color: Colors.black), // Ícone do Drawer preto
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                child: Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: Image.asset(
                'assets/images/LogoHeader.png',
                width: 304,
                fit: BoxFit.fitHeight
              ),
            )),
            ListTile(
              leading: Icon(Icons.all_inbox), // Ícone para Marcas
              title: Text('Patrimonios'),
              onTap: () {
                // Navegar para a tela de Cadastro de Marcas
                Navigator.pop(context); // Fecha o Drawer
                // Adicione aqui a sua lógica de navegação para a tela de Cadastro de Marcas
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ListaPatrimonioPage()) // Substitua Placeholder pela sua tela real
                    );
              },
            ),
            ListTile(
              leading: Icon(Icons.crop_square_outlined), // Ícone para Marcas
              title: Text('Cadastro de Modelos'),
              onTap: () {
                // Navegar para a tela de Cadastro de Marcas
                Navigator.pop(context); // Fecha o Drawer
                // Adicione aqui a sua lógica de navegação para a tela de Cadastro de Marcas
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ListaModelosPage()) // Substitua Placeholder pela sua tela real
                    );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.business), // Ícone para Fornecedor
              title: Text('Cadastro de Fornecedor'),
              onTap: () {
                // Navegar para a tela de Cadastro de Fornecedor
                Navigator.pop(context); // Fecha o Drawer
                // Adicione aqui a sua lógica de navegação para a tela de Cadastro de Fornecedor
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          listaFornecedor()), // Substitua Placeholder pela sua tela real
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.label), // Ícone para Marcas
              title: Text('Cadastro de Marcas'),
              onTap: () {
                // Navegar para a tela de Cadastro de Marcas
                Navigator.pop(context); // Fecha o Drawer
                // Adicione aqui a sua lógica de navegação para a tela de Cadastro de Marcas
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ListaMarcaPage()) // Substitua Placeholder pela sua tela real
                    );
              },
            ),
            ListTile(
              leading: Icon(Icons.door_back_door), // Ícone para Marcas
              title: Text('Cadastro de Setores'),
              onTap: () {
                // Navegar para a tela de Cadastro de Marcas
                Navigator.pop(context); // Fecha o Drawer
                // Adicione aqui a sua lógica de navegação para a tela de Cadastro de Marcas
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            listaSetor()) // Substitua Placeholder pela sua tela real
                    );
              },
            ),
            ListTile(
              leading: Icon(Icons.person), // Ícone para Marcas
              title: Text('Cadastro de Usuarios'),
              onTap: () {
                // Navegar para a tela de Cadastro de Marcas
                Navigator.pop(context); // Fecha o Drawer
                // Adicione aqui a sua lógica de navegação para a tela de Cadastro de Marcas
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            listaUsuario()) // Substitua Placeholder pela sua tela real
                    );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Tela Principal do Dashboard',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
