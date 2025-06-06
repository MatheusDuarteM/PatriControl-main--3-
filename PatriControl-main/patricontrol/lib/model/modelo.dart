import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Para debugPrint

class Modelo {
  final int? idModelo;
  final String nomeModelo;
  final String? corModelo; // TORNADO NULLABLE AQUI
  final Uint8List? imagemModeloBytes;
  final String? descricaoModelo;
  String? imagemUrl;
  final int? idMarca; // Adicionado para o filtro de marca no PatrimonioController

  Modelo({
    this.idModelo,
    required this.nomeModelo,
    this.corModelo, // REMOVIDO 'required' AQUI
    this.imagemModeloBytes,
    this.descricaoModelo,
    this.imagemUrl,
    this.idMarca, // Adicionar ao construtor
  });

  factory Modelo.fromJson(Map<String, dynamic> json) {
    String? urlDaImagem;
    if (json['imagem_modelo'] != null) {
      if (json['imagem_modelo'] is String) {
        urlDaImagem = json['imagem_modelo'] as String;
      } else if (json['imagem_modelo'] is Map) {
        debugPrint('AVISO: Campo imagem_modelo no JSON do Modelo é um Map, esperado String. Valor: ${json['imagem_modelo']}');
        urlDaImagem = null;
      } else {
        debugPrint('AVISO: Campo imagem_modelo no JSON do Modelo não é String nem Map. Tipo: ${json['imagem_modelo'].runtimeType}. Valor: ${json['imagem_modelo']}');
        urlDaImagem = json['imagem_modelo']?.toString();
      }
    }

    return Modelo(
      idModelo: json['id_modelo'] != null
          ? int.tryParse(json['id_modelo'].toString())
          : null,
      nomeModelo: json['nome_modelo']?.toString() ?? '',
      corModelo: json['cor_modelo']?.toString(), // Lendo como String?
      descricaoModelo: json['descricao_modelo']?.toString(),
      imagemModeloBytes: null,
      imagemUrl: urlDaImagem,
      idMarca: json['id_marca'] != null ? int.tryParse(json['id_marca'].toString()) : null, // Parseando idMarca
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nome_modelo': nomeModelo,
      'cor_modelo': corModelo, // Pode ser null aqui
      'descricao_modelo': descricaoModelo,
    };

    if (idModelo != null) {
      data['id_modelo'] = idModelo;
    }
    // Não inclua idMarca aqui se ele não é um campo a ser enviado diretamente no toJson de Modelo
    // (Ele é um campo do Modelo, mas para enviar à API de Modelo, provavelmente você não o envia)
    return data;
  }

  Modelo copyWith({
    int? idModelo,
    bool nullifyIdModelo = false,
    String? nomeModelo,
    String? corModelo,
    bool nullifyCorModelo = false, // Adicionado para corModelo
    Uint8List? imagemModeloBytes,
    bool nullifyImagemModeloBytes = false,
    String? descricaoModelo,
    bool nullifyDescricaoModelo = false,
    String? imagemUrl,
    bool nullifyImagemUrl = false,
    int? idMarca,
    bool nullifyIdMarca = false,
  }) {
    return Modelo(
      idModelo: nullifyIdModelo ? null : (idModelo ?? this.idModelo),
      nomeModelo: nomeModelo ?? this.nomeModelo,
      corModelo: nullifyCorModelo ? null : (corModelo ?? this.corModelo), // Tratamento para corModelo
      imagemModeloBytes: nullifyImagemModeloBytes
          ? null
          : (imagemModeloBytes ?? this.imagemModeloBytes),
      descricaoModelo: nullifyDescricaoModelo
          ? null
          : (descricaoModelo ?? this.descricaoModelo),
      imagemUrl: nullifyImagemUrl ? null : (imagemUrl ?? this.imagemUrl),
      idMarca: nullifyIdMarca ? null : (idMarca ?? this.idMarca),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Modelo &&
           idModelo != null &&
           other.idModelo == idModelo;
  }

  @override
int get hashCode {
  return Object.hash(idModelo, nomeModelo);
}

  @override
  String toString() {
    return 'Modelo(idModelo: $idModelo, nomeModelo: $nomeModelo, corModelo: $corModelo, hasImagemBytes: ${imagemModeloBytes != null}, descricaoModelo: $descricaoModelo, imagemUrl: $imagemUrl, idMarca: $idMarca)';
  }
}