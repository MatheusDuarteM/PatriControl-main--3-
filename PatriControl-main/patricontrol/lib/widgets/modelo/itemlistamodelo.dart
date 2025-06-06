// lib/pages/modelo/widgets/item_lista_modelo.dart (OU SEU CAMINHO ATUAL)
import 'package:flutter/material.dart';
import '../../../model/modelo.dart'; // Ajuste o caminho para seu modelo Modelo

class ItemListaModelo extends StatelessWidget {
  final Modelo modelo;
  final Function(Modelo)? onModeloSelecionado; // Para editar/visualizar
  final Function(Modelo)? onInativarModelo; // Para inativar

  const ItemListaModelo({
    super.key,
    required this.modelo,
    this.onModeloSelecionado,
    this.onInativarModelo,
  });

  // Método para construir o Widget de imagem (mantido como está, pois já funciona bem)
  Widget _buildImage(Modelo modelo) {
    if (modelo.imagemModeloBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          modelo.imagemModeloBytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Erro ao carregar imagem (memory): $error');
            return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
          },
        ),
      );
    } else if (modelo.imagemUrl != null && modelo.imagemUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          modelo.imagemUrl!, // Usando a URL dinâmica do modelo
          width: 70, // Ajuste para o tamanho desejado
          height: 70, // Ajuste para o tamanho desejado
          fit: BoxFit.cover, // Ou outro BoxFit de sua preferência
          errorBuilder: (context, error, stackTrace) {
            print('Erro ao carregar imagem (network): $error');
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
      return const Icon(Icons.image_not_supported_outlined,
          size: 40, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('ItemListaModelo - Nome: ${modelo.nomeModelo}, URL: ${modelo.imagemUrl}'); // Comentado para evitar poluição no console
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10), // Padding do Row externo, igual ao fornecedor
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded( // O Card agora ocupa o espaço restante horizontalmente
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Borda do Card interno
              ),
              elevation: 5, // Elevação do Card interno
              child: InkWell(
                borderRadius: BorderRadius.circular(16), // Arredondamento para o InkWell também
                onTap: onModeloSelecionado != null
                    ? () => onModeloSelecionado!(modelo)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(15), // Padding interno do Card, igual ao fornecedor
                  child: Row( // Usamos um Row aqui para colocar a imagem e o texto lado a lado
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: _buildImage(modelo), // A imagem do modelo
                      ),
                      const SizedBox(width: 15), // Espaçamento entre a imagem e o texto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              modelo.nomeModelo,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Cor: ${modelo.corModelo}",
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            if (modelo.descricaoModelo != null &&
                                modelo.descricaoModelo!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Descrição: ${modelo.descricaoModelo}",
                                  style:
                                      TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  maxLines: 2,
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
          // Botões de ação, seguindo o padrão do fornecedor (fora do Card principal, no Row externo)
          const SizedBox(width: 10), // Espaçamento entre o Card e os botões
          // Usamos um Column para empilhar os botões verticalmente
          Column(
            mainAxisSize: MainAxisSize.min, // Para que a coluna não ocupe mais espaço que o necessário
            children: [
              if (onInativarModelo != null)
                IconButton(
                  icon:  Icon(Icons.remove_circle_outline, color: Colors.red, size: 30), // Ícone de inativar/arquivar
                  tooltip: 'Inativar Modelo',
                  onPressed: () => onInativarModelo!(modelo),
                ),
            ],
          ),
        ],
      ),
    );
  }
}