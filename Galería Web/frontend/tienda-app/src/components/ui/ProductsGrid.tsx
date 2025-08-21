import React from 'react';
import { IonInfiniteScroll, IonInfiniteScrollContent } from '@ionic/react';
import ProductCard from './ProductCard';
import { SkeletonCards, ErrorState, EmptyState } from './LoadingStates';
import { Producto } from '../../models/Producto';
import './ProductsGrid.css';

interface ProductsGridProps {
  loading: boolean;
  error: string | null;
  productos: Producto[];
  favoritos: Set<number>;
  searchText: string;
  filtrosActivos: number;
  hasMoreData: boolean;
  onToggleFavorite: (productId: number) => void;
  onLoadMore: (event: CustomEvent) => void;
  onLimpiarFiltros: () => void;
  onRetry: () => void;
  formatPrice: (producto: Producto) => string;
}

const ProductsGrid: React.FC<ProductsGridProps> = ({
  loading,
  error,
  productos,
  favoritos,
  searchText,
  filtrosActivos,
  hasMoreData,
  onToggleFavorite,
  onLoadMore,
  onLimpiarFiltros,
  onRetry,
  formatPrice
}) => {
  if (loading) {
    return <SkeletonCards />;
  }

  if (error) {
    return <ErrorState error={error} onRetry={onRetry} />;
  }

  if (productos.length === 0) {
    return (
      <EmptyState
        searchText={searchText}
        filtrosActivos={filtrosActivos}
        onLimpiarFiltros={onLimpiarFiltros}
        onRetry={onRetry}
      />
    );
  }

  return (
    <>
      <div className="cards-container">
        {productos.map((producto) => (
          <ProductCard
            key={producto.id}
            producto={producto}
            isFavorite={favoritos.has(producto.id)}
            onToggleFavorite={onToggleFavorite}
            formatPrice={formatPrice}
          />
        ))}
      </div>

      {/* Infinite Scroll */}
      {hasMoreData && (
        <IonInfiniteScroll onIonInfinite={onLoadMore}>
          <IonInfiniteScrollContent
            loadingSpinner="bubbles"
            loadingText="Cargando más productos..."
          />
        </IonInfiniteScroll>
      )}
    </>
  );
};

export default ProductsGrid;