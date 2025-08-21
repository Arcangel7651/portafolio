// lib/services/respuestas_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/respuesta.dart';

class RespuestasService {
  final _supabase = Supabase.instance.client;

  /// Obtiene todas las respuestas de una pregunta, incluyendo nombre de usuario
  Future<List<Respuesta>> obtenerRespuestas(int preguntaId) async {
    final resp = await _supabase
        .from('respuestas')
        .select(
            'id_respuesta, respuesta, id_pregunta, id_usuario, usuario(nombre)')
        .eq('id_pregunta', preguntaId)
        .order('id_respuesta', ascending: true);
    if (resp is List<dynamic>) {
      return resp.map((j) => Respuesta.fromJson(j)).toList();
    }
    throw Exception('Error al cargar respuestas');
  }

  /// Crea una nueva respuesta
  Future<void> crearRespuesta(int preguntaId, String texto) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await _supabase.from('respuestas').insert({
      'respuesta': texto,
      'id_pregunta': preguntaId,
      'id_usuario': user.id,
    });
  }
}
