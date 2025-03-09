'use client';
import * as React from 'react';
import { useBasket } from '../context/BasketContext';
import { useNavigate } from 'react-router-dom';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import Tooltip from '@mui/material/Tooltip';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import DeleteIcon from '@mui/icons-material/Delete';
import AppAppBar from './AppAppBar';

export default function MyBasket() {
  const { basket, getTotalPrice, removeFromBasket } = useBasket();
  const navigate = useNavigate();
  
  // Debug: Log the basket to see what's in it
  React.useEffect(() => {
    console.log("Current basket:", basket);
  }, [basket]);

  const handleContinueShopping = () => {
    navigate('/');
  };

  return (
    <>
      <AppAppBar />
      <Container sx={{ py: 4, mt: 10 }}>
        <Box sx={{ 
          display: 'flex', 
          flexDirection: 'column', 
          alignItems: 'center', 
          position: 'relative',
          mb: 4 
        }}>
          <Typography variant="h4" gutterBottom sx={{ mb: 2, textAlign: 'center' }}>
            Sepetim
          </Typography>
          <Button 
            startIcon={<ArrowBackIcon />} 
            onClick={handleContinueShopping}
            sx={{ 
              position: 'absolute', 
              left: 0,
              top: '50%',
              transform: 'translateY(-50%)'
            }}
          >
            Alışverişe Devam Et
          </Button>
        </Box>
        
        {basket.length === 0 ? (
          <Box sx={{ 
            display: 'flex', 
            flexDirection: 'column', 
            alignItems: 'center',
            justifyContent: 'center',
            py: 8
          }}>
            <ShoppingCartIcon sx={{ fontSize: 60, color: 'text.secondary', mb: 2 }} />
            <Typography variant="h6" align="center" gutterBottom>
              Sepetiniz Boş
            </Typography>
            <Typography variant="body1" align="center" color="text.secondary" sx={{ mb: 4 }}>
              Henüz sepetinize ürün eklemediniz.
            </Typography>
            <Button 
              variant="contained" 
              color="primary" 
              onClick={handleContinueShopping}
            >
              Alışverişe Başla
            </Button>
          </Box>
        ) : (
          <>
            <Typography variant="body1" align="center" sx={{ mb: 3 }}>
              Sepetimdeki Ürünler: {basket.length}
            </Typography>
            
            <Grid container spacing={3}>
              {basket.map((item, index) => (
                <Grid item xs={12} sm={6} md={3} key={`basket-item-${index}-${item.basketId || item.id || item.name}`}>
                  <Card sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
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
                        image={item.image || item.image_url || '/placeholder.jpg'}
                        alt={item.name}
                        onError={(e) => {
                          e.target.onerror = null;
                          e.target.src = '/placeholder.jpg';
                        }}
                        sx={{ 
                          objectFit: 'contain',
                          maxHeight: '140px',
                          maxWidth: '90%',
                          margin: 'auto',
                          padding: '10px'
                        }}
                      />
                    </Box>
                    <CardContent sx={{ flexGrow: 1, p: 2, display: 'flex', flexDirection: 'column' }}>
                      <Tooltip title={item.name} placement="top-start">
                        <Typography 
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
                          {item.name}
                        </Typography>
                      </Tooltip>
                      <Typography 
                        variant="body2" 
                        color="text.secondary" 
                        sx={{ mb: 2, fontWeight: 'bold' }}
                      >
                        ₺{item.price?.toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
                      </Typography>
                      <Box sx={{ 
                        display: 'flex', 
                        justifyContent: 'center', 
                        alignItems: 'center',
                        mt: 'auto'
                      }}>
                        <Button
                          variant="outlined"
                          color="error"
                          fullWidth
                          startIcon={<DeleteIcon />}
                          onClick={() => {
                            console.log("Removing item:", item);
                            removeFromBasket(item.basketId || item.id || index);
                          }}
                          sx={{ borderRadius: '20px' }}
                        >
                          Kaldır
                        </Button>
                      </Box>
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>
            
            <Box sx={{ 
              mt: 6,
              mb: 4,
              p: 4,
              bgcolor: 'background.paper', 
              borderRadius: 2,
              boxShadow: '0 2px 10px rgba(0,0,0,0.1)',
              maxWidth: '600px',
              mx: 'auto'
            }}>
              <Typography variant="h5" align="center" gutterBottom>
                  Alışveriş Özeti
              </Typography>
              <Box sx={{ 
                display: 'flex', 
                justifyContent: 'space-between', 
                alignItems: 'center',
                borderTop: '1px solid',
                borderColor: 'divider',
                pt: 2,
                mt: 2
              }}>
                <Typography variant="h6">
                  Total:
                </Typography>
                <Typography variant="h6" color="primary.main" fontWeight="bold">
                  ₺{getTotalPrice().toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
                </Typography>
              </Box>
            </Box>
          </>
        )}
      </Container>
    </>
  );
} 
