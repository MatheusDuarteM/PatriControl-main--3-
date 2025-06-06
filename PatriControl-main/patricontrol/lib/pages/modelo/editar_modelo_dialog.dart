import 'dart:typed_data'; // Para Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controller/modelo_controller.dart'; // Ajuste o caminho se necessário
import '../../model/modelo.dart'; // Ajuste o caminho se necessário

class EditarModeloDialog extends StatefulWidget {
  final Modelo modeloParaEditar;

  const EditarModeloDialog({super.key, required this.modeloParaEditar});

  @override
  State<EditarModeloDialog> createState() => _EditarModeloDialogState();
}

class _EditarModeloDialogState extends State<EditarModeloDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  // Não use 'late' com Provider.of aqui, use context.read diretamente
  // para evitar problemas de BuildContext no initState.
  // late ModeloController _modeloController;

  bool _isEditingThisDialog = false; // Estado local para controlar o modo de edição/visualização

  @override
  void initState() {
    super.initState();
    // Acessa o controller de forma segura no initState
    final modeloController = context.read<ModeloController>();

    // Agende a chamada para `carregarDadosParaEdicao` para após o primeiro frame
    // Isso resolve o aviso `setState() or markNeedsBuild() called during build`
    // que pode ocorrer se `notifyListeners()` for chamado antes do widget estar completamente montado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      modeloController.carregarDadosParaEdicao(widget.modeloParaEditar);
      print('--- EditarModeloDialog initState ---');
      print('URL da imagem para edição (addPostFrameCallback): ${widget.modeloParaEditar.imagemUrl}');
      print('--- Fim initState ---');
    });

    // O _isEditingThisDialog começa como false (modo de visualização)
    _isEditingThisDialog = false;
  }

  // Não é mais necessário 'dispose' para os TextEditingControllers, pois eles
  // são gerenciados pelo ModeloController.

  void _toggleEdit() {
    setState(() {
      _isEditingThisDialog = !_isEditingThisDialog;
      if (!_isEditingThisDialog) {
        // Se o usuário clicou em 'Fechar' (ou 'Cancelar') enquanto estava editando,
        // reverte os dados para os originais no controller.
        context.read<ModeloController>().reverterDadosEdicao();
      }
    });
  }

  Future<void> _selecionarImagem(ImageSource source) async {
    if (_isEditingThisDialog) { // Só permite selecionar imagem se estiver em modo de edição
      try {
        final XFile? pickedFile =
            await _picker.pickImage(source: source, imageQuality: 80);
        if (pickedFile != null) {
          final Uint8List imageBytes = await pickedFile.readAsBytes();
          // Use context.read para chamar o método do controller
          context.read<ModeloController>().setImagemSelecionada(imageBytes, pickedFile.name);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao selecionar imagem: $e')));
        }
      }
    }
  }

  void _mostrarOpcoesSelecaoImagem() {
    if (_isEditingThisDialog) { // Só permite mostrar opções se estiver em modo de edição
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galeria'),
                    onTap: () {
                      Navigator.of(bc).pop();
                      _selecionarImagem(ImageSource.gallery);
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Câmera'),
                  onTap: () {
                    Navigator.of(bc).pop();
                    _selecionarImagem(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _editarModelo() async {
    if (_formKey.currentState!.validate()) {
      final modeloController = context.read<ModeloController>();

      // Verifica se a imagem é nula APENAS se o usuário tentou alterá-la
      // ou se o modelo original não tinha imagem e ele está editando.
      // O controller já tem a lógica de imagem obrigatória no `editarModelo`
      // baseada em `_editandoImagemFoiAlterada` e `_imagemSelecionadaBytes`.
      // Então, esta validação específica aqui pode ser redundante, mas não prejudica.
      if (modeloController.imagemSelecionadaBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('A imagem do modelo é obrigatória.'),
              backgroundColor: Colors.red));
        }
        return; // Sai da função se a imagem for nula
      }

      final sucesso = await modeloController.editarModelo(
        context, // Passe o contexto diretamente, ele é válido.
        widget.modeloParaEditar.idModelo!,
      );

      if (sucesso) {
        if (mounted) {
          Navigator.of(context).pop(true); // Indica sucesso e fecha o diálogo
        }
      } else {
        // O controller já mostra um SnackBar de erro.
        // Apenas não fecha o diálogo.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Acesso ao controller no build:
    // Para TextFormFields, é preferível usar `context.read` (ou `Provider.of(context, listen: false)`)
    // para evitar que todo o TextFormField seja reconstruído a cada `notifyListeners`.
    final modeloController = context.read<ModeloController>();

    return AlertDialog(
      title:
          Text(_isEditingThisDialog ? 'Editar Modelo' : 'Detalhes do Modelo'),
      contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: modeloController.nomeController,
                enabled: _isEditingThisDialog, // Habilita/desabilita campo
                decoration: const InputDecoration(labelText: 'Nome do Modelo *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o nome do modelo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: modeloController.corController,
                enabled: _isEditingThisDialog, // Habilita/desabilita campo
                decoration: const InputDecoration(labelText: 'Cor *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira a cor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: modeloController.descricaoController,
                enabled: _isEditingThisDialog, // Habilita/desabilita campo
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: Text(_isEditingThisDialog
                          ? 'Alterar Imagem'
                          : 'Ver Imagem'),
                      onPressed: _isEditingThisDialog
                          ? _mostrarOpcoesSelecaoImagem
                          : null, // Desabilita se não estiver em modo de edição
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditingThisDialog
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey, // Cor diferente quando desabilitado
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Consumer para a imagem e loading
                    Consumer<ModeloController>(
                      builder: (context, modeloCtrl, child) {
                        return Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: modeloCtrl.isLoading && modeloCtrl.imagemSelecionadaBytes == null // Mostra loading se estiver buscando a imagem inicial
                              ? const Center(child: CircularProgressIndicator())
                              : modeloCtrl.imagemSelecionadaBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: Image.memory(
                                        modeloCtrl.imagemSelecionadaBytes!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Center(
                                                child: Icon(Icons.error_outline,
                                                    size: 30, color: Colors.redAccent)),
                                      ),
                                    )
                                  : const Icon(Icons.image_outlined,
                                      size: 50, color: Colors.grey),
                        );
                      },
                    ),
                    // Exibe erro de carregamento de imagem se houver
                    Consumer<ModeloController>(
                      builder: (context, modeloCtrl, child) {
                        // Verifica se é um erro relacionado à imagem que deve ser exibido aqui
                        if (modeloCtrl.erroGeral != null && modeloCtrl.erroGeral!.contains('imagem')) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              modeloCtrl.erroGeral!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const SizedBox.shrink(); // Não mostra nada se não houver erro específico de imagem
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Se estiver em modo de edição, reverte os dados para o estado original
            // antes de fechar o dialog, caso o usuário não salve as alterações.
            if (_isEditingThisDialog) {
              modeloController.reverterDadosEdicao();
            }
            Navigator.of(context).pop(false); // Indica que foi cancelado/fechado sem salvar
          },
          child: const Text('Fechar'),
        ),
        // Botão "Editar" aparece apenas no modo de visualização
        if (!_isEditingThisDialog)
          ElevatedButton(
            onPressed: _toggleEdit,
            child: const Text('Editar'),
          ),
        // Botão "Salvar Alterações" aparece apenas no modo de edição
        if (_isEditingThisDialog)
          Consumer<ModeloController>(
            builder: (context, modeloCtrl, child) {
              return ElevatedButton(
                // Desabilita o botão se o controller estiver em estado de loading
                onPressed: modeloCtrl.isLoading ? null : _editarModelo,
                child: modeloCtrl.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                // Se a imagem não for válida, e não houver loading, também pode desabilitar
                // Isso já está sendo tratado na validação do _editarModelo, mas para a UI pode ser bom
                // onPressed: (modeloCtrl.isLoading || modeloCtrl.imagemSelecionadaBytes == null) ? null : _editarModelo,
                    : const Text('Salvar Alterações'),
              );
            },
          ),
      ],
    );
  }
}