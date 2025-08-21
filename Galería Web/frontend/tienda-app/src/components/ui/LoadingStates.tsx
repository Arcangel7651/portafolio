import React from 'react';
import { IonSkeletonText, IonText, IonIcon, IonButton } from '@ionic/react';
import { alertCircle, refresh, close } from 'ionicons/icons';
import './LoadingStates.css';

// Componente de Skeleton Loading
export const SkeletonCards: React.FC = () => (
  <div className="cards-container">
    {[...Array(6)].map((_, index) => (
      <div className="card" key={`skeleton-${index}`} style={{ opacity: 0.6 }}>
        <div className="card-img">
          <IonSkeletonText animated style={{ width: '100%', height: '100%', borderRadius: '16px' }} />
        </div>
        <div className="card-info">
          <IonSkeletonText animated style={{ width: '85%', height: '24px', marginBottom: '12px', borderRadius: '8px' }} />
          <IonSkeletonText animated style={{ width: '100%', height: '18px', marginBottom: '6px', borderRadius: '6px' }} />
          <IonSkeletonText animated style={{ width: '90%', height: '18px', marginBottom: '6px', borderRadius: '6px' }} />
          <IonSkeletonText animated style={{ width: '65%', height: '18px', marginBottom: '12px', borderRadius: '6px' }} />
          <IonSkeletonText animated style={{ width: '45%', height: '32px', borderRadius: '20px' }} />
        </div>
        <div className="card-footer">
          <IonSkeletonText animated style={{ width: '90px', height: '32px', borderRadius: '25px' }} />
          <IonSkeletonText animated style={{ width: '80px', height: '40px', borderRadius: '30px' }} />
        </div>
      </div>
    ))}
  </div>
);

// Componente de Error State
interface ErrorStateProps {
  error: string;
  onRetry: () => void;
}

export const ErrorState: React.FC<ErrorStateProps> = ({ error, onRetry }) => (
  <div className="loading-state">
    <IonIcon icon={alertCircle} size="large" color="danger" style={{ marginBottom: '16px' }} />
    <IonText color="medium">
      <h3 style={{ margin: '0 0 12px 0', fontWeight: 700 }}>¡Ups! Algo salió mal</h3>
      <p style={{ margin: '0 0 24px 0', maxWidth: '300px' }}>{error}</p>
    </IonText>
    <IonButton fill="outline" onClick={onRetry} style={{ textTransform: 'none' }}>
      <IonIcon icon={refresh} slot="start" />
      Intentar de nuevo
    </IonButton>
  </div>
);

// Componente de Empty State
interface EmptyStateProps {
  searchText: string;
  filtrosActivos: number;
  onLimpiarFiltros: () => void;
  onRetry: () => void;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  searchText,
  filtrosActivos,
  onLimpiarFiltros,
  onRetry
}) => (
  <div className="empty-state">
    <div className="empty-state-icon">
      {searchText || filtrosActivos > 0 ? '🔍' : '📦'}
    </div>
    <IonText color="medium">
      <h3>
        {searchText || filtrosActivos > 0 
          ? 'No se encontraron productos' 
          : 'No hay productos disponibles'
        }
      </h3>
      <p>
        {searchText || filtrosActivos > 0
          ? 'Intenta ajustar tus filtros de búsqueda'
          : 'Vuelve más tarde para ver nuestros productos destacados.'
        }
      </p>
    </IonText>
    {(searchText || filtrosActivos > 0) && (
      <IonButton fill="outline" onClick={onLimpiarFiltros}>
        <IonIcon icon={close} slot="start" />
        Limpiar filtros
      </IonButton>
    )}
    <IonButton fill="outline" onClick={onRetry}>
      <IonIcon icon={refresh} slot="start" />
      Actualizar
    </IonButton>
  </div>
);