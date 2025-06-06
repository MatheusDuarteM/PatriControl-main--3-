// lib/screens/patrimonio/editar_patrimonio_dialog.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patricontrol/controller/patrimonio_controller.dart';
import 'package:patricontrol/utils/Enums/tipoPatrimonio.dart';
import 'package:provider/provider.dart';

// Importe seus modelos. O PatrimonioListProvider já expõe as listas para os Dropdowns.
import 'package:patricontrol/model/patrimonio.dart'; // Para TipoPatrimonio (e StatusPatrimonio se for reintroduzido)
import 'package:patricontrol/model/modelo.dart';
import 'package:patricontrol/model/marca.dart';
import 'package:patricontrol/model/fornecedor.dart';
import 'package:patricontrol/model/setor.dart';

import 'package:patricontrol/providers/patrimonio_list_provider.dart'; // O provider que gerencia a lista e o controller

class PatrimonioEditDialog extends StatefulWidget {
  // Este diálogo agora é apenas para edição.
  // Não precisamos mais passar o 'patrimonio' como argumento,
  // pois o PatrimonioController já terá os dados carregados.
  const PatrimonioEditDialog({Key? key}) : super(key: key);

  @override
  State<PatrimonioEditDialog> createState() => _PatrimonioEditDialogState();
}

