import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iguanosquad/services/articulo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class EditArticleScreen extends StatefulWidget {
  final Product articulo;

  const EditArticleScreen({Key? key, required this.articulo}) : super(key: key);

  @override
  State<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _descripcionController;
  late TextEditingController _ubicacionController;
  String? _estadoSeleccionado;
  String? _categoriaSeleccionada;

  List<String> _imageUrls = [];
  List<File> _newImageFiles = [];
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _urlsToDelete = [];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.articulo.nombre);
    _precioController = TextEditingController(
      text: widget.articulo.precio?.toStringAsFixed(2) ?? '',
    );
    _descripcionController =
        TextEditingController(text: widget.articulo.descripcion ?? '');
    _ubicacionController =
        TextEditingController(text: widget.articulo.ubicacion ?? '');
    _estadoSeleccionado = widget.articulo.estado ?? 'Nuevo';
    _categoriaSeleccionada = widget.articulo.tipoCategoria ?? 'Otros';
    // Inicializa URLs existentes:
    _imageUrls = widget.articulo.imgs ?? [];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() {
          _newImageFiles.addAll(images.map((x) => File(x.path)));
        });
      }
    } catch (e) {
      debugPrint('Error seleccionando imágenes: $e');
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> uploadedUrls = [];
    const String storageFolder = 'articulos';
    const String bucketName =
        'markedplace'; // Asegúrate de que este sea el nombre correcto del bucket

    for (var image in _newImageFiles) {
      try {
        final String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${uploadedUrls.length}.${image.path.split('.').last}';

        debugPrint('Subiendo imagen: $fileName');

        // Subir imagen al storage
        final response = await _supabase.storage.from(bucketName).upload(
              '$storageFolder/$fileName',
              image,
            );

        final String filePath = '$storageFolder/$fileName';
        final String imageUrl =
            _supabase.storage.from(bucketName).getPublicUrl(filePath);

        uploadedUrls.add(imageUrl);
        debugPrint('Imagen subida exitosamente: $imageUrl');
      } catch (e) {
        debugPrint('Error subiendo imagen: $e');
      }
    }

    debugPrint('URLs de las imágenes subidas: $uploadedUrls');
    return uploadedUrls;
  }

  Future<void> _editArticle() async {
    // Combina URLs y rutas locales antes de enviar:
    var newimageUrls = await _uploadImages();
    debugPrint('URLs de las imágenes antiguas: $_imageUrls');
    final allImgs = [
      ..._imageUrls, // _imageUrls ya no contiene las que el usuario borró
      ...newimageUrls,
    ];
    debugPrint('URLs de las imágenes buenas: $allImgs');
    debugPrint('URLs de las imágenes que se deben borrar: $_urlsToDelete');
    final orldURL = _imageUrls;

    final updated = Product(
      id: widget.articulo.id,
      nombre: _nombreController.text,
      precio: double.tryParse(_precioController.text),
      descripcion: _descripcionController.text,
      estado: _estadoSeleccionado,
      tipoCategoria: _categoriaSeleccionada,
      ubicacion: _ubicacionController.text,
      imgs: allImgs,
      idUsuario: widget.articulo.idUsuario,
    );
    final success = await ArticuloService().updateProduct(updated);
    if (success) {
      if (_urlsToDelete.isNotEmpty) {
        await ArticuloService().deleteImagesFromStorage(_urlsToDelete);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Artículo actualizado exitosamente')),
      );
      Navigator.pop(context, updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el artículo')),
      );
    }
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Una sola lista combinada para render:
    final allImages = <dynamic>[
      ..._imageUrls,
      ..._newImageFiles,
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Editar Artículo'),
                Text('Modifica los detalles del articulo',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Theme.of(context).primaryColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  const Text('Título del Artículo',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nombreController,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  const Text('Precio (\$)',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration().copyWith(
                      prefixText: '\$ ',
                      suffixIcon: const Icon(Icons.arrow_drop_up),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Estado
                  const Text('Estado',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    _estadoSeleccionado,
                    ['Nuevo', 'Usado', 'Como Nuevo'],
                    (v) => setState(() => _estadoSeleccionado = v),
                  ),
                  const SizedBox(height: 16),

                  // Categoría
                  const Text('Categoría',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    _categoriaSeleccionada,
                    ['Hogar', 'Ropa', 'Electrónica', 'Jardín', 'Otros'],
                    (v) => setState(() => _categoriaSeleccionada = v),
                  ),
                  const SizedBox(height: 16),

                  // Ubicación
                  const Text('Ubicación',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ubicacionController,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  const Text('Descripción',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descripcionController,
                    maxLines: 4,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 16),

                  // Imágenes
                  const Text('Imágenes',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      await _pickImages();
                      setState(() {});
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: (allImages.isEmpty)
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    size: 50, color: Colors.grey),
                                Text('Agregar imágenes',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            )
                          : Stack(
                              children: [
                                GridView.count(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 4,
                                  crossAxisSpacing: 4,
                                  padding: const EdgeInsets.all(4),
                                  children: allImages.map((img) {
                                    final isUrl = img is String;
                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: isUrl
                                              ? Image.network(
                                                  img as String,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  img as File,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              if (isUrl) {
                                                _urlsToDelete
                                                    .add(img as String);
                                                _imageUrls.remove(img);
                                              } else {
                                                _newImageFiles.remove(img);
                                              }
                                            }),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await _pickImages();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.add_photo_alternate,
                                        size: 16),
                                    label: const Text('Más fotos'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _editArticle,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Guardar Cambios',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Cancelar',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
