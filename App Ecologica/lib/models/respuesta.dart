// lib/models/respuesta.dart
class Respuesta {
  final int idRespuesta;
  final String respuesta;
  final int? idPregunta;
  final String idUsuario;
  final String? nombreUsuario; // si deseas mostrar el nombre

  Respuesta({
    required this.idRespuesta,
    required this.respuesta,
    this.idPregunta,
    required this.idUsuario,
    this.nombreUsuario,
  });

  factory Respuesta.fromJson(Map<String, dynamic> json) => Respuesta(
        idRespuesta: json['id_respuesta'] as int,
        respuesta: json['respuesta'] as String,
        idPregunta: json['id_pregunta'] as int?,
        idUsuario: json['id_usuario'] as String,
        nombreUsuario: json['usuario']?['nombre'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id_respuesta': idRespuesta,
        'respuesta': respuesta,
        'id_pregunta': idPregunta,
        'id_usuario': idUsuario,
      };
}
