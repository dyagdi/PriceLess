'use client';
import React from 'react';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import AddShoppingCartIcon from '@mui/icons-material/AddShoppingCart';
import FavoriteBorderIcon from '@mui/icons-material/FavoriteBorder';
import LocalOfferIcon from '@mui/icons-material/LocalOffer';
import Snackbar from '@mui/material/Snackbar';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Tooltip from '@mui/material/Tooltip';
import Chip from '@mui/material/Chip';
import { useBasket } from '../context/BasketContext';

export default function ProductCard({ product }) {
  const { addToBasket } = useBasket();
  const [openSnackbar, setOpenSnackbar] = React.useState(false);
  const [isHovered, setIsHovered] = React.useState(false);
  
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

  // Check if product has a discount (for demo purposes)
  const hasDiscount = product.price && product.original_price && product.price < product.original_price;
  const discountPercentage = hasDiscount 
    ? Math.round(((product.original_price - product.price) / product.original_price) * 100) 
    : 0;

  return (
    <>
      <Card 
        sx={{ 
          height: '100%', 
          display: 'flex', 
          flexDirection: 'column',
          overflow: 'hidden',
          position: 'relative',
          borderRadius: 2,
          transition: 'all 0.3s ease',
          boxShadow: isHovered 
            ? '0 8px 24px rgba(0,0,0,0.12)' 
            : '0 2px 8px rgba(0,0,0,0.08)',
          transform: isHovered ? 'translateY(-4px)' : 'none',
          '&:hover': {
            borderColor: 'primary.main',
          }
        }}
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        {/* Discount badge */}
        {hasDiscount && (
          <Chip
            label={`${discountPercentage}% İndirim`}
            color="error"
            size="small"
            icon={<LocalOfferIcon />}
            sx={{ 
              position: 'absolute', 
              top: 10, 
              left: 10, 
              zIndex: 2,
              fontWeight: 'bold',
              boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
            }}
          />
        )}
        
        {/* Wishlist button */}
        <IconButton 
          size="small" 
          sx={{ 
            position: 'absolute', 
            top: 10, 
            right: 10, 
            zIndex: 2,
            backgroundColor: 'rgba(255,255,255,0.8)',
            '&:hover': { 
              backgroundColor: 'rgba(255,255,255,0.95)',
              color: 'error.main'
            }
          }}
        >
          <FavoriteBorderIcon fontSize="small" />
        </IconButton>
        
        {/* Image container */}
        <Box sx={{ 
          position: 'relative', 
          height: '180px', 
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          backgroundColor: '#f8f9fa',
          overflow: 'hidden',
          transition: 'all 0.3s ease',
          transform: isHovered ? 'scale(1.05)' : 'scale(1)',
          transformOrigin: 'center'
        }}>
          <CardMedia
            component="img"
            image={product.image || product.image_url || '/placeholder.jpg'}
            alt={product.name}
            onError={handleImageError}
            sx={{ 
              objectFit: 'contain',
              maxHeight: '150px',
              maxWidth: '90%',
              margin: 'auto',
              padding: '10px',
              transition: 'all 0.3s ease',
              filter: isHovered ? 'brightness(1.05)' : 'brightness(1)'
            }}
          />
        </Box>
        
        {/* Content */}
        <CardContent sx={{ 
          flexGrow: 1, 
          p: 2, 
          display: 'flex', 
          flexDirection: 'column',
          bgcolor: 'background.paper',
          borderTop: '1px solid',
          borderColor: 'divider'
        }}>
          {/* Market name if available */}
          {product.market_name && (
            <Typography 
              variant="caption" 
              color="primary"
              sx={{ 
                mb: 0.5, 
                fontWeight: 500,
                display: 'block'
              }}
            >
              {product.market_name}
            </Typography>
          )}
          
          {/* Product name */}
          <Tooltip title={product.name} placement="top-start">
            <Typography 
              gutterBottom 
              variant="subtitle1" 
              component="div" 
              sx={{ 
                fontWeight: 500,
                mb: 1,
                minHeight: '2.4em',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                display: '-webkit-box',
                WebkitLineClamp: 2,
                WebkitBoxOrient: 'vertical',
                lineHeight: '1.2em',
                fontSize: '0.875rem'
              }}
            >
              {product.name}
            </Typography>
          </Tooltip>
          
          {/* Price section */}
          <Box sx={{ mb: 2, display: 'flex', alignItems: 'center' }}>
            <Typography 
              variant="h6" 
              color="primary.main"
              sx={{ 
                fontWeight: 'bold',
                fontSize: '1.1rem'
              }}
            >
              ₺{product.price?.toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
            </Typography>
            
            {/* Original price if discounted */}
            {hasDiscount && (
              <Typography 
                variant="body2" 
                color="text.secondary"
                sx={{ 
                  ml: 1,
                  textDecoration: 'line-through',
                  fontWeight: 'medium'
                }}
              >
                ₺{product.original_price?.toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
              </Typography>
            )}
          </Box>
          
          {/* Add to basket button */}
          <Box sx={{ 
            display: 'flex', 
            justifyContent: 'center', 
            alignItems: 'center',
            mt: 'auto'
          }}>
            <Button
              variant="contained"
              color="primary"
              size="medium"
              fullWidth
              startIcon={<AddShoppingCartIcon />}
              onClick={handleAddToBasket}
              sx={{ 
                borderRadius: '8px',
                boxShadow: '0 2px 5px rgba(0,0,0,0.2)',
                py: 1,
                fontWeight: 500,
                '&:hover': {
                  transform: 'translateY(-2px)',
                  boxShadow: '0 4px 8px rgba(0,0,0,0.3)',
                },
                transition: 'all 0.2s ease-in-out',
                textTransform: 'none'
              }}
            >
              Sepete Ekle
            </Button>
          </Box>
        </CardContent>
      </Card>
      
      {/* Notification */}
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
          sx={{ 
            width: '100%',
            boxShadow: '0 4px 12px rgba(0,0,0,0.15)'
          }}
        >
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <Typography variant="body2" sx={{ fontWeight: 500 }}>
              {product.name.length > 30 ? `${product.name.substring(0, 30)}...` : product.name} sepete eklendi!
            </Typography>
          </Box>
        </Alert>
      </Snackbar>
    </>
  );
} 
