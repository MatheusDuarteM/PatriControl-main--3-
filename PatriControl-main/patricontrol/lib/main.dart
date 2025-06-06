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
import 'package:provider/provider.dart';

// --- PROVIDERS GLOBAIS ---

// --- SERVIÇOS ---
import 'package:patricontrol/services/modelo_service.dart';
import 'package:patricontrol/services/usuario_service.dart';
import 'package:patricontrol/services/patrimonio_service.dart';
// import 'package:patricontrol/services/movimentacao_service.dart'; // Se MovimentacaoService for usado diretamente no provider

// --- CONTROLLERS ---
import 'package:patricontrol/controller/usuario_controller.dart';
import 'package:patricontrol/controller/movimentacao_controller.dart'; // <--- NOVO IMPORT: MOVIMENTACAO CONTROLLER

// --- PROVIDERS DE LISTA ---
import 'package:patricontrol/providers/modelo_list_provider.dart';
import 'package:patricontrol/providers/usuario_list_provider.dart';
import 'package:patricontrol/providers/patrimonio_list_provider.dart';

// --- PÁGINAS DE MOVIMENTAÇÃO ---
import 'package:patricontrol/pages/movimentacao/movimentacao_list_page.dart'; // <--- NOVO IMPORT
//import 'package:patricontrol/pages/movimentacao/movimentacao_cadastro_page.dart'; // <--- NOVO IMPORT

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Função para construir a tela inicial baseada no status de autenticação
  Widget _buildInitialScreen(StatusAutenticacao status) {
    switch (status) {
      case StatusAutenticacao.inicializando:
        // Mostra um loader enquanto o AuthProvider verifica o status
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case StatusAutenticacao.autenticado:
        return DashboardScreen(); // Ou sua tela inicial após login
      case StatusAutenticacao.naoAutenticado:
      case StatusAutenticacao.falhaAutenticacao:
      default:
        // Caso contrário, mostra a LoginPage
        return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- SERVIÇOS ---
        // Provider de UsuarioService DEVE VIR ANTES do AuthProvider se este depender dele
        Provider<UsuarioService>(create: (_) => UsuarioService()),
        Provider<ModeloService>(create: (_) => ModeloService()),
        Provider<PatrimonioService>(create: (_) => PatrimonioService()),
        // Se o MovimentacaoService fosse usado em múltiplos controllers ou precisasse ser injetado
        // você poderia adicioná-lo aqui. Por enquanto, ele é instanciado dentro do MovimentacaoController.
        // Provider<MovimentacaoService>(create: (_) => MovimentacaoService()),

        // --- AUTH PROVIDER ---
        // É crucial que o AuthProvider seja criado e que verifique o login salvo
        ChangeNotifierProvider<AuthProvider>(
          create:
              (context) =>
                  AuthProvider(usuarioService: context.read<UsuarioService>())
                    ..verificarLoginSalvo(), // <-- CHAMADA IMPORTANTE!
        ),

        // --- CONTROLLERS ---
        ChangeNotifierProvider<ModeloController>(
          // Mantendo se ainda usado para formulários
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
          // <--- NOVO PROVIDER: MOVIMENTACAO CONTROLLER
          create: (context) => MovimentacaoController(),
        ),

        // --- PROVIDERS DE LISTA ---
        // (Se ModeloListProvider ainda for usado, mantenha-o)
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
            // Define a rota inicial baseada na autenticação.
            // Se o DashboardScreen for a tela principal após o login e contiver
            // a navegação para a lista de movimentações, não é necessário mudar a home aqui.
            // A rota para '/movimentacoes' será usada para navegação interna.
            home: _buildInitialScreen(authProvider.status),
            routes: {
              '/login': (context) => const LoginPage(),
              '/dashboard': (context) => DashboardScreen(),
              // --- NOVAS ROTAS PARA MOVIMENTAÇÃO ---
              MovimentacaoListPage.routeName:
                  (context) => const MovimentacaoListPage(),
              MovimentacaoCadastroPage.routeName:
                  (context) => const MovimentacaoCadastroPage(),
              // Suas outras rotas existentes...
            },
          );
        },
      ),
    );
  }
}
