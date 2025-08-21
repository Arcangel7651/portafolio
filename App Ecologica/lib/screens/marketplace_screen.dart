// lib/screens/marketplace_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/product_categories.dart';
import '../models/product.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();
  List<Product> _products = [];
  bool _isLoading = true;
  String _selectedCategory = ProductCategories.todos;

  // Controladores y variables para el formulario
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedState = ProductCategories.estados.first;
  List<File> _selectedImages = [];
  bool _isUploadingImages = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      // Usa select() sin execute() según la API más reciente de Supabase Flutter
      final response = await _supabase
          .from('articulo')
          .select()
          .order('id', ascending: false);

      if (response != null) {
        setState(() {
          _products =
              (response as List).map((json) => Product.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error cargando productos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar los productos')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // FUNCIÓN CORREGIDA: Ahora recibe el setDialogState como parámetro
  Future<void> _pickImages(StateSetter setDialogState) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        // SOLO usamos setDialogState, NO setState del widget principal
        setDialogState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
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

    for (var image in _selectedImages) {
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

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isUploadingImages = true);
    List<String> imageUrls = [];

    try {
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _uploadImages();
        debugPrint('URLs de imágenes subidas: $imageUrls');
      }

      final String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Debes iniciar sesión para crear una actividad')),
        );
        return;
      }
      // Verificamos que tengamos las URLs antes de insertar
      final response = await _supabase.from('articulo').insert({
        'nombre': _titleController.text,
        'descripcion': _descriptionController.text,
        'estado': _selectedState,
        'precio': double.parse(_priceController.text),
        'ubicacion': _locationController.text,
        'imgs': imageUrls, // Pasamos la lista de URLs
        'tipo_categoria': _selectedCategory == ProductCategories.todos
            ? ProductCategories.values.first
            : _selectedCategory,
        'id_usuario': userId,
      });

      debugPrint('Respuesta de inserción: $response');

      if (mounted) {
        Navigator.pop(context);
        _loadProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto publicado exitosamente')),
        );
      }
    } catch (e) {
      debugPrint('Error al publicar el producto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al publicar el producto')),
        );
      }
    } finally {
      setState(() => _isUploadingImages = false);
    }
  }

  List<Product> _getFilteredProducts() {
    if (_selectedCategory == ProductCategories.todos) {
      return _products;
    }
    return _products
        .where((product) => product.tipoCategoria == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marketplace Sostenible',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Compra y vende productos ecológicos',
                style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showPublishProductDialog(context),
              icon: const Icon(Icons.add, color: Color(0xFF4CAF50)),
              label: const Text('Publicar',
                  style: TextStyle(color: Color(0xFF4CAF50))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildCategoryChip(ProductCategories.todos, 'Todos'),
                ...ProductCategories.values
                    .map((category) => _buildCategoryChip(category, category)),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProducts,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _getFilteredProducts().isEmpty
                      ? const Center(
                          child: Text('No hay productos disponibles'))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                          padding: const EdgeInsets.all(16),
                          itemCount: _getFilteredProducts().length,
                          itemBuilder: (context, index) {
                            final product = _getFilteredProducts()[index];
                            return _buildProductCard(product);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: _selectedCategory == value,
        onSelected: (bool selected) {
          setState(() => _selectedCategory = value);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.green[100],
        labelStyle: TextStyle(
          color: _selectedCategory == value
              ? const Color(0xFF4CAF50)
              : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double
                  .infinity, // Asegura que el contenedor ocupe todo el ancho disponible
              height: 300.0, // Aumenta la altura para que se vea más alta
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: product.imgs != null && product.imgs!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.imgs!.first),
                        fit: BoxFit
                            .cover, // Mantiene la proporción de la imagen y la adapta al contenedor
                      )
                    : null,
              ),
              child: product.imgs == null || product.imgs!.isEmpty
                  ? const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.precio?.toStringAsFixed(2) ?? "0.00"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.estado ?? 'N/A',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (product.ubicacion != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.ubicacion!,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Implementar vista detallada del producto
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Ver detalles'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPublishProductDialog(BuildContext context) {
    // Resetear valores
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _locationController.clear();
    _selectedImages = []; // Limpiamos la lista de imágenes seleccionadas
    _selectedState = ProductCategories.estados.first;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        // Usamos StatefulBuilder para manejar el estado dentro del diálogo
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Publicar Artículo'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Selector de imágenes mejorado - CORREGIDO
                    InkWell(
                      onTap: () async {
                        // CAMBIO PRINCIPAL: Pasamos setDialogState como parámetro
                        await _pickImages(setDialogState);
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _selectedImages.isEmpty
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
                                    children: _selectedImages
                                        .map((image) => Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: Image.file(
                                                    image,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setDialogState(() {
                                                        _selectedImages
                                                            .remove(image);
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: const Icon(
                                                        Icons.close,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        // CAMBIO: Pasamos setDialogState aquí también
                                        await _pickImages(setDialogState);
                                      },
                                      icon: const Icon(
                                          Icons.add_photo_alternate,
                                          size: 16),
                                      label: const Text('Más fotos'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF4CAF50),
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

                    // Campos del formulario original
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Título del Artículo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory == ProductCategories.todos
                          ? ProductCategories.values.first
                          : _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ProductCategories.values
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() => _selectedCategory = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ProductCategories.estados
                          .map((estado) => DropdownMenuItem(
                                value: estado,
                                child: Text(estado),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() => _selectedState = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Precio (\$)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un precio';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor ingresa un precio válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Ubicación',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _isUploadingImages ? null : _createProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: _isUploadingImages
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Publicar Artículo'),
              ),
            ],
          );
        },
      ),
    );
  }
}
