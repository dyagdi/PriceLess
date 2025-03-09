'use client';
import React from 'react';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import AddShoppingCartIcon from '@mui/icons-material/AddShoppingCart';
import Snackbar from '@mui/material/Snackbar';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Tooltip from '@mui/material/Tooltip';
import { useBasket } from '../context/BasketContext';

export default function ProductCard({ product }) {
  const { addToBasket } = useBasket();
  const [openSnackbar, setOpenSnackbar] = React.useState(false);
  
  // Handle image error
  const handleImageError = (e) => {
    e.target.onerror = null; // Prevent infinite loop if fallback also fails
    e.target.src = '/placeholder.jpg'; // Set fallback image
  };

  // Ensure product has a unique identifier
  const handleAddToBasket = () => {
    // Create a copy of the product to avoid reference issues
    const productCopy = { ...product };
    
    // Ensure the product has an ID
    if (!productCopy.id) {
      productCopy.id = `product-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    }
    
    addToBasket(productCopy);
    setOpenSnackbar(true); // Show snackbar notification
  };

  const handleCloseSnackbar = (event, reason) => {
    if (reason === 'clickaway') {
      return;
    }
    setOpenSnackbar(false);
  };

  return (
    <>
      <Card sx={{ 
        height: '100%', 
        display: 'flex', 
        flexDirection: 'column',
        overflow: 'hidden',
        position: 'relative',
      }}>
        <Box sx={{ 
          position: 'relative', 
          height: '160px', 
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          backgroundColor: '#f5f5f5',
          overflow: 'hidden'
        }}>
          <CardMedia
            component="img"
            image={product.image || product.image_url || '/placeholder.jpg'}
            alt={product.name}
            onError={handleImageError}
            sx={{ 
              objectFit: 'contain', // This ensures the image is fully visible
              maxHeight: '140px',
              maxWidth: '90%',
              margin: 'auto',
              padding: '10px'
            }}
          />
        </Box>
        <CardContent sx={{ flexGrow: 1, p: 2, display: 'flex', flexDirection: 'column' }}>
          <Tooltip title={product.name} placement="top-start">
            <Typography 
              gutterBottom 
              variant="subtitle1" 
              component="div" 
              sx={{ 
                fontWeight: 500,
                mb: 1,
                minHeight: '3em',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                display: '-webkit-box',
                WebkitLineClamp: 3,
                WebkitBoxOrient: 'vertical',
                lineHeight: '1.2em',
                fontSize: '0.875rem'
              }}
            >
              {product.name}
            </Typography>
          </Tooltip>
          <Typography 
            variant="body2" 
            color="text.secondary"
            sx={{ mb: 2, fontWeight: 'bold' }}
          >
            ₺{product.price?.toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
          </Typography>
          <Box sx={{ 
            display: 'flex', 
            justifyContent: 'center', 
            alignItems: 'center',
            mt: 'auto' // Push button to bottom of card
          }}>
            <Button
              variant="contained"
              color="primary"
              size="small"
              fullWidth
              startIcon={<AddShoppingCartIcon />}
              onClick={handleAddToBasket}
              sx={{ 
                borderRadius: '20px',
                boxShadow: '0 2px 5px rgba(0,0,0,0.2)',
                '&:hover': {
                  transform: 'translateY(-2px)',
                  boxShadow: '0 4px 8px rgba(0,0,0,0.3)',
                },
                transition: 'all 0.2s ease-in-out'
              }}
            >
              Add to Basket
            </Button>
          </Box>
        </CardContent>
      </Card>
      <Snackbar 
        open={openSnackbar} 
        autoHideDuration={2000} 
        onClose={handleCloseSnackbar}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert 
          onClose={handleCloseSnackbar} 
          severity="success" 
          variant="filled"
          sx={{ width: '100%' }}
        >
          {product.name} added to basket!
        </Alert>
      </Snackbar>
    </>
  );
} 
