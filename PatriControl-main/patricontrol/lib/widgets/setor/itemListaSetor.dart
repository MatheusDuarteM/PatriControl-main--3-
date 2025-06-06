import 'package:flutter/material.dart';
import 'package:patricontrol/model/setor.dart';

class Itemlistasetor extends StatelessWidget {

  final Setor setor;
  final Function(Setor)? onSetorSelecionado;
  final Function(Setor)? onDeletarSetor;

  Itemlistasetor({
    super.key,
    required this.setor,
    this.onSetorSelecionado,
    this.onDeletarSetor
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
                onTap: onSetorSelecionado != null ? () => onSetorSelecionado!(setor) : null,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tipo: ${setor.tipo_setor}"),
                      Text("Nome: ${setor.nome_setor}"),
                      Text("Responsavel: ${setor.responsavel_setor}"),
                      Text("Descricao: ${setor.descricao_setor}"),
                      Text("Contato: ${setor.contato_setor}"),
                      Text("Email: ${setor.email_setor}"),
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
              if (onDeletarSetor != null) {
                  onDeletarSetor!(setor);
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
