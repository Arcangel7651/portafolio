import React from 'react';
import {
  IonModal,
  IonHeader,
  IonToolbar,
  IonTitle,
  IonButtons,
  IonButton,
  IonIcon,
  IonContent,
  IonList,
  IonItem,
  IonCheckbox,
  IonLabel
} from '@ionic/react';
import { close } from 'ionicons/icons';
import './FiltersModal.css';

interface FiltrosAvanzados {
  soloDisponibles: boolean;
  rangoPrecio: {
    min: number | null;
    max: number | null;
  };
}

interface FiltersModalProps {
  isOpen: boolean;
  filtrosAvanzados: FiltrosAvanzados;
  onDidDismiss: () => void;
  onFiltrosChange: (filtros: FiltrosAvanzados) => void;
  onReset: () => void;
}

const FiltersModal: React.FC<FiltersModalProps> = ({
  isOpen,
  filtrosAvanzados,
  onDidDismiss,
  onFiltrosChange,
  onReset
}) => {
  const handleDisponibilidadChange = (checked: boolean) => {
    onFiltrosChange({
      ...filtrosAvanzados,
      soloDisponibles: checked
    });
  };

  const handleReset = () => {
    onReset();
    onDidDismiss();
  };

  const handleApply = () => {
    onDidDismiss();
  };

  return (
    <IonModal isOpen={isOpen} onDidDismiss={onDidDismiss} className="filters-modal">
      <IonHeader>
        <IonToolbar>
          <IonTitle>Filtros Avanzados</IonTitle>
          <IonButtons slot="end">
            <IonButton
              fill="clear"
              onClick={onDidDismiss}
            >
              <IonIcon icon={close} />
            </IonButton>
          </IonButtons>
        </IonToolbar>
      </IonHeader>
      <IonContent>
        <div className="filters-content">
          <IonList>
            <div className="filter-section">
              <h4>Disponibilidad</h4>
              <IonItem>
                <IonCheckbox
                  checked={filtrosAvanzados.soloDisponibles}
                  onIonChange={(e) => handleDisponibilidadChange(e.detail.checked)}
                />
                <IonLabel className="ion-margin-start">
                  Solo productos disponibles
                </IonLabel>
              </IonItem>
            </div>
          </IonList>
          
          <div className="modal-actions">
            <IonButton
              expand="block"
              onClick={handleApply}
              className="apply-filters-btn"
            >
              Aplicar Filtros
            </IonButton>
            <IonButton
              expand="block"
              fill="outline"
              onClick={handleReset}
            >
              Restablecer
            </IonButton>
          </div>
        </div>
      </IonContent>
    </IonModal>
  );
};

export default FiltersModal;