import React, { useRef } from 'react';
import { IonPopover, IonSearchbar, IonButton } from '@ionic/react';

interface SearchPopoverProps {
  isOpen: boolean;
  searchText: string;
  onDidDismiss: () => void;
  onSearchTextChange: (text: string) => void;
  onClear: () => void;
}

const SearchPopover: React.FC<SearchPopoverProps> = ({
  isOpen,
  searchText,
  onDidDismiss,
  onSearchTextChange,
  onClear
}) => {
  const searchPopoverRef = useRef<HTMLIonPopoverElement>(null);

  const handleClear = () => {
    onClear();
    onDidDismiss();
  };

  const handleSearch = () => {
    onDidDismiss();
  };

  return (
    <IonPopover
      ref={searchPopoverRef}
      isOpen={isOpen}
      onDidDismiss={onDidDismiss}
      trigger="search-trigger"
      className="search-popover"
    >
      <div className="popover-content">
        <IonSearchbar
          value={searchText}
          onIonInput={(e) => onSearchTextChange(e.detail.value!)}
          placeholder="Buscar productos..."
          showClearButton="focus"
          debounce={300}
          className="popover-searchbar"
          onIonClear={() => onSearchTextChange('')}
        />
        {searchText && (
          <div className="search-actions">
            <IonButton 
              size="small" 
              fill="clear" 
              onClick={handleClear}
            >
              Limpiar
            </IonButton>
            <IonButton 
              size="small" 
              onClick={handleSearch}
            >
              Buscar
            </IonButton>
          </div>
        )}
      </div>
    </IonPopover>
  );
};

export default SearchPopover;