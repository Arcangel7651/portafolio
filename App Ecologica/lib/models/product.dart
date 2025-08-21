// lib/models/product.dart
import 'dart:convert';

class Product {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? estado;
  final double? precio;
  final String? ubicacion;
  final List<String>? imgs;
  final String? tipoCategoria;
  final String? idUsuario; // <— nuevo campo

  Product({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.estado,
    this.precio,
    this.ubicacion,
    this.imgs,
    this.tipoCategoria,
    this.idUsuario,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String>? imgsList;

    // Manejo del campo 'imgs' que es jsonb en la base de datos
    if (json['imgs'] != null) {
      if (json['imgs'] is List) {
        imgsList = List<String>.from(json['imgs']);
      } else if (json['imgs'] is String) {
        try {
          var decoded = jsonDecode(json['imgs']);
          if (decoded is List) {
            imgsList = List<String>.from(decoded);
          } else {
            imgsList = [json['imgs']];
          }
        } catch (_) {
          imgsList = [json['imgs']];
        }
      } else if (json['imgs'] is Map) {
        imgsList = [];
        (json['imgs'] as Map).forEach((_, value) {
          imgsList!.add(value.toString());
        });
      }
    }

    return Product(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as String?,
      precio: json['precio'] != null
          ? double.parse(json['precio'].toString())
          : null,
      ubicacion: json['ubicacion'] as String?,
      imgs: imgsList,
      tipoCategoria: json['tipo_categoria'] as String?,
      idUsuario: json['id_usuario'] as String?, // <— parse UUID string
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
      'precio': precio,
      'ubicacion': ubicacion,
      'imgs': imgs,
      'tipo_categoria': tipoCategoria,
      'id_usuario': idUsuario, // <— incluimos el UUID
    };

    return data;
  }

  @override
  String toString() {
    return 'Product(id: $id, nombre: $nombre, imgs: $imgs, idUsuario: $idUsuario)';
  }
}
