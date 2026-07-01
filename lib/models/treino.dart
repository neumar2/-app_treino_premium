import 'dart:convert';

class Treino {
  final String id;
  final String nome;
  final List<String> exerciseIds;

  Treino({
    required this.id,
    required this.nome,
    required this.exerciseIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'exerciseIds': exerciseIds,
    };
  }

  factory Treino.fromMap(Map<String, dynamic> map) {
    return Treino(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      exerciseIds: List<String>.from(map['exerciseIds'] ?? map['musculos'] ?? []), // Suporte a legado
    );
  }

  String toJson() => json.encode(toMap());

  factory Treino.fromJson(String source) => Treino.fromMap(json.decode(source));
}
