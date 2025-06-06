import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Importe seus modelos
import '../../../model/patrimonio.dart';
import '../../../model/modelo.dart';
import '../../../model/marca.dart';
import '../../../model/fornecedor.dart';
import '../../../model/setor.dart';

// Importe seus providers
import '../../../providers/patrimonio_list_provider.dart';
import '../../../providers/modelo_list_provider.dart';
import '../../../providers/marca_list_provider.dart';
import '../../../providers/fornecedor_list_provider.dart';
import '../../../providers/setor_list_provider.dart';
import 'package:patricontrol/utils/Enums/tipoPatrimonio.dart';

// Importe seus dialogs de cadastro para outras entidades
import 'package:patricontrol/pages/marca/cadastroMarcadialog.dart';
import 'package:patricontrol/pages/modelo/cadastro_modelo_dialog.dart';
import 'package:patricontrol/pages/fornecedor/cadastrodialogFornecedor.dart';
// NOVAS IMPORTAÇÕES PARA OS WIDGETS DE SCANNER E ÚLTIMOS NÚMEROS
import 'package:patricontrol/widgets/patrimonio/BarcodeScannerPage.dart'; // Ajuste o caminho conforme onde você salvou este arquivo
import 'package:patricontrol/widgets/patrimonio/LastNumbersInputDialog.dart'; // Ajuste o caminho conforme onde você salvou este arquivo

class CadastroPatrimonioDialog extends StatefulWidget {
  const CadastroPatrimonioDialog({super.key});

  @override
  State<CadastroPatrimonioDialog> createState() =>
      _CadastroPatrimonioDialogState();
}

