import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patricontrol/controller/movimentacao_controller.dart';
import 'package:patricontrol/model/movimentacao.dart'; // Para PatrimonioParaSelecao
import 'package:patricontrol/model/setor.dart';
import 'package:patricontrol/services/movimentacao_service.dart'; // Para buscar patrimônios
import 'package:provider/provider.dart';

class MovimentacaoCadastroPage extends StatefulWidget {
  const MovimentacaoCadastroPage({super.key});

  static const routeName = '/movimentacao-cadastro';

  @override
  State<MovimentacaoCadastroPage> createState() =>
      _MovimentacaoCadastroPageState();
}

class _MovimentacaoCadastroPageState extends State<MovimentacaoCadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patrimonioSearchController =
      TextEditingController();
  List<PatrimonioParaSelecao> _searchResults = [];
  bool _isSearchingPatrimonio = false;

  // Usar o MovimentacaoService diretamente para busca,
  // ou idealmente injetar via Provider se ele for gerenciado como estado.
  // Aqui, vamos instanciar para simplificar.
  final MovimentacaoService _movService = MovimentacaoService();

  Future<void> _buscarPatrimonios(String termo) async {
    if (termo.length < 2) {
      // Evita buscas com poucos caracteres
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isSearchingPatrimonio = true;
    });
    try {
      final resultados = await _movService.buscarPatrimoniosParaSelecao(termo);
      setState(() {
        _searchResults = resultados;
      });
    } catch (e) {
      // Tratar erro
      print("Erro ao buscar patrimônios: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao buscar patrimônios.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSearchingPatrimonio = false;
      });
    }
  }

  Future<void> _selecionarData(
    BuildContext context,
    MovimentacaoController controller,
  ) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: controller.cadastroDataMovimentacao,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (dataSelecionada != null) {
      controller.setCadastroDataMovimentacao(dataSelecionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MovimentacaoController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Movimentação')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Busca e Seleção de Patrimônio ---
              Text(
                'Patrimônio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _patrimonioSearchController,
                decoration: InputDecoration(
                  labelText: 'Digite nome ou código do patrimônio',
                  suffixIcon:
                      _isSearchingPatrimonio
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed:
                                () => _buscarPatrimonios(
                                  _patrimonioSearchController.text,
                                ),
                          ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: _buscarPatrimonios, // Busca dinâmica enquanto digita
              ),
              if (_searchResults.isNotEmpty &&
                  controller.patrimonioSelecionado == null)
                SizedBox(
                  height: 150, // Limita altura da lista de resultados
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (ctx, index) {
                      final patrimonio = _searchResults[index];
                      return ListTile(
                        title: Text(
                          '${patrimonio.codigo} - ${patrimonio.descricao}',
                        ),
                        subtitle: Text(
                          'Setor: ${patrimonio.setorAtual?.nome ?? "N/A"}',
                        ),
                        onTap: () {
                          controller.selecionarPatrimonio(patrimonio);
                          _patrimonioSearchController.clear();
                          setState(() {
                            _searchResults = [];
                          }); // Limpa resultados após seleção
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // --- Card do Patrimônio Selecionado ---
              if (controller.patrimonioSelecionado != null)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Patrimônio Selecionado',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              tooltip: 'Limpar Seleção',
                              onPressed:
                                  () => controller.limparSelecaoPatrimonio(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Placeholder para Imagem
                        if (controller.patrimonioSelecionado!.imagemUrl !=
                                null &&
                            controller
                                .patrimonioSelecionado!
                                .imagemUrl!
                                .isNotEmpty)
                          Center(
                            child: Image.network(
                              controller.patrimonioSelecionado!.imagemUrl!,
                              height: 100,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 60),
                            ),
                          )
                        else
                          const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Código: ${controller.patrimonioSelecionado!.codigo}',
                        ),
                        Text(
                          'Descrição: ${controller.patrimonioSelecionado!.descricao}',
                        ),
                        if (controller.patrimonioSelecionado!.marca != null)
                          Text(
                            'Marca: ${controller.patrimonioSelecionado!.marca}',
                          ),
                        if (controller.patrimonioSelecionado!.modelo != null)
                          Text(
                            'Modelo: ${controller.patrimonioSelecionado!.modelo}',
                          ),
                        //Text('Cor: ${controller.patrimonioSelecionado!.cor ?? 'N/A'}'),
                        Text(
                          'Status: ${controller.patrimonioSelecionado!.status ?? 'N/A'}',
                        ),
                        Text(
                          'Setor Atual: ${controller.patrimonioSelecionado!.setorAtual?.nome ?? 'N/A'}',
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // --- Tipo de Movimentação ---
              DropdownButtonFormField<String?>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Movimentação *',
                  border: OutlineInputBorder(),
                ),
                value: controller.cadastroTipoMovimentacao,
                hint: const Text('Selecione o tipo'),
                isExpanded: true,
                items:
                    controller.tiposDeMovimentacao.map((String tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                onChanged: (String? novoValor) {
                  controller.setCadastroTipoMovimentacao(novoValor);
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Selecione um tipo'
                            : null,
              ),
              const SizedBox(height: 16),

              // --- Setor de Destino (condicional) ---
              // Aparece se não for DESCARTE
              if (controller.cadastroTipoMovimentacao != "DESCARTE")
                DropdownButtonFormField<Setor?>(
                  decoration: const InputDecoration(
                    labelText: 'Setor de Destino *',
                    border: OutlineInputBorder(),
                  ),
                  value: controller.cadastroSetorDestino,
                  hint: const Text('Selecione o setor'),
                  isExpanded: true,
                  items:
                      controller.setoresDisponiveis.map((Setor setor) {
                        return DropdownMenuItem<Setor>(
                          value: setor,
                          child: Text(setor.nome),
                        );
                      }).toList(),
                  onChanged: (Setor? novoValor) {
                    controller.setCadastroSetorDestino(novoValor);
                  },
                  validator: (value) {
                    if (controller.cadastroTipoMovimentacao != "DESCARTE" &&
                        value == null) {
                      return 'Selecione um setor de destino';
                    }
                    return null;
                  },
                ),
              if (controller.cadastroTipoMovimentacao != "DESCARTE")
                const SizedBox(height: 16),

              // --- Descrição/Observação ---
              TextFormField(
                controller: controller.cadastroObservacaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição/Observação',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // --- Data da Movimentação ---
              ListTile(
                title: Text(
                  'Data da Movimentação: ${DateFormat('dd/MM/yyyy').format(controller.cadastroDataMovimentacao)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selecionarData(context, controller),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 32),

              // --- Botões ---
              ElevatedButton(
                onPressed:
                    controller.isLoading ||
                            controller.patrimonioSelecionado == null
                        ? null // Desabilita se estiver carregando ou nenhum patrimônio selecionado
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            final sucesso = await controller
                                .submeterCadastroMovimentacao(context);
                            if (sucesso && mounted) {
                              Navigator.of(context).pop(); // Volta para a lista
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    controller.isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Salvar',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  controller.limparFormularioCadastro();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
