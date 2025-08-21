class Articulo {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? estado;
  final double? precio;
  final String? ubicacion;
  final List<String>? imgs;
  final String? tipoCategoria;
  final String? idUsuario;

  Articulo({
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

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as String?,
      precio:
          (json['precio'] != null) ? (json['precio'] as num).toDouble() : null,
      ubicacion: json['ubicacion'] as String?,
      imgs:
          json['imgs'] != null ? List<String>.from(json['imgs'] as List) : null,
      tipoCategoria: json['tipo_categoria'] as String?,
      idUsuario: json['id_usuario'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
      'precio': precio,
      'ubicacion': ubicacion,
      'imgs': imgs,
      'tipo_categoria': tipoCategoria,
      'id_usuario': idUsuario,
    };
  }
}
