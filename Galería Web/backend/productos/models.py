from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator

class Categoria(models.Model):
    nombre = models.CharField(max_length=100, unique=True)
    descripcion = models.TextField(blank=True, null=True)
    activa = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Categoría"
        verbose_name_plural = "Categorías"
        ordering = ['nombre']

    def __str__(self):
        return self.nombre

class Producto(models.Model):
    ESTADO_CHOICES = [
        ('disponible', 'Disponible'),
        ('agotado', 'Agotado'),
        ('descontinuado', 'Descontinuado'),
    ]

    nombre = models.CharField(max_length=200)
    descripcion = models.TextField()
    precio = models.DecimalField(
        max_digits=10, 
        decimal_places=2,
        validators=[MinValueValidator(0.01)]
    )
    categoria = models.ForeignKey(
        Categoria, 
        on_delete=models.CASCADE,
        related_name='productos'
    )
    stock = models.PositiveIntegerField(default=0)
    codigo_sku = models.CharField(max_length=50, unique=True)
    estado = models.CharField(
        max_length=20,
        choices=ESTADO_CHOICES,
        default='disponible'
    )
    imagen = models.URLField(blank=True, null=True)
    peso = models.DecimalField(
        max_digits=8,
        decimal_places=3,
        blank=True,
        null=True,
        help_text="Peso en kilogramos"
    )
    calificacion = models.DecimalField(
        max_digits=3,
        decimal_places=2,
        default=0.00,
        validators=[
            MinValueValidator(0.00),
            MaxValueValidator(5.00)
        ]
    )
    activo = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Producto"
        verbose_name_plural = "Productos"
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['codigo_sku']),
            models.Index(fields=['categoria', 'estado']),
            models.Index(fields=['created_at']),
        ]

    def __str__(self):
        return f"{self.nombre} - {self.codigo_sku}"

    def esta_disponible(self):
        return self.estado == 'disponible' and self.stock > 0 and self.activo

    def precio_formateado(self):
        return f"${self.precio:,.2f}"