class _PatrimonioEditDialogState extends State<PatrimonioEditDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // A lógica de carregarDadosParaEdicao já é chamada na ListaPatrimonioPage
    // ANTES de abrir este dialog. Portanto, não precisamos fazer nada aqui.
  }

  @override
  Widget build(BuildContext context) {
    // Acessa o PatrimonioListProvider, que por sua vez expõe o PatrimonioController
    // e as listas de modelos, marcas, etc.
    final patrimonioListProvider = Provider.of<PatrimonioListProvider>(context);
    final patrimonioController = patrimonioListProvider.patrimonioController;

    Future<void> _showImageSourceSelectionModal(
        BuildContext dialogContext) async {
      final patrimonioProvider =
          Provider.of<PatrimonioListProvider>(dialogContext, listen: false);

      await showModalBottomSheet<void>(
        context: dialogContext,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeria'),
                  onTap: () {
                    Navigator.of(dialogContext).pop(); // Fecha o BottomSheet
                    patrimonioProvider.pickImageFromGallery().then((_) {
                      // Chama o método do provider
                      // setState necessário para reconstruir a UI do dialog
                      // e mostrar a nova imagem (se for o caso)
                      setState(() {});
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Câmera'),
                  onTap: () {
                    Navigator.of(dialogContext).pop(); // Fecha o BottomSheet
                    patrimonioProvider.pickImageFromCamera().then((_) {
                      // Chama o método do provider
                      // setState necessário para reconstruir a UI do dialog
                      // e mostrar a nova imagem (se for o caso)
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return AlertDialog(
      title: const Text('Editar Patrimônio'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Mostrar loading ou erro se o PatrimonioListProvider estiver carregando os dropdowns
            // ou se o controller estiver carregando/salvando dados.
            if (patrimonioListProvider.isLoading ||
                patrimonioController.isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Carregando dados...'),
                  ],
                ),
              )
            else if (patrimonioListProvider.error !=
                null) // Erro ao carregar dados iniciais (dropdowns)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      patrimonioListProvider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => patrimonioListProvider
                          .init(), // Tenta recarregar tudo
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              )
            else if (patrimonioController.erroGeral !=
                null) // Erro durante uma operação (salvar, etc.)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      patrimonioController.erroGeral!,
                      style: const TextStyle(color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // Não é necessário um botão de "Tentar Novamente" aqui,
                    // pois o erro é geralmente de uma operação anterior.
                    // O usuário pode ajustar os campos e tentar salvar novamente.
                  ],
                ),
              ),

            // O formulário só será exibido se não houver loading ou erro principal
            if (!patrimonioListProvider.isLoading &&
                patrimonioListProvider.error == null)
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller:
                          patrimonioController.codigoPatrimonioController,
                      decoration: const InputDecoration(
                          labelText: 'Código do Patrimônio *'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'O código é obrigatório.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown para Tipo de Patrimônio (Custeio/Capital)
                    DropdownButtonFormField<TipoPatrimonio>(
                      value: patrimonioController.selectedTipoPatrimonio,
                      decoration: const InputDecoration(
                          labelText: 'Tipo de Patrimônio *'),
                      items: TipoPatrimonio.values.map((TipoPatrimonio tipo) {
                        return DropdownMenuItem<TipoPatrimonio>(
                          value: tipo,
                          child: Text(
                            tipo.displayValue,
                            overflow: TextOverflow
                                .ellipsis, // <--- Adicione esta linha
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (TipoPatrimonio? newValue) {
                        patrimonioController
                            .setSelectedTipoPatrimonio(newValue);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione o tipo de patrimônio.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          patrimonioController.descricaoPatrimonioController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Dropdown para Modelo (usando dados do PatrimonioListProvider)
                    DropdownButtonFormField<Modelo>(
                      value: patrimonioController.selectedModelo,
                      decoration: const InputDecoration(labelText: 'Modelo *'),
                      items: patrimonioListProvider.modelosDisponiveis
                          .map((Modelo modelo) {
                        return DropdownMenuItem<Modelo>(
                          value: modelo,
                          child: Text(
                            modelo.nomeModelo ?? 'Modelo sem nome',
                            overflow: TextOverflow
                                .ellipsis, // <--- Adicione esta linha
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (Modelo? newValue) {
                        patrimonioController.setSelectedModelo(newValue);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione um modelo.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown para Marca (usando dados do PatrimonioListProvider)
                    DropdownButtonFormField<Marca>(
                      value: patrimonioController.selectedMarca,
                      decoration: const InputDecoration(labelText: 'Marca *'),
                      items: patrimonioListProvider.marcasDisponiveis
                          .map((Marca marca) {
                        return DropdownMenuItem<Marca>(
                          value: marca,
                          child: Text(
                            marca.nome_marca ?? 'Marca sem nome',
                            overflow: TextOverflow
                                .ellipsis, // <--- Adicione esta linha
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (Marca? newValue) {
                        patrimonioController.setSelectedMarca(newValue);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione uma marca.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown para Fornecedor (usando dados do PatrimonioListProvider)
                    DropdownButtonFormField<Fornecedor>(
                      value: patrimonioController.selectedFornecedor,
                      decoration:
                          const InputDecoration(labelText: 'Fornecedor *'),
                      items: patrimonioListProvider.fornecedoresDisponiveis
                          .map((Fornecedor fornecedor) {
                        return DropdownMenuItem<Fornecedor>(
                          value: fornecedor,
                          child: Text(
                            fornecedor.nome_fornecedor ?? 'Fornecedor sem nome',
                            overflow: TextOverflow
                                .ellipsis, // <--- Adicione esta linha
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (Fornecedor? newValue) {
                        patrimonioController.setSelectedFornecedor(newValue);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione um fornecedor.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown para Setor de Origem (usando dados do PatrimonioListProvider)
                    DropdownButtonFormField<Setor>(
                      value: patrimonioController.selectedSetorOrigem,
                      decoration:
                          const InputDecoration(labelText: 'Setor de Origem *'),
                      items: patrimonioListProvider.setoresDisponiveis
                          .map((Setor setor) {
                        return DropdownMenuItem<Setor>(
                          value: setor,
                          child: Text(
                            setor.nome_setor ?? 'Setor sem nome',
                            overflow: TextOverflow
                                .ellipsis, // <--- Adicione esta linha
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (Setor? newValue) {
                        patrimonioController.setSelectedSetorOrigem(newValue);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione o setor de origem.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown para Setor Atual (Sempre visível na edição)
                    DropdownButtonFormField<Setor>(
                      value: patrimonioController.selectedSetorAtual,
                      decoration:
                          const InputDecoration(labelText: 'Setor Atual *'),
                      items: patrimonioListProvider.setoresDisponiveis
                          .map((Setor setor) {
                        return DropdownMenuItem<Setor>(
                          value: setor,
                          child: Text(
                            setor.nome_setor ?? 'Setor sem nome',
                            overflow: TextOverflow
                                .ellipsis, // <--- Adicione esta linha
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (Setor? newValue) {
                        patrimonioController.setSelectedSetorAtual(newValue);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione o setor atual.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: patrimonioController.nfePatrimonioController,
                      decoration: const InputDecoration(labelText: 'NFE'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: patrimonioController.lotePatrimonioController,
                      decoration: const InputDecoration(labelText: 'Lote'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: patrimonioController.dataEntradaController,
                      decoration: InputDecoration(
                        labelText: 'Data de Entrada (dd/MM/yyyy)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? initialDate;
                            try {
                              initialDate = DateFormat('dd/MM/yyyy')
                                  .parseStrict(patrimonioController
                                      .dataEntradaController.text);
                            } catch (_) {
                              initialDate = DateTime.now();
                            }

                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              locale: const Locale('pt', 'BR'),
                            );
                            if (picked != null) {
                              patrimonioController.dataEntradaController.text =
                                  DateFormat('dd/MM/yyyy').format(picked);
                            }
                          },
                        ),
                      ),
                      readOnly:
                          true, // Torna o campo somente leitura, incentivando o DatePicker
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            DateFormat('dd/MM/yyyy').parseStrict(value);
                          } catch (e) {
                            return 'Formato de data inválido (dd/MM/yyyy).';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // IMAGEM
                    // Visualização da imagem atual (se houver e não for um novo upload ainda)
                    if (patrimonioController.imagemSelecionadaBytes != null)
                      Column(
                        children: [
                          const Text('Imagem Atual:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Image.memory(
                            patrimonioController.imagemSelecionadaBytes!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          TextButton(
                            onPressed: () {
                              patrimonioController.setImagemSelecionada(
                                  null, null); // Limpa a imagem
                            },
                            child: const Text('Remover Imagem Atual'),
                          ),
                          const SizedBox(height: 8),
                        ],
                      )
                    else if (patrimonioController
                                .patrimonioEmEdicao?.imagemPatrimonio !=
                            null &&
                        patrimonioController
                            .patrimonioEmEdicao!.imagemPatrimonio!.isNotEmpty &&
                        !patrimonioController.editandoImagemFoiAlterada)
                      // Se tem URL de imagem mas não foi selecionada uma nova, e não está carregando a imagem original
                      // (A imagem já deve ter sido carregada em bytes pelo carregarDadosParaEdicao)
                      const Text(
                          'Imagem original sendo carregada ou erro ao exibir.',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),

                    // Botão para selecionar imagem
                    ElevatedButton.icon(
                      onPressed: () {
                        _showImageSourceSelectionModal(
                            context); // <-- Chama a nova função
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Selecionar Nova Imagem'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Exibir nome da imagem selecionada ou mensagem
                    if (patrimonioController.nomeArquivoImagemSelecionada !=
                            null &&
                        patrimonioController
                            .nomeArquivoImagemSelecionada!.isNotEmpty)
                      Text(
                          'Nova imagem selecionada: ${patrimonioController.nomeArquivoImagemSelecionada}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.blueAccent))
                    else if (patrimonioController.imagemSelecionadaBytes ==
                            null &&
                        patrimonioController
                                .patrimonioEmEdicao?.imagemPatrimonio ==
                            null &&
                        !patrimonioController.isLoading)
                      const Text('Nenhuma imagem selecionada.',
                          style: TextStyle(fontSize: 12, color: Colors.red)),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            patrimonioController
                .reverterDadosEdicao(); // Reverte os campos para o estado original
            Navigator.of(context)
                .pop(false); // Indica que a operação foi cancelada
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: patrimonioController.isLoading
              ? null // Desabilita o botão enquanto estiver carregando
              : () async {
                  if (_formKey.currentState!.validate()) {
                    // Chama editar no controller
                    bool success =
                        await patrimonioController.editarPatrimonio(context);

                    if (success) {
                      Navigator.of(context)
                          .pop(true); // Indica que a operação foi bem-sucedida
                    }
                  }
                },
          child: const Text('Salvar Edição'),
        ),
      ],
    );
  }
}
