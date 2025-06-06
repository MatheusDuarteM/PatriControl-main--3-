import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint (opcional, pode ser removido em produção)

class Marca extends Equatable {
  final int? id_marca;
  final String nome_marca;
  final int deletado_marca;

  Marca({
    this.id_marca,
    required this.nome_marca,
    this.deletado_marca = 0,
  });

  // Método fromJson para criar uma Marca a partir de um Map
  factory Marca.fromJson(Map<String, dynamic> json) {
    // Para id_marca:
    // Tenta parsear para int. Se já for int, usa direto.
    // Se for String, tenta parsear. Se falhar, é null.
    int? parsedIdMarca;
    if (json['id_marca'] != null) {
      if (json['id_marca'] is int) {
        parsedIdMarca = json['id_marca'] as int;
      } else if (json['id_marca'] is String) {
        parsedIdMarca = int.tryParse(json['id_marca']);
      } else {
        debugPrint('AVISO: Tipo inesperado para id_marca no JSON da Marca: ${json['id_marca'].runtimeType}. Valor: ${json['id_marca']}');
        // Define como null se o tipo for inesperado e não puder ser parseado
        parsedIdMarca = null;
      }
    }

    // Para nome_marca:
    // Garante que seja String. Se for null, usa string vazia.
    // Usamos toString() para converter outros tipos (int, bool) em string, se necessário.
    String parsedNomeMarca = json['nome_marca']?.toString() ?? '';
    // Se você tiver certeza que 'nome_marca' NUNCA será null ou outro tipo que não String,
    // pode usar: json['nome_marca'] as String

    // Para deletado_marca:
    // Tenta parsear para int. Se já for int, usa direto.
    // Se for String, tenta parsear. Se falhar, é 0 como fallback.
    int parsedDeletadoMarca = 0; // Valor padrão de fallback
    if (json['deletado_marca'] != null) {
      if (json['deletado_marca'] is int) {
        parsedDeletadoMarca = json['deletado_marca'] as int;
      } else if (json['deletado_marca'] is String) {
        parsedDeletadoMarca = int.tryParse(json['deletado_marca']) ?? 0;
      } else {
        debugPrint('AVISO: Tipo inesperado para deletado_marca no JSON da Marca: ${json['deletado_marca'].runtimeType}. Valor: ${json['deletado_marca']}');
        // Mantém o valor padrão de 0 se o tipo for inesperado
        parsedDeletadoMarca = 0;
      }
    }


    return Marca(
      id_marca: parsedIdMarca,
      nome_marca: parsedNomeMarca,
      deletado_marca: parsedDeletadoMarca,
    );
  }

  // Opcional: Método toJson para converter uma Marca em um Map
  Map<String, dynamic> toJson() {
    return {
      'id_marca': id_marca,
      'nome_marca': nome_marca,
      'deletado_marca': deletado_marca
    };
  }
  
  // --- CORREÇÃO AQUI: Use apenas o ID único para a comparação ---
  @override
  List<Object?> get props => [
        id_marca,
      ];
}