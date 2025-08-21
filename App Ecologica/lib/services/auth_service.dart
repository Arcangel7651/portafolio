import 'package:flutter/material.dart';
import 'package:iguanosquad/atributos/atributo_usuario.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Verifica si el usuario está autenticado
  Future<bool> isUserAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    return userId != null; // Si tiene un user_id guardado, está autenticado
  }

  /// Inicia sesión con Supabase Auth y luego obtiene la fila de `usuario`
  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    // 1. Autenticar con Supabase Auth
    final authRes = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = authRes.user;
    if (user == null) {
      print('No se obtuvo sesión de usuario');
      throw Exception('No se obtuvo sesión de usuario');
    }

    // Guardar ID del usuario localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);

// Guardar en variable estática
    UserData.userId = user.id;

    // 2. Traer datos extra del usuario (sin contraseña)
    final resp = await _supabase
        .from('usuario')
        .select(
            'id, nombre, correo_electronico, telefono, ubicacion, historial_participacion')
        .eq('id', user.id)
        .maybeSingle();

    if (resp == null) {
      print('Error al cargar perfil: ${resp.error!.message}');
      throw Exception('Error al cargar perfil: ${resp.error!.message}');
    }

    final data = resp as Map<String, dynamic>;
    if (data == null) {
      print('Usuario no encontrado en la tabla “usuario”');
      throw Exception('Usuario no encontrado en la tabla “usuario”');
    }

    return Usuario.fromJson(data);
  }

  /// Cierra la sesión
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Registra un nuevo usuario en Auth y en la tabla `usuario`
  Future<Usuario> register({
    required String nombre,
    required String email,
    required String password,
    required String ubicacion,
    required String telefono,
  }) async {
    try {
      // 1. Registrar usuario con email y password
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw Exception(
            'Error al registrar usuario: ${res.session?.accessToken ?? 'sin sesión activa'}');
      }

      final user = res.user!;

      debugPrint('Usuario registrado con ID: ${user.id}');

      // 2. Insertar datos adicionales en tu tabla `usuario`
      final insertRes = await _supabase
          .from('usuario')
          .insert({
            'id': user.id,
            'nombre': nombre,
            'correo_electronico': email,
            'ubicacion': ubicacion,
            'telefono': telefono,
          })
          .select()
          .single();

      print('Datos insertados correctamente en tabla `usuario`: $insertRes');

      return Usuario.fromJson(insertRes as Map<String, dynamic>);
    } catch (error, stackTrace) {
      print('Error durante el registro: $error');
      print('Stack trace: $stackTrace');
      throw Exception('Fallo en el proceso de registro: $error');
    }
  }
}
