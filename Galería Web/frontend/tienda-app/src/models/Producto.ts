export interface Producto {
  id: number;
  nombre: string;
  descripcion: string;
  precio: string; 
  precio_formateado: string;
  categoria: number;
  categoria_nombre: string;
  stock: number;
  codigo_sku: string;
  estado: "disponible" | "agotado" | "descontinuado";
  imagen: string | null;
  peso: string | null;
  calificacion: string; 
  activo: boolean;
  esta_disponible: boolean;
  created_at: string; //  date
  updated_at: string; //  date
}
