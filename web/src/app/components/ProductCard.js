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
import FavoriteIcon from '@mui/icons-material/Favorite';
import LocalOfferIcon from '@mui/icons-material/LocalOffer';
import Snackbar from '@mui/material/Snackbar';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Tooltip from '@mui/material/Tooltip';
import Chip from '@mui/material/Chip';
import { useBasket } from '../context/BasketContext';
import { useFavorites } from '../context/FavoritesContext';

export default function ProductCard({ product = {} }) {
  const { addToBasket } = useBasket();
  const { isFavorite, toggleFavorite } = useFavorites();
  const [openSnackbar, setOpenSnackbar] = React.useState(false);
  const [isHovered, setIsHovered] = React.useState(false);
  const [imgSrc, setImgSrc] = React.useState(() => {
    return product?.image || product?.image_url || '/default.png';
  });
  const [imgError, setImgError] = React.useState(false);
  
  const handleImageError = (e) => {
    console.log('Image failed to load:', imgSrc);
    e.target.onerror = null; // Prevent infinite loops
    setImgError(true);
    setImgSrc('/default.png');
  };

  const handleAddToBasket = () => {
    if (!product) return;
    
    const productCopy = { ...product };
    
    if (!productCopy.id) {
      productCopy.id = `product-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    }
    
    addToBasket(productCopy);
    setOpenSnackbar(true);
  };

  const handleCloseSnackbar = (event, reason) => {
    if (reason === 'clickaway') {
      return;
    }
    setOpenSnackbar(false);
  };

  const handleToggleFavorite = (e) => {
    if (!product) return;
    e.stopPropagation();
    toggleFavorite(product);
  };

  // Safely check for discount with null checks
  const hasDiscount = product?.price && product?.high_price && 
                      !isNaN(product.price) && !isNaN(product.high_price) && 
                      product.price < product.high_price;
                      
  const discountPercentage = hasDiscount 
    ? Math.round(((product.high_price - product.price) / product.high_price) * 100) 
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
          borderRadius: 3,
          transition: 'all 0.3s ease',
          boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
          border: 'none',
          '&:hover': {
            boxShadow: '0 6px 16px rgba(0,0,0,0.1)',
          }
        }}
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        {hasDiscount && (
          <Box
            sx={{ 
              position: 'absolute', 
              top: 8, 
              right: 8, 
              zIndex: 2,
              backgroundColor: '#FF5B3D',
              color: 'white',
              fontSize: '12px',
              fontWeight: 'bold',
              padding: '4px 8px',
              borderRadius: 1,
            }}
          >
            -%{discountPercentage}
          </Box>
        )}
        
        <IconButton 
          size="small" 
          onClick={handleToggleFavorite}
          sx={{ 
            position: 'absolute', 
            top: 8, 
            left: 8, 
            zIndex: 2,
            backgroundColor: 'rgba(255,255,255,0.8)',
            padding: '4px',
            '&:hover': { 
              backgroundColor: 'rgba(255,255,255,0.95)',
            },
            color: isFavorite(product) ? 'error.main' : 'inherit',
          }}
        >
          {isFavorite(product) ? (
            <FavoriteIcon fontSize="small" />
          ) : (
            <FavoriteBorderIcon fontSize="small" />
          )}
        </IconButton>
 
        <Box sx={{ 
          position: 'relative', 
          height: '180px', 
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          backgroundColor: '#ffffff',
          overflow: 'hidden',
        }}>
          {!imgError ? (
            <CardMedia
              component="img"
              image={imgSrc}
              alt={product?.name || 'Product'}
              onError={handleImageError}
              sx={{ 
                objectFit: 'contain',
                maxHeight: '150px',
                maxWidth: '90%',
                margin: 'auto',
                padding: '10px',
              }}
            />
          ) : (
            <Box 
              sx={{ 
                width: '100px', 
                height: '100px', 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'center',
                backgroundColor: 'rgba(0,0,0,0.03)',
                borderRadius: '8px',
                color: 'text.secondary'
              }}
            >
              <Typography variant="caption">No Image</Typography>
            </Box>
          )}
        </Box>
        
        <CardContent sx={{ 
          flexGrow: 1, 
          p: 2, 
          display: 'flex', 
          flexDirection: 'column',
          bgcolor: 'background.paper',
        }}>
          <Box
            sx={{
              backgroundColor: 'hsl(120, 85%, 95%)',
              borderRadius: 1,
              px: 1.5,
              py: 0.5,
              mb: 1,
              alignSelf: 'flex-start',
            }}
          >
            <Typography 
              variant="caption"
              sx={{
                color: 'primary.dark',
                fontWeight: 600,
                fontSize: '0.75rem',
              }}
            >
              Süt Ürünleri
            </Typography>
          </Box>
          
          <Typography 
            variant="subtitle1" 
            component="div" 
            sx={{ 
              fontWeight: 600,
              mb: 1,
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              display: '-webkit-box',
              WebkitLineClamp: 2,
              WebkitBoxOrient: 'vertical',
              lineHeight: '1.2em',
              fontSize: '0.9rem',
              height: '2.4em',
            }}
          >
            {product?.name || 'Unnamed Product'}
          </Typography>
          
          <Box sx={{ mt: 'auto', display: 'flex', alignItems: 'baseline' }}>
            <Typography 
              variant="h6" 
              sx={{ 
                fontWeight: 'bold',
                fontSize: '1.25rem',
                color: '#333',
              }}
            >
              {product?.price ? `₺${product.price.toLocaleString('tr-TR', { minimumFractionDigits: 2 })}` : '₺0.00'}
            </Typography>
            
            {hasDiscount && product?.high_price && (
              <Typography 
                variant="body2" 
                sx={{ 
                  ml: 1,
                  textDecoration: 'line-through',
                  color: 'text.secondary',
                  fontSize: '0.85rem',
                }}
              >
                ₺{product.high_price.toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
              </Typography>
            )}
          </Box>
          
          <Button
            variant="contained"
            color="primary"
            size="medium"
            fullWidth
            onClick={handleAddToBasket}
            sx={{ 
              mt: 2,
              borderRadius: 2,
              boxShadow: 'none',
              py: 1,
              fontWeight: 600,
              textTransform: 'none',
              backgroundColor: '#68B96A',
              '&:hover': {
                backgroundColor: '#5AA45C',
              }
            }}
          >
            Sepete Ekle
          </Button>
        </CardContent>
      </Card>
      
      {/* Notification */}
      <Snackbar
        open={openSnackbar}
        autoHideDuration={3000}
        onClose={handleCloseSnackbar}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert 
          onClose={handleCloseSnackbar} 
          severity="success" 
          variant="filled"
          sx={{ width: '100%' }}
        >
          Ürün sepete eklendi!
        </Alert>
      </Snackbar>
    </>
  );
} 
