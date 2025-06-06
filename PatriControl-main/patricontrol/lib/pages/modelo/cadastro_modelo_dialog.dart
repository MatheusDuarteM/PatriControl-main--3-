import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controller/modelo_controller.dart';
// Importe o modelo se for necessário para um EditarModeloDialog, mas para CadastroModeloDialog puro, talvez não.
// import '../model/modelo.dart';

class CadastroModeloDialog extends StatefulWidget {
  // Para fins de demonstração, se este diálogo fosse reutilizado para edição,
  // você poderia adicionar um parâmetro 'modeloParaEdicao'.
  // final Modelo? modeloParaEdicao;
  // const CadastroModeloDialog({super.key, this.modeloParaEdicao});
  const CadastroModeloDialog({super.key});

  @override
  State<CadastroModeloDialog> createState() => _CadastroModeloDialogState();
}

class _CadastroModeloDialogState extends State<CadastroModeloDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  // Não use 'late' com Provider.of, pois o 'context' pode não estar totalmente disponível
  // no initState para 'listen: true'.
  // Prefira acessá-lo dentro do build ou em callbacks que são garantidos de ter um contexto válido.
  // Ou use `_modeloController = context.read<ModeloController>();` (equivalente a listen: false)
  // Mas como você já está usando `listen: false` nos text controllers, não precisa disso aqui.
  // E para o botão salvar, você vai usar um Consumer.

  @override
  void initState() {
    super.initState();
    // Acesse o controller usando `context.read` que é equivalente a `Provider.of(context, listen: false)`
    // e é a forma recomendada para acessar um provider que não precisa notificar rebuilds
    // imediatamente no initState.
    final modeloController = context.read<ModeloController>();
    // IMPORTANTE: Limpar os campos e a imagem ao abrir o dialog
    modeloController.limparCampos(); // Chama o método do controller para limpar tudo

    // Se este diálogo fosse reutilizado para edição, a lógica de carregarDadosParaEdicao
    // seria chamada aqui, agendada para o pós-frame.
    // if (widget.modeloParaEdicao != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     modeloController.carregarDadosParaEdicao(widget.modeloParaEdicao!);
    //   });
    // }
  }

  Future<void> _selecionarImagem(ImageSource source) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        // Acessar o controller usando context.read para evitar problemas de rebuild desnecessários
        // fora de um Consumer ou para chamadas de métodos.
        context.read<ModeloController>().setImagemSelecionada(imageBytes, pickedFile.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao selecionar imagem: $e')));
      }
    }
  }

  void _mostrarOpcoesSelecaoImagem() {
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

  Future<void> _cadastrarModelo() async {
    if (_formKey.currentState!.validate()) {
      // Usar `context.read` para acessar o controller para chamadas de método
      final modeloController = context.read<ModeloController>();

      if (modeloController.imagemSelecionadaBytes == null) {
        if (mounted) { // Check mounted antes de mostrar o SnackBar
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Por favor, adicione uma imagem.'),
              backgroundColor: Colors.red));
        }
        return;
      }

      // Não é necessário capturar o BuildContext aqui se você já está usando mounted
      // e o `context` dentro de um `State` é garantido de ser válido até `dispose`.
      // final BuildContext currentContext = context;

      // Chama o método no controller. O controller agora gerencia seu próprio loading e notificações.
      final sucesso = await modeloController.cadastrarModelo(context);

      if (sucesso) {
        if (mounted) {
          // Fecha o diálogo APENAS se a operação foi bem-sucedida.
          // O `pop(true)` pode ser útil se você quiser que o chamador saiba que foi um sucesso.
          Navigator.of(context).pop(true);
          
        }
      } else {
        // Se a operação não for bem-sucedida, o controller já mostra um SnackBar de erro.
        // Não é necessário fazer mais nada aqui, apenas não fechar o dialog.
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
      title: const Text('Cadastrar Novo Modelo'),
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
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Adicionar Imagem'),
                      onPressed: _mostrarOpcoesSelecaoImagem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Use Consumer para que apenas esta parte da UI (a exibição da imagem)
                    // seja reconstruída quando a imagem selecionada mudar no controller.
                    Consumer<ModeloController>(
                      builder: (context, modeloCtrl, child) {
                        return Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: modeloCtrl.imagemSelecionadaBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: Image.memory(
                                    modeloCtrl.imagemSelecionadaBytes!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.error_outline, size: 30, color: Colors.redAccent)),
                                  ),
                                )
                              : const Icon(Icons.image_outlined,
                                  size: 50, color: Colors.grey),
                        );
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
            // Ao cancelar, também limpa os campos para a próxima vez que o dialog for aberto.
            modeloController.limparCampos();
            Navigator.of(context).pop(false); // Indica que foi cancelado
          },
          child: const Text('Cancelar'),
        ),
        // Use Consumer para que o botão 'Salvar' (e seu estado de loading)
        // seja reconstruído apenas quando o `isLoading` do controller mudar.
        Consumer<ModeloController>(
          builder: (context, modeloCtrl, child) {
            return ElevatedButton(
              onPressed: modeloCtrl.isLoading ? null : _cadastrarModelo, // Desabilita se estiver carregando
              child: modeloCtrl.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Salvar'),
            );
          },
        ),
      ],
    );
  }
}