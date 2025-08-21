import { useState, useCallback } from 'react';

export const useFavorites = (onMessage: (message: string) => void) => {
  const [favoritos, setFavoritos] = useState<Set<number>>(new Set());

  const toggleFavorito = useCallback((productId: number) => {
    setFavoritos(prev => {
      const newFavoritos = new Set(prev);
      if (newFavoritos.has(productId)) {
        newFavoritos.delete(productId);
        onMessage('Eliminado de favoritos');
      } else {
        newFavoritos.add(productId);
        onMessage('Agregado a favoritos');
      }
      return newFavoritos;
    });
  }, [onMessage]);

  return {
    favoritos,
    toggleFavorito
  };
};