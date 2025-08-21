import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/Preguntas.dart';

class PreguntasService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Pregunta>> obtenerPreguntasUser(String userId) async {
    try {
      final response = await _supabase
          .from('preguntas')
          .select('id_pregunta, pregunta, fecha, id_usuario, usuario(nombre)')
          .eq('id_usuario', userId)
          .order('fecha', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => Pregunta.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener preguntas: $e');
    }
  }

  Future<List<Pregunta>> obtenerTodasLasPreguntas() async {
    try {
      final dynamic response = await _supabase.from('preguntas').select('''
      id_pregunta,
      pregunta,
      fecha,
      id_usuario,
      usuario(nombre)
    ''').order('fecha', ascending: false);

      // Verificar si la respuesta es una lista
      if (response is List) {
        List<Pregunta> preguntas = [];

        for (final item in response) {
          if (item is Map<String, dynamic>) {
            try {
              preguntas.add(Pregunta.fromJson(item));
            } catch (e) {
              print("Error parseando item: $item");
              rethrow;
            }
          } else {
            print("Item inválido (no es Map<String, dynamic>): $item");
          }
        }

        return preguntas;
      } else {
        throw Exception(
            'Se esperaba una lista de preguntas, pero se recibió: ${response.runtimeType}');
      }
    } catch (e) {
      throw Exception('Error al obtener preguntas: $e');
    }
  }

  Future<void> crearPregunta(String texto) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await _supabase.from('preguntas').insert({
      'pregunta': texto,
      'fecha': DateTime.now().toIso8601String().split('T')[0],
      'id_usuario': user.id,
    });
  }

  Future<List<Pregunta>> obtenerResumenPreguntas() async {
    try {
      final dynamic response = await _supabase
          .from('vista_preguntas_con_total')
          .select()
          .order('fecha', ascending: false);

      print("Respuesta desde la vista: $response");

      if (response is List) {
        return response.map((item) {
          return Pregunta(
            idPregunta: item['id_pregunta'] as int,
            pregunta: item['pregunta'] as String,
            fecha: DateTime.parse(item['fecha'] as String),
            idUsuario: item['id_usuario'] as String?,
            nombreUsuario: item['nombre_usuario'] as String?, // importante
            totalRespuestas: item['total_respuestas'] as int,
          );
        }).toList();
      } else {
        throw Exception('La vista no devolvió una lista');
      }
    } catch (e) {
      print("Error en obtenerResumenPreguntas: $e");
      throw Exception('Error al obtener preguntas desde la vista: $e');
    }
  }
}
