from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q
from .models import Producto, Categoria
from .serializers import (
    ProductoSerializer, 
    ProductoCreateUpdateSerializer,
    CategoriaSerializer
)

class CategoriaViewSet(viewsets.ModelViewSet):
    """
    ViewSet para manejar las categorías
    """
    queryset = Categoria.objects.all()
    serializer_class = CategoriaSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['nombre', 'descripcion']
    ordering_fields = ['nombre', 'created_at']
    ordering = ['nombre']

    @action(detail=True, methods=['get'])
    def productos(self, request, pk=None):
        """
        Obtener todos los productos de una categoría específica
        """
        categoria = self.get_object()
        productos = categoria.productos.filter(activo=True)
        serializer = ProductoSerializer(productos, many=True)
        return Response(serializer.data)

class ProductoViewSet(viewsets.ModelViewSet):
    """
    ViewSet para manejar los productos con operaciones CRUD 
    """
    queryset = Producto.objects.select_related('categoria').all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['categoria', 'estado', 'activo']
    search_fields = ['nombre', 'descripcion', 'codigo_sku']
    ordering_fields = ['nombre', 'precio', 'stock', 'created_at', 'calificacion']
    ordering = ['-created_at']

    def get_serializer_class(self):
        """
        Usar diferentes serializers según la acción
        """
        if self.action in ['create', 'update', 'partial_update']:
            return ProductoCreateUpdateSerializer
        return ProductoSerializer

    def get_queryset(self):
        """
        Personalizar el queryset según los parámetros de consulta
        """
        queryset = Producto.objects.select_related('categoria').all()
        
        # Filtros adicionales
        categoria_id = self.request.query_params.get('categoria_id', None)
        precio_min = self.request.query_params.get('precio_min', None)
        precio_max = self.request.query_params.get('precio_max', None)
        disponibles = self.request.query_params.get('disponibles', None)

        if categoria_id:
            queryset = queryset.filter(categoria_id=categoria_id)
        
        if precio_min:
            try:
                queryset = queryset.filter(precio__gte=float(precio_min))
            except ValueError:
                pass
        
        if precio_max:
            try:
                queryset = queryset.filter(precio__lte=float(precio_max))
            except ValueError:
                pass
        
        if disponibles and disponibles.lower() == 'true':
            queryset = queryset.filter(
                estado='disponible',
                stock__gt=0,
                activo=True
            )

        return queryset

    def create(self, request, *args, **kwargs):
        """
        Crear un nuevo producto
        """
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            producto = serializer.save()
            response_serializer = ProductoSerializer(producto)
            return Response(
                response_serializer.data, 
                status=status.HTTP_201_CREATED
            )
        return Response(
            serializer.errors, 
            status=status.HTTP_400_BAD_REQUEST
        )

    def update(self, request, *args, **kwargs):
        """
        Actualizar un producto existente
        """
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        
        if serializer.is_valid():
            producto = serializer.save()
            response_serializer = ProductoSerializer(producto)
            return Response(response_serializer.data)
        
        return Response(
            serializer.errors, 
            status=status.HTTP_400_BAD_REQUEST
        )

    @action(detail=False, methods=['get'])
    def estadisticas(self, request):
        """
        Obtener estadísticas generales de productos
        """
        total_productos = Producto.objects.count()
        productos_activos = Producto.objects.filter(activo=True).count()
        productos_disponibles = Producto.objects.filter(
            estado='disponible', 
            stock__gt=0, 
            activo=True
        ).count()
        productos_agotados = Producto.objects.filter(
            Q(estado='agotado') | Q(stock=0)
        ).count()
        
        # Valor total del inventario
        productos_con_stock = Producto.objects.filter(stock__gt=0, activo=True)
        valor_inventario = sum(
            producto.precio * producto.stock 
            for producto in productos_con_stock
        )

        return Response({
            'total_productos': total_productos,
            'productos_activos': productos_activos,
            'productos_disponibles': productos_disponibles,
            'productos_agotados': productos_agotados,
            'valor_inventario': float(valor_inventario),
            'categorias_count': Categoria.objects.filter(activa=True).count()
        })

    @action(detail=True, methods=['patch'])
    def cambiar_estado(self, request, pk=None):
        """
        Cambiar solo el estado de un producto
        """
        producto = self.get_object()
        nuevo_estado = request.data.get('estado')
        
        if nuevo_estado not in ['disponible', 'agotado', 'descontinuado']:
            return Response(
                {'error': 'Estado no válido'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        producto.estado = nuevo_estado
        
        # Si se marca como agotado, poner stock en 0
        if nuevo_estado == 'agotado':
            producto.stock = 0
        
        producto.save()
        
        serializer = ProductoSerializer(producto)
        return Response(serializer.data)

    @action(detail=True, methods=['patch'])
    def actualizar_stock(self, request, pk=None):
        """
        Actualizar solo el stock de un producto
        """
        producto = self.get_object()
        nuevo_stock = request.data.get('stock')
        
        if nuevo_stock is None or not isinstance(nuevo_stock, int) or nuevo_stock < 0:
            return Response(
                {'error': 'Stock debe ser un número entero no negativo'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        producto.stock = nuevo_stock
        
        # Actualizar estado automáticamente
        if nuevo_stock == 0:
            producto.estado = 'agotado'
        elif producto.estado == 'agotado' and nuevo_stock > 0:
            producto.estado = 'disponible'
        
        producto.save()
        
        serializer = ProductoSerializer(producto)
        return Response(serializer.data)