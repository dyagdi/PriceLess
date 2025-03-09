'use client';
import * as React from 'react';
import { useBasket } from '../context/BasketContext';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import AppAppBar from './AppAppBar';

export default function MyBasket() {
  const { basket, getTotalPrice, removeFromBasket } = useBasket();
  
  // Debug: Log the basket to see what's in it
  React.useEffect(() => {
    console.log("Current basket:", basket);
  }, [basket]);

  return (
    <>
      <AppAppBar />
      <Container sx={{ py: 4, mt: 10 }}>
        <Typography variant="h4" gutterBottom align="center">
          My Basket
        </Typography>
        
        {basket.length === 0 ? (
          <Typography variant="h6" align="center">
            Your Basket is Empty
          </Typography>
        ) : (
          <>
            {/* Debug: Show how many items are in the basket */}
            <Typography variant="body1" align="center" sx={{ mb: 3 }}>
              Items in basket: {basket.length}
            </Typography>
            
            <Grid container spacing={3}>
              {basket.map((item, index) => (
                <Grid item xs={12} sm={6} md={3} key={`basket-item-${index}-${item.basketId || item.id || item.name}`}>
                  <Card sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
                    <CardMedia
                      component="img"
                      height="140"
                      image={item.image || item.image_url || '/placeholder.jpg'}
                      alt={item.name}
                      onError={(e) => {
                        e.target.onerror = null;
                        e.target.src = '/placeholder.jpg';
                      }}
                    />
                    <CardContent>
                      <Typography variant="h6">{item.name}</Typography>
                      <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                        ₺{item.price?.toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
                      </Typography>
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <Button
                          variant="outlined"
                          color="secondary"
                          onClick={() => {
                            console.log("Removing item:", item);
                            removeFromBasket(item.basketId || item.id || index);
                          }}
                        >
                          Remove
                        </Button>
                      </Box>
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>
            <Typography variant="h5" align="center" sx={{ mt: 4 }}>
              Total: ₺{getTotalPrice().toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
            </Typography>
          </>
        )}
      </Container>
    </>
  );
} 
