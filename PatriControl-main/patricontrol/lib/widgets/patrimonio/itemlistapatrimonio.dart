// lib/pages/patrimonio/widgets/item_lista_patrimonio.dart
import 'package:flutter/material.dart';
import '../../../model/patrimonio.dart'; // Ajuste o caminho para seu modelo Patrimonio

class ItemListaPatrimonio extends StatelessWidget {
  final Patrimonio patrimonio;
  final Function(Patrimonio)? onPatrimonioSelecionado; // Para editar/visualizar
  final Function(Patrimonio)? onInativarPatrimonio; // Para inativar

  const ItemListaPatrimonio({
    super.key,
    required this.patrimonio,
    this.onPatrimonioSelecionado,
    this.onInativarPatrimonio,
  });

  // Método para construir o Widget de imagem (adaptado para Patrimonio)
  Widget _buildImage(Patrimonio patrimonio) {
    // Para simplificar, focaremos apenas na URL da imagem, como no provider de Patrimonio
    if (patrimonio.imagemPatrimonio != null && patrimonio.imagemPatrimonio!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          patrimonio.imagemPatrimonio!,
          width: 70, // Ajuste para o tamanho desejado
          height: 70, // Ajuste para o tamanho desejado
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Erro ao carregar imagem do patrimônio (network): $error');
            return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
          },
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    } else {
      return const Icon(Icons.inventory, // Ícone mais genérico para patrimônio
          size: 40, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onPatrimonioSelecionado != null
                    ? () => onPatrimonioSelecionado!(patrimonio)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: _buildImage(patrimonio), // A imagem do patrimônio
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              patrimonio.codigoPatrimonio ?? 'Sem Código',
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tipo: ${patrimonio.tipoPatrimonio}",
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            if (patrimonio.descricaoPatrimonio != null &&
                                patrimonio.descricaoPatrimonio!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Descrição: ${patrimonio.descricaoPatrimonio}",
                                  style:
                                      TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (patrimonio.modelo != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Modelo: ${patrimonio.modelo!.nomeModelo}",
                                  style:
                                      TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (patrimonio.marca != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Marca: ${patrimonio.marca!.nome_marca}",
                                  style:
                                      TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (patrimonio.setorAtual != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Setor: ${patrimonio.setorAtual!.nome_setor}",
                                  style:
                                      TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Botões de ação
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onInativarPatrimonio != null)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 30),
                  tooltip: 'Inativar Patrimônio',
                  onPressed: () => onInativarPatrimonio!(patrimonio),
                ),
            ],
          ),
        ],
      ),
    );
  }
}