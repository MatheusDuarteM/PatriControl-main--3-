import 'package:flutter/material.dart';
import 'package:patricontrol/model/marca.dart';

class ItemListaMarca extends StatelessWidget {
  final Marca marca;
  final Function(Marca)? onMarcaSelecionado;
  final Function(Marca)? onDeletarMarca;

  const ItemListaMarca({
    super.key,
    required this.marca,
    this.onMarcaSelecionado,
    this.onDeletarMarca
    });

  

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
              child: 
              InkWell(
                onTap: onMarcaSelecionado != null ? () => onMarcaSelecionado!(marca) : null,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(marca.nome_marca),
                    ],
                  ),
                ),
              ),
            )
          ),
          SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: (){
              if (onDeletarMarca != null) {
                  onDeletarMarca!(marca);
                }
            },
            icon: Icon(Icons.remove_circle_outline,size: 30),
            color: Colors.red,
          )
        ],
      ),
    );
  }
}