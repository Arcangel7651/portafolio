import 'package:flutter/material.dart';
import 'package:iguanosquad/models/Articulo.dart';
import 'package:iguanosquad/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'articulo.dart'; // Asegúrate de importar el modelo Articulo

class ArticuloService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> crearArticulo(Articulo articulo) async {
    final response = await _supabase
        .from('articulo') // Nombre de la tabla
        .insert(articulo.toJson())
        .execute();

    return 'Artículo creado exitosamente';
  }

  Future<List<Product>> getProductsByUser(String userId) async {
    final response = await _supabase
        .from('articulo')
        .select()
        .eq('id_usuario', userId)
        .order('id', ascending: false) // Los más recientes primero
        .execute();

    final data = response.data as List<dynamic>;
    // Mapear cada fila JSON a un Product
    return data
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<bool> updateProduct(Product producto) async {
    try {
      final response = await _supabase
          .from('articulo')
          .update({
            'nombre': producto.nombre,
            'precio': producto.precio,
            'descripcion': producto.descripcion,
            'estado': producto.estado,
            'tipo_categoria': producto.tipoCategoria,
            'ubicacion': producto.ubicacion,
            'imgs': producto.imgs,
            'id_usuario': producto.idUsuario,
          })
          .eq('id', producto.id)
          .execute();

      return true;
    } catch (e) {
      print('Excepción al actualizar: $e');
      return false;
    }
  }

  Future<void> deleteImagesFromStorage(List<String> urls) async {
    const String bucketName = 'markedplace'; // Asegúrate de que sea correcto

    // Convertimos URLs públicas en rutas internas del storage
    final List<String> pathsToDelete = urls.map((url) {
      final uri = Uri.parse(url);
      // Extraemos todo después del nombre del bucket
      final startIndex = url.indexOf(bucketName) + bucketName.length + 1;
      return url.substring(startIndex);
    }).toList();

    try {
      final response =
          await _supabase.storage.from(bucketName).remove(pathsToDelete);

      if (response.isEmpty) {
        debugPrint('Imágenes eliminadas correctamente');
      } else {
        debugPrint('Resultado inesperado al borrar: $response');
      }
    } catch (e) {
      debugPrint('Error al eliminar imágenes: $e');
    }
  }

  Future<bool> borrarArticuloPorId(int id) async {
    try {
      final response =
          await _supabase.from('articulo').delete().eq('id', id).execute();

      print('Artículo eliminado exitosamente.');
      return true;
    } catch (e) {
      print('Excepción al eliminar artículo: $e');
      return false;
    }
  }
}
