from django.contrib import admin
from .models import Producto, Categoria

@admin.register(Categoria)
class CategoriaAdmin(admin.ModelAdmin):
    list_display = ['nombre', 'activa', 'productos_count', 'created_at']
    list_filter = ['activa', 'created_at']
    search_fields = ['nombre', 'descripcion']
    ordering = ['nombre']
    
    def productos_count(self, obj):
        return obj.productos.count()
    productos_count.short_description = 'Productos'

@admin.register(Producto)
class ProductoAdmin(admin.ModelAdmin):
    list_display = [
        'nombre', 'codigo_sku', 'categoria', 'precio_formateado', 
        'stock', 'estado', 'activo', 'created_at'
    ]
    list_filter = ['categoria', 'estado', 'activo', 'created_at']
    search_fields = ['nombre', 'codigo_sku', 'descripcion']
    list_editable = ['stock', 'estado', 'activo']
    ordering = ['-created_at']
    
    fieldsets = (
        ('Información Básica', {
            'fields': ('nombre', 'descripcion', 'codigo_sku', 'categoria')
        }),
        ('Detalles del Producto', {
            'fields': ('precio', 'stock', 'estado', 'peso', 'calificacion')
        }),
        ('Multimedia', {
            'fields': ('imagen',),
            'classes': ('collapse',)
        }),
        ('Estado', {
            'fields': ('activo',)
        })
    )
    
    actions = ['marcar_disponible', 'marcar_agotado', 'activar_productos', 'desactivar_productos']
    
    def marcar_disponible(self, request, queryset):
        updated = queryset.update(estado='disponible')
        self.message_user(request, f'{updated} productos marcados como disponibles.')
    marcar_disponible.short_description = "Marcar como disponibles"
    
    def marcar_agotado(self, request, queryset):
        updated = queryset.update(estado='agotado', stock=0)
        self.message_user(request, f'{updated} productos marcados como agotados.')
    marcar_agotado.short_description = "Marcar como agotados"
    
    def activar_productos(self, request, queryset):
        updated = queryset.update(activo=True)
        self.message_user(request, f'{updated} productos activados.')
    activar_productos.short_description = "Activar productos"
    
    def desactivar_productos(self, request, queryset):
        updated = queryset.update(activo=False)
        self.message_user(request, f'{updated} productos desactivados.')
    desactivar_productos.short_description = "Desactivar productos"