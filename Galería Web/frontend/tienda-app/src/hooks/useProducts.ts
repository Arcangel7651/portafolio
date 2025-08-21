import { useState, useCallback, useEffect } from 'react';
import { getProductos } from '../services/productosService';
import { getProductosPorCategoria } from '../services/categoriesService';
import { Producto } from '../models/Producto';

interface UseProductsOptions {
  categoriaSeleccionada: number | null;
  itemsPerPage: number;
  onError: (message: string) => void;
}

export const useProducts = ({ categoriaSeleccionada, itemsPerPage, onError }: UseProductsOptions) => {
  const [productos, setProductos] = useState<Producto[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [hasMoreData, setHasMoreData] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);


  const loadProductos = useCallback(async (showLoading = true, page = 1, append = false) => {
    try {
      if (showLoading && !append) setLoading(true);
      setError(null);

      let data: Producto[] = [];

      if (categoriaSeleccionada !== null) {
        data = await getProductosPorCategoria(categoriaSeleccionada);
      } else {
        data = await getProductos();
      }

      if (Array.isArray(data)) {
        const startIndex = (page - 1) * itemsPerPage;
        const endIndex = startIndex + itemsPerPage;
        const paginatedData = data.slice(startIndex, endIndex);

        if (append) {
          setProductos(prev => [...prev, ...paginatedData]);
        } else {
          setProductos(paginatedData);
        }

        setHasMoreData(endIndex < data.length);
      } else {
        setError('Formato de datos inesperado');
        onError('Error en el formato de datos');
      }
    } catch (err) {
      setError('Error al obtener productos. Verifica tu conexión a internet.');
      onError('Error al cargar productos');
      console.error('Error loading productos:', err);
    } finally {
      setLoading(false);
    }
  }, [categoriaSeleccionada, itemsPerPage]); 

  const loadMoreProducts = useCallback(async (event: CustomEvent) => {
    const nextPage = currentPage + 1;
    await loadProductos(false, nextPage, true);
    setCurrentPage(nextPage);
    (event.target as HTMLIonInfiniteScrollElement).complete();
  }, [currentPage, loadProductos]);

  const refreshProducts = useCallback(async (event?: CustomEvent) => {
    setCurrentPage(1);
    await loadProductos(false, 1, false);
    if (event) {
      event.detail.complete();
    }
  }, [loadProductos]);

  const retryLoad = useCallback(() => {
    setCurrentPage(1);
    loadProductos();
  }, [loadProductos]);

  useEffect(() => {
    setCurrentPage(1);
    loadProductos();
  }, [categoriaSeleccionada]); // solo depende de la categoría

  return {
    productos,
    loading,
    error,
    hasMoreData,
    loadMoreProducts,
    refreshProducts,
    retryLoad
  };
};
