import { useState, useMemo, useCallback } from 'react';
import { Producto } from '../models/Producto';

interface FiltrosAvanzados {
  soloDisponibles: boolean;
  rangoPrecio: {
    min: number | null;
    max: number | null;
  };
}

export const useFilters = (productos: Producto[]) => {
  const [categoriaSeleccionada, setCategoriaSeleccionada] = useState<number | null>(null);
  const [searchText, setSearchText] = useState('');
  const [filtrosAvanzados, setFiltrosAvanzados] = useState<FiltrosAvanzados>({
    soloDisponibles: false,
    rangoPrecio: { min: null, max: null }
  });

  const productosFiltrados = useMemo(() => {
    let filtered = [...productos];

    // Filtro por texto de búsqueda
    if (searchText.trim()) {
      const searchLower = searchText.toLowerCase();
      filtered = filtered.filter(producto =>
        producto.nombre.toLowerCase().includes(searchLower) ||
        producto.descripcion?.toLowerCase().includes(searchLower) ||
        producto.categoria_nombre?.toLowerCase().includes(searchLower)
      );
    }

    // Filtro por disponibilidad
    if (filtrosAvanzados.soloDisponibles) {
      filtered = filtered.filter(producto => producto.esta_disponible);
    }

    return filtered;
  }, [productos, searchText, filtrosAvanzados]);

  const filtrosActivos = useMemo(() => {
    let count = 0;
    if (categoriaSeleccionada !== null) count++;
    if (searchText.trim()) count++;
    if (filtrosAvanzados.soloDisponibles) count++;
    if (filtrosAvanzados.rangoPrecio.min !== null || filtrosAvanzados.rangoPrecio.max !== null) count++;
    return count;
  }, [categoriaSeleccionada, searchText, filtrosAvanzados]);

  const limpiarFiltros = useCallback(() => {
    setCategoriaSeleccionada(null);
    setSearchText('');
    setFiltrosAvanzados({
      soloDisponibles: false,
      rangoPrecio: { min: null, max: null }
    });
  }, []);

  return {
    categoriaSeleccionada,
    setCategoriaSeleccionada,
    searchText,
    setSearchText,
    filtrosAvanzados,
    setFiltrosAvanzados,
    productosFiltrados,
    filtrosActivos,
    limpiarFiltros
  };
};
