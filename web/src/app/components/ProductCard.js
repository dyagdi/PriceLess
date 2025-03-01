'use client';
import React from 'react';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import { useBasket } from '../context/BasketContext';

export default function ProductCard({ product }) {
  const { addToBasket } = useBasket();
  
  // Fallback image URL in case the product image is not availabl

  // Handle image error
  const handleImageError = (e) => {
    e.target.onerror = null; // Prevent infinite loop if fallback also fails
  };

  return (
    <Card sx={{ 
      height: '100%', 
      display: 'flex', 
      flexDirection: 'column',
      overflow: 'hidden',
    }}>
      <CardMedia
                        component="img"
                        height="140"
                        image={product.image }
                        alt={product.name}
                      />
      <CardContent sx={{ flexGrow: 1, p: 2 }}>

        <Typography 
          gutterBottom 
          variant="h6" 
          component="div" 
          noWrap
          sx={{ 
            fontWeight: 500,
            mb: 1 
          }}
        >
          {product.name}
        </Typography>
        <Typography 
          variant="body2" 
          color="text.secondary"
          sx={{ mb: 2 }}
        >
          ₺{product.price?.toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
        </Typography>
      </CardContent>
    </Card>
  );
} 