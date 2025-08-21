from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ProductoViewSet, CategoriaViewSet

# Crear el router para las APIs
router = DefaultRouter()
router.register(r'productos', ProductoViewSet, basename='producto')
router.register(r'categorias', CategoriaViewSet, basename='categoria')

urlpatterns = [
    path('api/v1/', include(router.urls)),
]

# URLs generadas automáticamente por el router:
# GET    /api/v1/productos/                 - Lista y crear productos
# GET/PUT/PATCH/DELETE /api/v1/productos/{id}/    - Operaciones individuales
# GET          /api/v1/productos/estadisticas/    - Estadísticas
# PATCH        /api/v1/productos/{id}/cambiar_estado/
# PATCH        /api/v1/productos/{id}/actualizar_stock/
# 
# GET    /api/v1/categorias/                - Lista y crear categorías  
# GET/PUT/PATCH/DELETE /api/v1/categorias/{id}/   - Operaciones individuales
# GET          /api/v1/categorias/{id}/productos/ - Productos de una categoría