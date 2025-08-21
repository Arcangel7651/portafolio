import {
  IonContent,
  IonPage,
  IonRefresher,
  IonRefresherContent,
  IonToast,
  IonFab,
  IonFabButton,
  IonIcon,
} from '@ionic/react';
import { useEffect, useState, useCallback, useRef, useMemo } from 'react';
import { refresh } from 'ionicons/icons';
import { getCategories } from '../services/categoriesService';
import { Categoria } from '../models/Categoria';
import { Producto } from '../models/Producto';

// Importar componentes separados
import ProductHeader from '../components/ui/ProductHeader';
import SearchPopover from '../components/ui/SearchPopover';
import CategoryPopover from '../components/ui/CategoryPopover';
import FiltersModal from '../components/ui/FiltersModal';
import ProductsGrid from '../components/ui/ProductsGrid';

// Importar hooks personalizados
import { useProducts } from '../hooks/useProducts';
import { useFilters } from '../hooks/useFilters';
import { useFavorites } from '../hooks/useFavorites';

import './Home.css';

const Home: React.FC = () => {
  // Estados de UI
  const [categorias, setCategorias] = useState<Categoria[]>([]);
  const [headerVisible, setHeaderVisible] = useState(true);
  const [showToast, setShowToast] = useState(false);
  const [toastMessage, setToastMessage] = useState('');
  const [toastColor, setToastColor] = useState<'success' | 'warning' | 'danger'>('success');
  const [showFiltrosModal, setShowFiltrosModal] = useState(false);
  const [showSearchPopover, setShowSearchPopover] = useState(false);
  const [showCategoriaPopover, setShowCategoriaPopover] = useState(false);
  
  // Referencias
  const contentRef = useRef<HTMLIonContentElement>(null);
  const lastScrollTop = useRef(0);
  const scrollThreshold = 10;
  const itemsPerPage = 12;

  // Función para mostrar toast
  const showToastMessage = useCallback((message: string, color: 'success' | 'warning' | 'danger' = 'success') => {
    setToastMessage(message);
    setToastColor(color);
    setShowToast(true);
  }, []);

  // Hooks personalizados
  const {
    categoriaSeleccionada,
    setCategoriaSeleccionada,
    searchText,
    setSearchText,
    filtrosAvanzados,
    setFiltrosAvanzados,
    filtrosActivos,
    limpiarFiltros
  } = useFilters([]);

  const {
    productos,
    loading,
    error,
    hasMoreData,
    loadMoreProducts,
    refreshProducts,
    retryLoad
  } = useProducts({
    categoriaSeleccionada,
    itemsPerPage,
    onError: (message) => showToastMessage(message, 'danger')
  });

  const { favoritos, toggleFavorito } = useFavorites(showToastMessage);

  // Aplicar filtros cuando cambien los productos
  const filteredProducts = useMemo(() => {
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

  // Cargar categorías
  useEffect(() => {
    const cargarCategorias = async () => {
      try {
        const data = await getCategories();
        setCategorias(data);
      } catch (error) {
        console.error("Error al cargar categorías", error);
        showToastMessage('Error al cargar categorías', 'warning');
      }
    };
    cargarCategorias();
  }, [showToastMessage]);

  // Manejar scroll del header
  const handleScroll = useCallback((event: CustomEvent) => {
    const detail = event.detail;
    const scrollTop = detail.scrollTop;

    if (scrollTop <= 50) {
      if (!headerVisible) setHeaderVisible(true);
      lastScrollTop.current = scrollTop;
      return;
    }

    const scrollDirection = scrollTop > lastScrollTop.current ? 'down' : 'up';
    const scrollDifference = Math.abs(scrollTop - lastScrollTop.current);

    if (scrollDifference > scrollThreshold) {
      if (scrollDirection === 'down' && headerVisible) {
        setHeaderVisible(false);
      } else if (scrollDirection === 'up' && !headerVisible) {
        setHeaderVisible(true);
      }
      lastScrollTop.current = scrollTop;
    }
  }, [headerVisible, scrollThreshold]);

  // Manejar refresh
  const handleRefresh = useCallback(async (event: CustomEvent) => {
    await refreshProducts(event);
    showToastMessage('Productos actualizados');
  }, [refreshProducts, showToastMessage]);

  // Cambiar categoría
  const handleCategoriaChange = useCallback((categoria: number | null) => {
    setCategoriaSeleccionada(categoria);
    setShowCategoriaPopover(false);
  }, [setCategoriaSeleccionada]);

  // Limpiar filtros
  const handleLimpiarFiltros = useCallback(() => {
    limpiarFiltros();
    showToastMessage('Filtros limpiados');
  }, [limpiarFiltros, showToastMessage]);

  // Formatear precio
  const formatPrice = useCallback((producto: Producto) => {
    return producto.precio_formateado || `$${producto.precio?.toLocaleString()}`;
  }, []);

  // Obtener nombre de categoría seleccionada
  const getNombreCategoriaSeleccionada = useMemo(() => {
    if (categoriaSeleccionada === null) return 'Todas';
    const categoria = categorias.find(cat => cat.id === categoriaSeleccionada);
    return categoria?.nombre || 'Todas';
  }, [categoriaSeleccionada, categorias]);

  // Handlers para los popovers y modales
  const handleSearchClick = () => setShowSearchPopover(true);
  const handleCategoriaClick = () => setShowCategoriaPopover(true);
  const handleFiltrosClick = () => setShowFiltrosModal(true);

  const handleFiltrosReset = () => {
    setFiltrosAvanzados({
      soloDisponibles: false,
      rangoPrecio: { min: null, max: null }
    });
  };

  return (
    <IonPage>
      <ProductHeader
        headerVisible={headerVisible}
        searchText={searchText}
        categoriaSeleccionada={categoriaSeleccionada}
        filtrosActivos={filtrosActivos}
        filtrosAvanzados={filtrosAvanzados}
        loading={loading}
        productosFiltrados={filteredProducts}
        getNombreCategoriaSeleccionada={getNombreCategoriaSeleccionada}
        onSearchClick={handleSearchClick}
        onCategoriaClick={handleCategoriaClick}
        onFiltrosClick={handleFiltrosClick}
        onLimpiarFiltros={handleLimpiarFiltros}
      />

      <SearchPopover
        isOpen={showSearchPopover}
        searchText={searchText}
        onDidDismiss={() => setShowSearchPopover(false)}
        onSearchTextChange={setSearchText}
        onClear={() => setSearchText('')}
      />

      <CategoryPopover
        isOpen={showCategoriaPopover}
        categorias={categorias}
        categoriaSeleccionada={categoriaSeleccionada}
        onDidDismiss={() => setShowCategoriaPopover(false)}
        onCategoriaChange={handleCategoriaChange}
      />

      <FiltersModal
        isOpen={showFiltrosModal}
        filtrosAvanzados={filtrosAvanzados}
        onDidDismiss={() => setShowFiltrosModal(false)}
        onFiltrosChange={setFiltrosAvanzados}
        onReset={handleFiltrosReset}
      />

      <IonContent
        ref={contentRef}
        fullscreen
        scrollEvents={true}
        onIonScroll={handleScroll}
        className="premium-content"
      >
        <IonRefresher slot="fixed" onIonRefresh={handleRefresh}>
          <IonRefresherContent
            pullingIcon={refresh}
            pullingText="Desliza para actualizar"
            refreshingSpinner="circular"
            refreshingText="Actualizando..."
          />
        </IonRefresher>

        <div className="content-container">
          <ProductsGrid
            loading={loading}
            error={error}
            productos={filteredProducts}
            favoritos={favoritos}
            searchText={searchText}
            filtrosActivos={filtrosActivos}
            hasMoreData={hasMoreData}
            onToggleFavorite={toggleFavorito}
            onLoadMore={loadMoreProducts}
            onLimpiarFiltros={handleLimpiarFiltros}
            onRetry={retryLoad}
            formatPrice={formatPrice}
          />
        </div>

        {/* FAB para ir arriba */}
        <IonFab vertical="bottom" horizontal="end" slot="fixed">
          <IonFabButton
            onClick={() => contentRef.current?.scrollToTop(500)}
            size="small"
            className="scroll-to-top-fab"
          >
            <IonIcon icon={refresh} />
          </IonFabButton>
        </IonFab>
      </IonContent>

      {/* Toast para notificaciones */}
      <IonToast
        isOpen={showToast}
        message={toastMessage}
        duration={2000}
        color={toastColor}
        onDidDismiss={() => setShowToast(false)}
        position="bottom"
      />
    </IonPage>
  );
};

export default Home;