class _CadastroPatrimonioDialogState extends State<CadastroPatrimonioDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _localModeloImageUrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patrimonioProvider =
          Provider.of<PatrimonioListProvider>(context, listen: false);

      patrimonioProvider.limparCampos();

      if (patrimonioProvider.patrimonioController.patrimonioEmEdicao != null) {
        final patrimonioEmEdicao =
            patrimonioProvider.patrimonioController.patrimonioEmEdicao!;

        if (patrimonioEmEdicao.modelo?.imagemUrl != null &&
            patrimonioEmEdicao.modelo!.imagemUrl!.isNotEmpty) {
          setState(() {
            _localModeloImageUrl = patrimonioEmEdicao.modelo!.imagemUrl;
          });
        }
      }

      Provider.of<ModeloListProvider>(context, listen: false).carregarModelos();
      Provider.of<MarcaListProvider>(context, listen: false).carregarMarcas();
      Provider.of<FornecedorListProvider>(context, listen: false)
          .carregarFornecedores();
      Provider.of<SetorListProvider>(context, listen: false).carregarSetores();
    });
  }

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
                    if (patrimonioProvider
                            .patrimonioController.imagemSelecionadaBytes !=
                        null) {
                      setState(() {
                        _localModeloImageUrl =
                            null; // Zera a URL do modelo se uma nova imagem for selecionada
                      });
                    }
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
                    if (patrimonioProvider
                            .patrimonioController.imagemSelecionadaBytes !=
                        null) {
                      setState(() {
                        _localModeloImageUrl =
                            null; // Zera a URL do modelo se uma nova imagem for selecionada
                      });
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _abrirCadastroEntidadeDialog<T>(
      BuildContext context, Widget formDialog) async {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: formDialog,
      ),
    );
    if (T == Marca) {
      Provider.of<MarcaListProvider>(context, listen: false).carregarMarcas();
    } else if (T == Modelo) {
      Provider.of<ModeloListProvider>(context, listen: false).carregarModelos();
    } else if (T == Fornecedor) {
      Provider.of<FornecedorListProvider>(context, listen: false)
          .carregarFornecedores();
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  // NOVA FUNÇÃO: Abrir a página do scanner de código de barras
  Future<void> _scanBarcode(TextEditingController controller) async {
    print('DEBUG: _scanBarcode: Abrindo BarcodeScannerDialog...');
    final result = await showDialog<String>(
      // Agora usamos showDialog aqui!
      context: context,
      barrierDismissible:
          false, // Pode manter como false para forçar interação com o diálogo
      builder: (BuildContext dialogContext) {
        return const BarcodeScannerDialog(); // Chama a sua nova classe de diálogo do scanner
      },
    );

    if (!mounted) {
      print(
          'DEBUG: _scanBarcode: Widget CadastroPatrimonioDialog não está mais montado após retorno do scanner.');
      return;
    }

    if (result != null && result is String) {
      print('DEBUG: _scanBarcode: Resultado do scanner recebido: $result');
      controller.text = result;
      print(
          'DEBUG: _scanBarcode: Controller do código de patrimônio atualizado para: ${controller.text}');

      FocusScope.of(context).unfocus();
      print('DEBUG: _scanBarcode: Foco removido do campo de texto.');
    } else {
      print(
          'DEBUG: _scanBarcode: Scanner foi cancelado ou não retornou valor.');
    }
    print(
        'DEBUG: _scanBarcode: Final da função. O diálogo de cadastro DEVE continuar aberto.');
  }

  // NOVA FUNÇÃO: Abrir o dialog para inserir os últimos números
  Future<void> _showLastNumbersInputDialog(
      TextEditingController controller) async {
    print(
        'DEBUG: _showLastNumbersInputDialog: Abrindo LastNumbersInputDialog...');
    final String? formattedPatrimonio = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const LastNumbersInputDialog();
      },
    );

    // **** ADIÇÃO SUGERIDA AQUI ****
    if (!mounted) {
      print(
          'DEBUG: _showLastNumbersInputDialog: Widget CadastroPatrimonioDialog não está mais montado após retorno do dialog.');
      return; // O widget não está mais na árvore, não podemos continuar
    }

    if (formattedPatrimonio != null) {
      print(
          'DEBUG: _showLastNumbersInputDialog: Resultado do dialog recebido: $formattedPatrimonio');
      controller.text =
          formattedPatrimonio; // Preenche com o valor formatado retornado do dialog
      print(
          'DEBUG: _showLastNumbersInputDialog: Controller do código de patrimônio atualizado para: ${controller.text}');
      // Adicione este trecho para tentar remover o foco e evitar validação indesejada
      FocusScope.of(context).unfocus();
      print(
          'DEBUG: _showLastNumbersInputDialog: Foco removido do campo de texto.');
    } else {
      print(
          'DEBUG: _showLastNumbersInputDialog: Dialog de últimos números foi cancelado ou não retornou valor.');
    }
    print(
        'DEBUG: _showLastNumbersInputDialog: Final da função. O diálogo de cadastro DEVE continuar aberto.');
  }

  @override
  Widget build(BuildContext context) {
    final patrimonioProvider = Provider.of<PatrimonioListProvider>(context);
    final patrimonioController = patrimonioProvider.patrimonioController;

    final modeloProvider = Provider.of<ModeloListProvider>(context);
    final marcaProvider = Provider.of<MarcaListProvider>(context);
    final fornecedorProvider = Provider.of<FornecedorListProvider>(context);
    final setorProvider = Provider.of<SetorListProvider>(context);

    final mediaQuery = MediaQuery.of(context);
    final keyboardSpace = mediaQuery.viewInsets.bottom;

    Widget imageWidget;
    if (patrimonioController.isImageLoading) {
      imageWidget = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (patrimonioController.imagemSelecionadaBytes != null) {
      imageWidget = Image.memory(
        patrimonioController.imagemSelecionadaBytes!,
        fit: BoxFit.cover,
      );
    } else if (_localModeloImageUrl != null &&
        _localModeloImageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        _localModeloImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.broken_image,
            size: 80,
            color: Colors.grey,
          );
        },
      );
    } else {
      imageWidget = const Icon(
        Icons.image_not_supported_outlined,
        size: 80,
        color: Colors.grey,
      );
    }

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Cadastrar Novo Patrimônio',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
      content: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 20.0,
          bottom: 20.0 + keyboardSpace,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),

              // Campo Tipo (Dropdown: Custeio ou Capital)
              DropdownButtonFormField<TipoPatrimonio>(
                value: patrimonioController.selectedTipoPatrimonio,
                decoration: const InputDecoration(
                  labelText: 'Tipo *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: TipoPatrimonio.values.map((TipoPatrimonio tipo) {
                  return DropdownMenuItem<TipoPatrimonio>(
                    value: tipo,
                    child: Text(tipo.displayValue),
                  );
                }).toList(),
                onChanged: (TipoPatrimonio? newValue) {
                  if (newValue != null) {
                    patrimonioController.setSelectedTipoPatrimonio(newValue);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione o tipo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Dropdown Marca
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Marca>(
                      value: patrimonioController.selectedMarca,
                      items: marcaProvider.listaMarcas.map((Marca marca) {
                        return DropdownMenuItem<Marca>(
                          value: marca,
                          child: Text(marca.nome_marca),
                        );
                      }).toList(),
                      onChanged: (Marca? newValue) {
                        patrimonioController.setSelectedMarca(newValue);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Marca *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione a marca.';
                        }
                        return null;
                      },
                      isExpanded: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.blueGrey, size: 30),
                    onPressed: () => _abrirCadastroEntidadeDialog<Marca>(
                      context,
                      const CadastroMarcaDialog(),
                    ),
                    tooltip: 'Cadastrar nova marca',
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Dropdown Modelo
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Modelo>(
                      value: patrimonioController.selectedModelo,
                      items:
                          modeloProvider.modelosFiltrados.map((Modelo modelo) {
                        return DropdownMenuItem<Modelo>(
                          value: modelo,
                          child: Text(modelo.nomeModelo),
                        );
                      }).toList(),
                      onChanged: (Modelo? newValue) {
                        patrimonioController.setSelectedModelo(newValue);
                        setState(() {
                          _localModeloImageUrl = newValue?.imagemUrl;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Modelo *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.devices),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione o modelo.';
                        }
                        return null;
                      },
                      isExpanded: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.blueGrey, size: 30),
                    onPressed: () => _abrirCadastroEntidadeDialog<Modelo>(
                      context,
                      const CadastroModeloDialog(),
                    ),
                    tooltip: 'Cadastrar novo modelo',
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Campo Código com Scanner EAN13 - MODIFICADO
              TextFormField(
                controller: patrimonioController.codigoPatrimonioController,
                keyboardType: TextInputType.number, // Garante teclado numérico
                maxLength:
                    14, // Limita o máximo de caracteres para o patrimônio completo
                decoration: InputDecoration(
                  labelText: 'Código *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: Row(
                    // Usamos um Row para ter múltiplos ícones no suffix
                    mainAxisSize:
                        MainAxisSize.min, // Faz o Row ocupar o mínimo de espaço
                    children: [
                      // Ícone para abrir o dialog de "Últimos Números" (Esquerda)
                      IconButton(
                        icon: const Icon(Icons
                            .format_list_numbered), // Ou Icons.numbers, Icons.input
                        onPressed: () => _showLastNumbersInputDialog(
                            patrimonioController.codigoPatrimonioController),
                        tooltip: 'Preencher Últimos Números',
                      ),
                      // Ícone para Leitor de Código de Barras (Direita)
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () => _scanBarcode(patrimonioController
                            .codigoPatrimonioController), // Chamada para a nova função
                        tooltip: 'Escanear Código de Barras',
                      ),
                    ],
                  ),
                  counterText: '', // Oculta o contador de caracteres
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O código do patrimônio é obrigatório.';
                  }
                  if (value.length != 14) {
                    return 'O código do patrimônio deve ter 14 dígitos.';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'O código deve conter apenas números.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Campo Descrição
              TextFormField(
                controller: patrimonioController.descricaoPatrimonioController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 15),

              // Dropdown Fornecedor
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Fornecedor>(
                      value: patrimonioController.selectedFornecedor,
                      items: fornecedorProvider.listaFornecedores
                          .map((Fornecedor fornecedor) {
                        return DropdownMenuItem<Fornecedor>(
                          value: fornecedor,
                          child: Text(fornecedor.nome_fornecedor),
                        );
                      }).toList(),
                      onChanged: (Fornecedor? newValue) {
                        patrimonioController.setSelectedFornecedor(newValue);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Fornecedor *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione o fornecedor.';
                        }
                        return null;
                      },
                      isExpanded: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.blueGrey, size: 30),
                    onPressed: () => _abrirCadastroEntidadeDialog<Fornecedor>(
                      context,
                      const CadastroFornecedorDialog(),
                    ),
                    tooltip: 'Cadastrar novo fornecedor',
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Dropdown Setor de Origem
              DropdownButtonFormField<Setor>(
                value: patrimonioController.selectedSetorOrigem,
                items: setorProvider.listaSetores.map((Setor setor) {
                  return DropdownMenuItem<Setor>(
                    value: setor,
                    child: Text(setor.nome_setor),
                  );
                }).toList(),
                onChanged: (Setor? newValue) {
                  patrimonioController.setSelectedSetorOrigem(newValue);
                },
                decoration: const InputDecoration(
                  labelText: 'Setor de Origem *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione o setor de origem.';
                  }
                  return null;
                },
                isExpanded: true,
              ),
              const SizedBox(height: 15),

              // Campo NFE com Scanner (opcional) - MANTIDO A SIMULAÇÃO, MAS PODE SER ADAPTADO
              TextFormField(
                controller: patrimonioController.nfePatrimonioController,
                decoration: InputDecoration(
                  labelText: 'NFE',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.receipt),
                ),
              ),
              const SizedBox(height: 15),

              // Campo Lote
              TextFormField(
                controller: patrimonioController.lotePatrimonioController,
                decoration: const InputDecoration(
                  labelText: 'Lote',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 15),

              // Campo Data de Aquisição
              TextFormField(
                controller: patrimonioController.dataEntradaController,
                decoration: InputDecoration(
                  labelText: 'Data de Entrada',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () => _selectDate(
                        context, patrimonioController.dataEntradaController),
                    tooltip: 'Selecionar data',
                  ),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 20),

              // Botão para tirar foto/selecionar imagem
              ElevatedButton.icon(
                onPressed: () {
                  _showImageSourceSelectionModal(
                      context); // <-- Chama a nova função
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tirar/Escolher Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Exibição da imagem
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueGrey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageWidget,
                ),
              ),
              // Botão de remover imagem, visível apenas se houver uma imagem para remover
              if (patrimonioController.imagemSelecionadaBytes != null ||
                  (_localModeloImageUrl != null &&
                      _localModeloImageUrl!.isNotEmpty))
                TextButton(
                  onPressed: () {
                    patrimonioController.removerImagem();
                    setState(() {
                      _localModeloImageUrl = null;
                    });
                  },
                  child: const Text(
                    'Remover Imagem',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),

              // Botões de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      patrimonioController.limparCampos();
                      setState(() {
                        _localModeloImageUrl = null;
                      });
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: patrimonioProvider.isLoading ||
                            _isSubmitting // Desabilita se já estiver submetendo
                        ? null
                        : () async {
                            print('DEBUG: Botão Cadastrar pressionado.');
                            // Define a flag de submissão para true para evitar chamadas duplicadas
                            setState(() {
                              _isSubmitting = true;
                            });

                            if (_formKey.currentState!.validate()) {
                              print(
                                  'DEBUG: Formulário validado com sucesso. Chamando cadastrarPatrimonio...');
                              final sucesso = await patrimonioProvider
                                  .cadastrarPatrimonio(context);

                              if (sucesso) {
                                print(
                                    'DEBUG: Cadastro bem-sucedido, tentando fechar o diálogo.');
                                // Só fecha se o cadastro foi bem-sucedido
                                Navigator.of(context).pop(
                                    true); // Mude para true para indicar sucesso no pop
                              } else {
                                print(
                                    'DEBUG: Cadastro falhou (sucesso é false).');
                                // Opcional: mostrar uma mensagem de erro na tela aqui
                              }
                            } else {
                              print('DEBUG: Validação do formulário falhou.');
                              // Opcional: mostrar uma mensagem de erro na tela aqui se a validação falhou
                            }

                            // Reseta a flag de submissão após a tentativa de cadastro
                            setState(() {
                              _isSubmitting = false;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                    child: patrimonioProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Cadastrar'),
                  ),
                ],
              ),
              // Exibe erro geral, se houver
              if (patrimonioProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    patrimonioProvider.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
