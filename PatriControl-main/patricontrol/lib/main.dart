import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:patricontrol/controller/fornecedor_controller.dart';
import 'package:patricontrol/controller/marca_controller.dart';
import 'package:patricontrol/controller/modelo_controller.dart';
import 'package:patricontrol/controller/patrimonio_controller.dart';
import 'package:patricontrol/controller/setor_controller.dart';
import 'package:patricontrol/pages/dashboard/dashboard_screen.dart';
import 'package:patricontrol/pages/loginpage.dart';
import 'package:patricontrol/providers/authProvider.dart';
import 'package:patricontrol/providers/fornecedor_list_provider.dart';
import 'package:patricontrol/providers/marca_list_provider.dart';
import 'package:patricontrol/providers/setor_list_provider.dart';
import 'package:patricontrol/widgets/movimentacao/movimentacao_cadastro_page.dart';
// Removido o import de 'widgets' pois a página de cadastro deve estar em 'pages'
// import 'package:patricontrol/widgets/movimentacao/movimentacao_cadastro_page.dart';
import 'package:provider/provider.dart';

// --- SERVIÇOS ---
import 'package:patricontrol/services/modelo_service.dart';
import 'package:patricontrol/services/usuario_service.dart';
import 'package:patricontrol/services/patrimonio_service.dart';

// --- CONTROLLERS ---
import 'package:patricontrol/controller/usuario_controller.dart';
import 'package:patricontrol/controller/movimentacao_controller.dart';

// --- PROVIDERS DE LISTA ---
import 'package:patricontrol/providers/modelo_list_provider.dart';
import 'package:patricontrol/providers/usuario_list_provider.dart';
import 'package:patricontrol/providers/patrimonio_list_provider.dart';

// --- PÁGINAS DE MOVIMENTAÇÃO ---
import 'package:patricontrol/pages/movimentacao/movimentacao_list_page.dart';
// Certifique-se que este caminho está correto e o arquivo existe lá
//import 'package:patricontrol/pages/movimentacao/movimentacao_cadastro_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Função para construir a tela inicial baseada no status de autenticação
  Widget _buildInitialScreen(StatusAutenticacao status) {
    switch (status) {
      case StatusAutenticacao.inicializando:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case StatusAutenticacao.autenticado:
        return DashboardScreen(); // Esta tela DEVE ter o Drawer
      case StatusAutenticacao.naoAutenticado:
      case StatusAutenticacao.falhaAutenticacao:
      default:
        return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ***** A ESTRUTURA CORRETA VOLTA AQUI *****
    return MultiProvider(
      providers: [
        Provider<UsuarioService>(create: (_) => UsuarioService()),
        Provider<ModeloService>(create: (_) => ModeloService()),
        Provider<PatrimonioService>(create: (_) => PatrimonioService()),
        ChangeNotifierProvider<AuthProvider>(
          create:
              (context) => AuthProvider(
                usuarioService: context.read<UsuarioService>(),
              )..verificarLoginSalvo(), // Ou ..simularLoginParaTeste() se quiser pular o login
        ),
        ChangeNotifierProvider<ModeloController>(
          create: (context) => ModeloController(),
        ),
        ChangeNotifierProvider<UsuarioController>(
          create: (context) => UsuarioController(),
        ),
        ChangeNotifierProvider<FornecedorController>(
          create: (context) => FornecedorController(),
        ),
        ChangeNotifierProvider<MarcaController>(
          create: (context) => MarcaController(),
        ),
        ChangeNotifierProvider<SetorController>(
          create: (context) => SetorController(),
        ),
        ChangeNotifierProvider<PatrimonioController>(
          create: (context) => PatrimonioController(),
        ),
        ChangeNotifierProvider<MovimentacaoController>(
          create: (context) => MovimentacaoController(),
        ),
        ChangeNotifierProvider<ModeloListProvider>(
          create: (context) => ModeloListProvider(),
        ),
        ChangeNotifierProvider<UsuarioListProvider>(
          create: (context) => UsuarioListProvider(),
        ),
        ChangeNotifierProvider<FornecedorListProvider>(
          create: (context) => FornecedorListProvider(),
        ),
        ChangeNotifierProvider<MarcaListProvider>(
          create: (context) => MarcaListProvider(),
        ),
        ChangeNotifierProvider<SetorListProvider>(
          create: (context) => SetorListProvider(),
        ),
        ChangeNotifierProvider<PatrimonioListProvider>(
          create: (context) => PatrimonioListProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'PatriControl',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blueGrey[700],
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.blueGrey[600],
                foregroundColor: Colors.white,
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
            locale: const Locale('pt', 'BR'),
            home: _buildInitialScreen(authProvider.status),
            routes: {
              '/login': (context) => const LoginPage(),
              '/dashboard': (context) => DashboardScreen(),
              MovimentacaoListPage.routeName:
                  (context) => const MovimentacaoListPage(),
              MovimentacaoCadastroPage.routeName:
                  (context) => const MovimentacaoCadastroPage(),
            },
          );
        },
      ),
    );
    // *******************************************
  }
}
