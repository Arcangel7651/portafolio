import React from 'react';
import { IonButton, IonIcon } from '@ionic/react';
import { heart, heartOutline, checkmarkCircle, alertCircle } from 'ionicons/icons';
import { Producto } from '../../models/Producto';
import './ProductCard.css';

interface ProductCardProps {
  producto: Producto;
  isFavorite: boolean;
  onToggleFavorite: (productId: number) => void;
  formatPrice: (producto: Producto) => string;
}

const ProductCard: React.FC<ProductCardProps> = ({
  producto,
  isFavorite,
  onToggleFavorite,
  formatPrice
}) => {
  return (
    <div className="card">
      <div className="card-img">
        <IonButton
          fill="clear"
          className="favorite-btn"
          onClick={(e) => {
            e.stopPropagation();
            onToggleFavorite(producto.id);
          }}
        >
          <IonIcon
            className="favorite-icon"
            icon={isFavorite ? heart : heartOutline}
            color={isFavorite ? "danger" : "medium"}
          />
        </IonButton>

        {producto.imagen ? (
          <img
            src={producto.imagen}
            alt={producto.nombre}
            loading="lazy"
            onError={(e) => {
              const target = e.target as HTMLImageElement;
              target.style.display = 'none';
            }}
          />
        ) : (
          <div className="no-image-placeholder">
            📷
          </div>
        )}
      </div>
      
      <div className="card-info">
        <p className="text-title">{producto.nombre}</p>
        <p className="text-body">
          {producto.descripcion?.length > 100
            ? producto.descripcion.slice(0, 100) + '...'
            : producto.descripcion || 'Sin descripción disponible'}
        </p>
        <p className="text-body">{"En stock: "+producto.stock}</p>
        {producto.categoria_nombre && (
          <p className="categoria">{producto.categoria_nombre}</p>
        )}
      </div>
      
      <div className="card-footer">
        <span className={`badge ${producto.esta_disponible ? 'disponible' : 'nodisponible'}`}>
          <IonIcon 
            icon={producto.esta_disponible ? checkmarkCircle : alertCircle} 
            size="small" 
          />
          {producto.esta_disponible ? 'Disponible' : 'No disponible'}
        </span>
        <div className="card-button">
          {formatPrice(producto)}
        </div>
      </div>
    </div>
  );
};

export default ProductCard;