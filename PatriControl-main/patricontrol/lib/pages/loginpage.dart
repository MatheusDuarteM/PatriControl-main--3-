import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart'; // Ajuste o caminho conforme sua estrutura

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _obscureSenha = true;

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _tentarLogin(BuildContext context) async {
    // Limpa mensagens de erro anteriores do AuthProvider antes de uma nova tentativa
    context.read<AuthProvider>().limparMensagemErroLogin();

    if (_formKey.currentState?.validate() ?? false) {
      final usuario = _usuarioController.text.trim();
      final senha = _senhaController.text.trim();

      // Chama o método login do AuthProvider
      // O AuthProvider cuidará de atualizar o estado (isLoading, isAuthenticated, mensagemErro)
      // e o Consumer no main.dart (ou onde estiver a lógica de roteamento)
      // redirecionará automaticamente se o login for bem-sucedido.
      await context.read<AuthProvider>().login(usuario, senha);

      // Após a tentativa de login, verificamos se ainda estamos na LoginPage
      // e se há uma mensagem de erro para exibir um SnackBar (opcional, pois o erro
      // também pode ser exibido diretamente na tela de login).
      if (mounted &&
          context.read<AuthProvider>().status ==
              StatusAutenticacao.falhaAutenticacao) {
        final erro = context.read<AuthProvider>().mensagemErroLogin;
        if (erro != null && erro.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(erro),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa um Consumer para reagir ao estado de isLoading e mensagemErro do AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Image.asset(
                    'assets/images/LogoSistema.png',
                    width: 300,
                    height: 300,
                  )
                ),
                const SizedBox(height: 15),
                Text(
                  'Bem-vindo ao PatriControl',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça login para continuar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 40),

                // Campo Usuário
                SizedBox(
                  width: 500,
                  child: TextFormField(
                    controller: _usuarioController,
                    decoration: InputDecoration(
                      labelText: 'Usuário',
                      hintText: 'Digite seu nome de usuário',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const UnderlineInputBorder()
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu usuário';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Senha
                SizedBox(
                  width: 500,
                  child: TextFormField(
                    controller: _senhaController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      hintText: 'Digite sua senha',
                      prefixIcon: const Icon(Icons.lock_person_outlined),
                      border: const UnderlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureSenha
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureSenha = !_obscureSenha;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureSenha,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      // Permite logar ao pressionar "Done" no teclado
                      if (!authProvider.isLoadingLogin) {
                        _tentarLogin(context);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Exibição de Mensagem de Erro (opcional, pode ser só SnackBar)
                if (authProvider.status ==
                        StatusAutenticacao.falhaAutenticacao &&
                    authProvider.mensagemErroLogin != null &&
                    authProvider.mensagemErroLogin!.isNotEmpty &&
                    !authProvider
                        .isLoadingLogin) // Não mostrar erro enquanto carrega
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      authProvider.mensagemErroLogin!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),

                // Botão de Login
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2C2C2C),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // Desabilita o botão enquanto estiver carregando
                    onPressed: authProvider.isLoadingLogin
                        ? null
                        : () => _tentarLogin(context),
                    child: authProvider.isLoadingLogin
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
