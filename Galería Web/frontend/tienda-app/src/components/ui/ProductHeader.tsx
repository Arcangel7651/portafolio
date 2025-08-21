import React from 'react';
import {
  IonHeader,
  IonTitle,
  IonToolbar,
  IonButtons,
  IonButton,
  IonIcon,
  IonBadge,
  IonChip,
  IonLabel
} from '@ionic/react';
import { search, options, chevronDown, funnel, filter, close } from 'ionicons/icons';

interface ProductHeaderProps {
  headerVisible: boolean;
  searchText: string;
  categoriaSeleccionada: number | null;
  filtrosActivos: number;
  filtrosAvanzados: {
    soloDisponibles: boolean;
    rangoPrecio: { min: number | null; max: number | null };
  };
  loading: boolean;
  productosFiltrados: unknown[];
  getNombreCategoriaSeleccionada: string;
  onSearchClick: () => void;
  onCategoriaClick: () => void;
  onFiltrosClick: () => void;
  onLimpiarFiltros: () => void;
}

const ProductHeader: React.FC<ProductHeaderProps> = ({
  headerVisible,
  searchText,
  categoriaSeleccionada,
  filtrosActivos,
  filtrosAvanzados,
  loading,
  productosFiltrados,
  getNombreCategoriaSeleccionada,
  onSearchClick,
  onCategoriaClick,
  onFiltrosClick,
  onLimpiarFiltros
}) => {
  return (
    <IonHeader className={`premium-header ${headerVisible ? 'header-visible' : 'header-hidden'}`}>
      <IonToolbar className="premium-toolbar">
        <IonTitle className="premium-title">
          Productos Destacados
        </IonTitle>
        
        <IonButtons slot="end" className="filter-buttons">
          {/* Botón de búsqueda */}
          <IonButton 
            id="search-trigger" 
            fill="clear" 
            className="filter-button"
            onClick={onSearchClick}
          >
            <IonIcon icon={search} />
            {searchText && <IonBadge color="primary" className="filter-badge">1</IonBadge>}
          </IonButton>

          {/* Botón de categorías */}
          <IonButton 
            id="categoria-trigger" 
            fill="clear" 
            className="filter-button"
            onClick={onCategoriaClick}
          >
            <IonIcon icon={options} />
            <IonIcon icon={chevronDown} size="small" />
            {categoriaSeleccionada !== null && <IonBadge color="secondary" className="filter-badge">1</IonBadge>}
          </IonButton>

          {/* Botón de filtros avanzados */}
          <IonButton 
            fill="clear" 
            className="filter-button"
            onClick={onFiltrosClick}
          >
            <IonIcon icon={funnel} />
            {(filtrosAvanzados.soloDisponibles || filtrosAvanzados.rangoPrecio.min !== null || filtrosAvanzados.rangoPrecio.max !== null) && 
              <IonBadge color="tertiary" className="filter-badge">
                {(filtrosAvanzados.soloDisponibles ? 1 : 0) + (filtrosAvanzados.rangoPrecio.min !== null || filtrosAvanzados.rangoPrecio.max !== null ? 1 : 0)}
              </IonBadge>
            }
          </IonButton>

          {/* Indicador de filtros activos */}
          {filtrosActivos > 0 && (
            <IonChip color="primary" className="active-filters-chip">
              <IonIcon icon={filter} />
              <IonLabel>{filtrosActivos}</IonLabel>
              <IonIcon 
                icon={close} 
                onClick={onLimpiarFiltros}
                style={{ cursor: 'pointer' }}
              />
            </IonChip>
          )}
        </IonButtons>
      </IonToolbar>

      {/* Barra de información compacta */}
      {!loading && (
        <div className="info-bar">
          <div className="info-content">
            <span className="result-count">
              {productosFiltrados.length} producto{productosFiltrados.length !== 1 ? 's' : ''}
            </span>
            {categoriaSeleccionada !== null && (
              <span className="category-info">
                en {getNombreCategoriaSeleccionada}
              </span>
            )}
            {searchText && (
              <span className="search-info">
                para "{searchText}"
              </span>
            )}
          </div>
        </div>
      )}
    </IonHeader>
  );
};

export default ProductHeader;