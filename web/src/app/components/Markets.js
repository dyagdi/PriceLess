'use client';
import * as React from 'react';
import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import ProductCard from './ProductCard'; 

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
      <Grid container spacing={4}>
        {marketProducts.map((market, index) => (
          <Grid item xs={12} key={index}>
            <Card sx={{ p: 3 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h5" gutterBottom sx={{ mb: 0 }}>
                  {market.marketName}
                </Typography>
                <Button 
                  variant="outlined" 
                  color="primary" 
                  size="small"
                >
                  Tümünü Gör
                </Button>
              </Box>
              <Grid container spacing={3}>
                {market.products.slice(0, 4).map((product, productIndex) => (
                  <Grid item xs={12} sm={6} md={3} key={productIndex}>
                    <ProductCard product={product} />
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
