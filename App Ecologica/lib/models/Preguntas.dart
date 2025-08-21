// lib/models/pregunta.dart
import 'dart:convert';

class Pregunta {
  final int idPregunta;
  final String pregunta;
  final DateTime fecha;
  final String? idUsuario;
  final String? nombreUsuario;
  final int? totalRespuestas; // 🆕 Nuevo campo

  Pregunta({
    required this.idPregunta,
    required this.pregunta,
    required this.fecha,
    this.idUsuario,
    this.nombreUsuario,
    required this.totalRespuestas,
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    // Supabase nos devuelve la lista anidada de respuestas
    final List<dynamic>? respList = json['respuestas'] as List<dynamic>?;

    return Pregunta(
      idPregunta: json['id_pregunta'] as int,
      pregunta: json['pregunta'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      idUsuario: json['id_usuario'] as String?,
      nombreUsuario: json['usuario']?['nombre'] as String?,
      totalRespuestas: respList?.length ?? 0, // contamos cuántas hay
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pregunta': idPregunta,
      'pregunta': pregunta,
      'fecha': fecha.toIso8601String(),
      'id_usuario': idUsuario,
      'usuario': {'nombre': nombreUsuario},
      // Aunque no se use para enviar, lo dejamos por consistencia
      'total_respuestas': totalRespuestas,
    };
  }

  @override
  String toString() {
    return 'Pregunta(id: $idPregunta, texto: "$pregunta", '
        'usuario: ${nombreUsuario ?? "Anónimo"}, '
        'respuestas: $totalRespuestas)';
  }
}
