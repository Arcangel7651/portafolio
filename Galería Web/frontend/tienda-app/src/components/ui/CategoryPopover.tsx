import React, { useRef } from 'react';
import { IonPopover, IonList, IonItem, IonLabel, IonIcon } from '@ionic/react';
import { checkmarkCircle } from 'ionicons/icons';
import { Categoria } from '../../models/Categoria';
import './CategoryPopover.css';

interface CategoryPopoverProps {
  isOpen: boolean;
  categorias: Categoria[];
  categoriaSeleccionada: number | null;
  onDidDismiss: () => void;
  onCategoriaChange: (categoria: number | null) => void;
}

const CategoryPopover: React.FC<CategoryPopoverProps> = ({
  isOpen,
  categorias,
  categoriaSeleccionada,
  onDidDismiss,
  onCategoriaChange
}) => {
  const categoriaPopoverRef = useRef<HTMLIonPopoverElement>(null);

  return (
    <IonPopover
      ref={categoriaPopoverRef}
      isOpen={isOpen}
      onDidDismiss={onDidDismiss}
      trigger="categoria-trigger"
      className="categoria-popover"
    >
      <div className="popover-content">
        <div className="popover-header">
          <h4>Categorías</h4>
        </div>
        <IonList className="categoria-list">
          <IonItem 
            button 
            onClick={() => onCategoriaChange(null)}
            className={categoriaSeleccionada === null ? 'selected-item' : ''}
          >
            <IonLabel>
              <h3>Todas las categorías</h3>
            </IonLabel>
            {categoriaSeleccionada === null && <IonIcon icon={checkmarkCircle} color="primary" />}
          </IonItem>
          {categorias.map((categoria) => (
            <IonItem 
              key={categoria.id} 
              button 
              onClick={() => onCategoriaChange(categoria.id)}
              className={categoriaSeleccionada === categoria.id ? 'selected-item' : ''}
            >
              <IonLabel>
                <h3>{categoria.nombre}</h3>
              </IonLabel>
              {categoriaSeleccionada === categoria.id && <IonIcon icon={checkmarkCircle} color="primary" />}
            </IonItem>
          ))}
        </IonList>
      </div>
    </IonPopover>
  );
};

export default CategoryPopover;