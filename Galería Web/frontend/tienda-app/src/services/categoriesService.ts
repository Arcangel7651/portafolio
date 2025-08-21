import axios from "axios";
import { Producto } from "../models/Producto";
import { Categoria } from "../models/Categoria";

const API_URL = "http://127.0.0.1:8000/api/v1";

// Obtener todas las categorías
export const getCategories = async (): Promise<Categoria[]> => {
  const res = await axios.get(`${API_URL}/categorias/`);
  return res.data.results; // Usa res.data.results si tienes paginación en Django REST
};

// Obtener productos de una categoría específica
export const getProductosPorCategoria = async (categoriaId: number): Promise<Producto[]> => {
  const response = await axios.get(`${API_URL}/categorias/${categoriaId}/productos/`);
  return response.data;
};
