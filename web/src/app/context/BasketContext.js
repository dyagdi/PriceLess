'use client';
import React, { createContext, useContext, useState, useEffect } from 'react';

const BasketContext = createContext();

export function BasketProvider({ children }) {
  const [basket, setBasket] = useState([]);

  // Debug: Log basket changes
  useEffect(() => {
    console.log("Basket updated:", basket);
  }, [basket]);

  const addToBasket = (product) => {
    if (!product) {
      console.error("Attempted to add undefined product to basket");
      return;
    }
    
    // Create a unique ID if the product doesn't have one
    const productToAdd = {
      ...product,
      basketId: product.id || `temp-id-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
    };
    
    setBasket((prevBasket) => {
      // Check if product already exists in basket by comparing all properties
      const existingProductIndex = prevBasket.findIndex(
        (item) => item.id === productToAdd.id && item.name === productToAdd.name
      );
      
      if (existingProductIndex >= 0) {
        // Create a new array with the updated product
        const newBasket = [...prevBasket];
        newBasket[existingProductIndex] = {
          ...newBasket[existingProductIndex],
          quantity: (newBasket[existingProductIndex].quantity || 1) + 1
        };
        return newBasket;
      }
      
      // Add new product to basket
      return [...prevBasket, { ...productToAdd, quantity: 1 }];
    });
  };

  const removeFromBasket = (productIdOrIndex) => {
    console.log("Removing product with ID/index:", productIdOrIndex);
    
    setBasket((prevBasket) => {
      // If it's a number and not an ID, treat it as an index
      if (typeof productIdOrIndex === 'number' && !prevBasket.some(item => item.id === productIdOrIndex)) {
        return prevBasket.filter((_, index) => index !== productIdOrIndex);
      }
      
      // Otherwise filter by ID or basketId
      return prevBasket.filter((item) => 
        item.id !== productIdOrIndex && 
        item.basketId !== productIdOrIndex
      );
    });
  };

  const updateQuantity = (productId, newQuantity) => {
    setBasket((prevBasket) =>
      prevBasket.map((item) =>
        (item.id === productId || item.basketId === productId)
          ? { ...item, quantity: newQuantity }
          : item
      )
    );
  };

  const getTotalPrice = () => {
    return basket.reduce((total, item) => total + (item.price * (item.quantity || 1)), 0);
  };

  const getBasketCount = () => {
    return basket.reduce((total, item) => total + (item.quantity || 1), 0);
  };

  const value = {
    basket,
    addToBasket,
    removeFromBasket,
    updateQuantity,
    getTotalPrice,
    getBasketCount
  };

  return (
    <BasketContext.Provider value={value}>
      {children}
    </BasketContext.Provider>
  );
}

export function useBasket() {
  const context = useContext(BasketContext);
  if (context === undefined) {
    throw new Error('useBasket must be used within a BasketProvider');
  }
  return context;
} 
