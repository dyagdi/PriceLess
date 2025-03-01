'use client';
import * as React from 'react';
//import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';

export default function Markets({ marketProducts }) {
  if (!marketProducts || marketProducts.length === 0) {
    return null;
  }

  return (
    <Container sx={{ py: 4 }} id="markets">
      <Typography variant="h4" gutterBottom align="center">
        Marketlerdeki Ürünler
      </Typography>
      <Typography variant="body2" color="text.secondary" align="center" sx={{ mb: 3 }}>
        Farklı marketlerdeki ürünleri keşfedin.
      </Typography>
      <Grid container spacing={3}>
        {marketProducts.map((market, index) => (
          <Grid item xs={12} md={6} key={index}>
            <Card sx={{ height: '100%', p: 2 }}>
              <Typography variant="h6" gutterBottom>
                {market.market_name}
              </Typography>
              <Grid container spacing={2}>
                {market.products.slice(0, 4).map((product, productIndex) => (
                  <Grid item xs={6} sm={3} key={productIndex}>
                    <Card sx={{ height: '100%' }}>
                      <CardMedia
                        component="img"
                        height="100"
                        image={product.image || '/placeholder.jpg'}
                        alt={product.name}
                      />
                      <CardContent>
                        <Typography variant="body2" noWrap>
                          {product.name}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          ₺{product.price}
                        </Typography>
                      </CardContent>
                    </Card>
                  </Grid>
                ))}
              </Grid>
            </Card>
          </Grid>
        ))}
      </Grid>
    </Container>
  );
}
