from rest_framework import serializers
from .models import Producto, Categoria

class CategoriaSerializer(serializers.ModelSerializer):
    productos_count = serializers.SerializerMethodField() #Campo personalizado 

    class Meta:
        model = Categoria
        fields = [
            'id', 'nombre', 'descripcion', 'activa', 
            'created_at', 'updated_at', 'productos_count'
        ]

    def get_productos_count(self, obj):
        return obj.productos.filter(activo=True).count()

class ProductoSerializer(serializers.ModelSerializer):
    categoria_nombre = serializers.CharField(source='categoria.nombre', read_only=True)
    precio_formateado = serializers.CharField(read_only=True)
    esta_disponible = serializers.BooleanField(read_only=True)

    class Meta:
        model = Producto
        fields = [
            'id', 'nombre', 'descripcion', 'precio', 'precio_formateado',
            'categoria', 'categoria_nombre', 'stock', 'codigo_sku', 
            'estado', 'imagen', 'peso', 'calificacion', 'activo',
            'esta_disponible', 'created_at', 'updated_at'
        ]

    def validate_codigo_sku(self, value):
        """
        Validar que el SKU sea único al crear/actualizar
        """
        if self.instance:
            # Actualización: excluir el producto actual de la validación
            if Producto.objects.exclude(pk=self.instance.pk).filter(codigo_sku=value).exists():
                raise serializers.ValidationError("Ya existe un producto con este código SKU.")
        else:
            # Creación: verificar que no exista
            if Producto.objects.filter(codigo_sku=value).exists():
                raise serializers.ValidationError("Ya existe un producto con este código SKU.")
        return value

    def validate_precio(self, value):
        """
        Validar que el precio sea positivo
        """
        if value <= 0:
            raise serializers.ValidationError("El precio debe ser mayor a 0.")
        return value

    def validate_stock(self, value):
        """
        Validar que el stock no sea negativo
        """
        if value < 0:
            raise serializers.ValidationError("El stock no puede ser negativo.")
        return value

class ProductoCreateUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer específico para crear y actualizar productos
    con validaciones adicionales
    """
    
    class Meta:
        model = Producto
        fields = [
            'nombre', 'descripcion', 'precio', 'categoria', 
            'stock', 'codigo_sku', 'estado', 'imagen', 
            'peso', 'calificacion', 'activo'
        ]

    def validate(self, data):
        """
        Validaciones de objeto
        """
        # Si el estado es 'agotado', el stock debe ser 0
        if data.get('estado') == 'agotado' and data.get('stock', 0) > 0:
            raise serializers.ValidationError({
                'estado': 'Si el producto está agotado, el stock debe ser 0.'
            })
        
        # Si hay stock, el estado no puede ser 'agotado'
        if data.get('stock', 0) > 0 and data.get('estado') == 'agotado':
            raise serializers.ValidationError({
                'stock': 'No puede haber stock si el producto está marcado como agotado.'
            })

        return data