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
import ShoppingBagIcon from '@mui/icons-material/ShoppingBag';
import LocalShippingIcon from '@mui/icons-material/LocalShipping';
import PaymentIcon from '@mui/icons-material/Payment';
import Divider from '@mui/material/Divider';
import Paper from '@mui/material/Paper';
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
        {/* Page Header with Background */}
        <Paper 
          elevation={0} 
          sx={{ 
            p: 3, 
            mb: 4, 
            borderRadius: 2,
            background: 'linear-gradient(145deg, #f0f7ff 0%, #e6f0fd 100%)',
            position: 'relative',
            overflow: 'visible'
          }}
        >
          <Box sx={{ 
            display: 'flex', 
            flexDirection: 'column', 
            alignItems: 'center', 
            position: 'relative',
            zIndex: 1,
            pl: { xs: 0, sm: 8 }
          }}>
            <Typography 
              variant="h4" 
              gutterBottom 
              sx={{ 
                mb: 1, 
                textAlign: 'center',
                fontWeight: 600,
                color: 'primary.dark'
              }}
            >
              Sepetim
            </Typography>
            <Typography 
              variant="body2" 
              color="text.secondary" 
              align="center"
              sx={{ mb: 1 }}
            >
              Sepetinizdeki ürünleri inceleyebilir ve düzenleyebilirsiniz.
            </Typography>
          </Box>
          
          <Box sx={{ 
            position: { xs: 'relative', sm: 'absolute' }, 
            left: { xs: 0, sm: 16 },
            top: { xs: 'auto', sm: '50%' },
            transform: { xs: 'none', sm: 'translateY(-50%)' },
            width: { xs: '100%', sm: 'auto' },
            mt: { xs: 2, sm: 0 },
            display: 'flex',
            justifyContent: { xs: 'center', sm: 'flex-start' },
            zIndex: 5
          }}>
            <Button 
              startIcon={<ArrowBackIcon />} 
              onClick={handleContinueShopping}
              variant="outlined"
              size="small"
              sx={{ 
                borderRadius: '20px',
                pointerEvents: 'auto',
                position: 'relative',
                '&:hover': {
                  backgroundColor: 'rgba(255, 255, 255, 0.8)'
                }
              }}
            >
              Alışverişe Devam Et
            </Button>
          </Box>
          
          <Box sx={{ 
            position: 'absolute', 
            right: -20, 
            top: -20, 
            width: 100, 
            height: 100, 
            borderRadius: '50%', 
            bgcolor: 'primary.light', 
            opacity: 0.1,
            zIndex: 0
          }} />
          <Box sx={{ 
            position: 'absolute', 
            left: -15, 
            bottom: -15, 
            width: 70, 
            height: 70, 
            borderRadius: '50%', 
            bgcolor: 'secondary.light', 
            opacity: 0.1 
          }} />
        </Paper>
        
        {basket.length === 0 ? (
          <Paper 
            elevation={0} 
            sx={{ 
              display: 'flex', 
              flexDirection: 'column', 
              alignItems: 'center',
              justifyContent: 'center',
              py: 8,
              px: 4,
              borderRadius: 2,
              bgcolor: 'background.paper',
              border: '1px dashed',
              borderColor: 'divider'
            }}
          >
            <ShoppingCartIcon sx={{ fontSize: 80, color: 'text.secondary', mb: 3, opacity: 0.6 }} />
            <Typography variant="h5" align="center" gutterBottom sx={{ fontWeight: 500 }}>
              Sepetiniz Boş
            </Typography>
            <Typography variant="body1" align="center" color="text.secondary" sx={{ mb: 4, maxWidth: 500 }}>
              Henüz sepetinize ürün eklemediniz. Ürünleri keşfetmek ve sepetinize eklemek için alışverişe başlayın.
            </Typography>
            <Button 
              variant="contained" 
              color="primary" 
              onClick={handleContinueShopping}
              startIcon={<ShoppingBagIcon />}
              size="large"
              sx={{ 
                borderRadius: '24px',
                px: 4,
                py: 1,
                boxShadow: '0 4px 12px rgba(0,0,0,0.15)'
              }}
            >
              Alışverişe Başla
            </Button>
          </Paper>
        ) : (
          <>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 500 }}>
                Sepetimdeki Ürünler ({basket.length})
              </Typography>
            </Box>
            
            <Grid container spacing={3}>
              <Grid item xs={12} md={8}>
                <Grid container spacing={2}>
                  {basket.map((item, index) => (
                    <Grid item xs={12} sm={6} key={`basket-item-${index}-${item.basketId || item.id || item.name}`}>
                      <Card 
                        sx={{ 
                          display: 'flex', 
                          flexDirection: 'row',
                          height: '100%',
                          borderRadius: 2,
                          overflow: 'hidden',
                          transition: 'all 0.3s ease',
                          '&:hover': {
                            boxShadow: '0 8px 16px rgba(0,0,0,0.1)',
                            transform: 'translateY(-4px)'
                          }
                        }}
                      >
                        <Box sx={{ 
                          width: '40%',
                          position: 'relative', 
                          display: 'flex',
                          justifyContent: 'center',
                          alignItems: 'center',
                          backgroundColor: '#f5f5f5',
                          p: 2
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
                              maxHeight: '120px',
                              maxWidth: '100%'
                            }}
                          />
                        </Box>
                        <CardContent sx={{ 
                          flexGrow: 1, 
                          p: 2, 
                          display: 'flex', 
                          flexDirection: 'column',
                          width: '60%'
                        }}>
                          <Tooltip title={item.name} placement="top-start">
                            <Typography 
                              variant="subtitle1" 
                              component="div" 
                              sx={{ 
                                fontWeight: 500,
                                mb: 1,
                                overflow: 'hidden',
                                textOverflow: 'ellipsis',
                                display: '-webkit-box',
                                WebkitLineClamp: 2,
                                WebkitBoxOrient: 'vertical',
                                lineHeight: '1.2em'
                              }}
                            >
                              {item.name}
                            </Typography>
                          </Tooltip>
                          <Typography 
                            variant="h6" 
                            color="primary.main" 
                            sx={{ fontWeight: 'bold', mb: 1 }}
                          >
                            ₺{item.price?.toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
                          </Typography>
                          <Box sx={{ 
                            display: 'flex', 
                            justifyContent: 'flex-end', 
                            alignItems: 'center',
                            mt: 'auto'
                          }}>
                            <Button
                              variant="text"
                              color="error"
                              size="small"
                              startIcon={<DeleteIcon />}
                              onClick={() => {
                                console.log("Removing item:", item);
                                removeFromBasket(item.basketId || item.id || index);
                              }}
                            >
                              Kaldır
                            </Button>
                          </Box>
                        </CardContent>
                      </Card>
                    </Grid>
                  ))}
                </Grid>
              </Grid>
              
              <Grid item xs={12} md={4}>
                <Paper 
                  elevation={0} 
                  sx={{ 
                    p: 3,
                    borderRadius: 2,
                    border: '1px solid',
                    borderColor: 'divider',
                    position: 'sticky',
                    top: 100
                  }}
                >
                  <Typography variant="h5" gutterBottom sx={{ fontWeight: 600 }}>
                    Alışveriş Özeti
                  </Typography>
                  
                  <Box sx={{ my: 3 }}>
                    <Box sx={{ 
                      display: 'flex', 
                      justifyContent: 'space-between', 
                      mb: 2
                    }}>
                      <Typography variant="body1" color="text.secondary">
                        Ürünler ({basket.length})
                      </Typography>
                      <Typography variant="body1">
                        ₺{getTotalPrice().toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
                      </Typography>
                    </Box>
                    <Box sx={{ 
                      display: 'flex', 
                      justifyContent: 'space-between',
                      mb: 2
                    }}>
                    </Box>
                  </Box>
                  
                  <Divider sx={{ my: 2 }} />
                  
                  <Box sx={{ 
                    display: 'flex', 
                    justifyContent: 'space-between', 
                    alignItems: 'center',
                    mb: 3
                  }}>
                    <Typography variant="h6" sx={{ fontWeight: 600 }}>
                      Toplam:
                    </Typography>
                    <Typography variant="h6" color="primary.main" fontWeight="bold">
                      ₺{getTotalPrice().toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
                    </Typography>
                  </Box>
                </Paper>
              </Grid>
            </Grid>
          </>
        )}
      </Container>
    </>
  );
} 
