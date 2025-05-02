'use client';

import React, { createContext, useState, useContext, useEffect } from 'react';

const FavoritesContext = createContext();

export const useFavorites = () => useContext(FavoritesContext);

export function FavoritesProvider({ children }) {
  const [favorites, setFavorites] = useState([]);

  // Load favorites from localStorage on component mount
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const storedFavorites = localStorage.getItem('favorites');
      if (storedFavorites) {
        try {
          setFavorites(JSON.parse(storedFavorites));
        } catch (error) {
          console.error('Failed to parse favorites from localStorage:', error);
          setFavorites([]);
        }
      }
    }
  }, []);

  // Save favorites to localStorage whenever they change
  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('favorites', JSON.stringify(favorites));
    }
  }, [favorites]);

  const isFavorite = (product) => {
    if (!product || !product.id) return false;
    return favorites.some(item => item.id === product.id);
  };

  const toggleFavorite = (product) => {
    const productCopy = { ...product };
    
    if (!productCopy.id) {
      productCopy.id = `product-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    }

    setFavorites(prev => {
      if (isFavorite(productCopy)) {
        return prev.filter(item => item.id !== productCopy.id);
      } else {
        return [...prev, productCopy];
      }
    });
  };

  const clearFavorites = () => {
    setFavorites([]);
    if (typeof window !== 'undefined') {
      localStorage.removeItem('favorites');
    }
  };

  return (
    <FavoritesContext.Provider value={{ 
      favorites, 
      isFavorite, 
      toggleFavorite, 
      clearFavorites 
    }}>
      {children}
    </FavoritesContext.Provider>
  );
} 