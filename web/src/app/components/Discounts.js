'use client';
import * as React from 'react';
//import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import ProductCard from './ProductCard';  // Import the ProductCard component

export default function DiscountedProducts({ products }) {
  if (!products || products.length === 0) {
    return null;
  }

  return (
    <Container sx={{ py: 4 }} id="indirimli-urunler">
      <Typography variant="h4" gutterBottom align="center">
        İndirimli Ürünler
      </Typography>
      <Typography
        variant="body2"
        color="text.secondary"
        align="center"
        sx={{ mb: 3 }}
      >
        Popüler ürünlerdeki en son indirimleri kontrol edin.
      </Typography>
      <Grid container spacing={3}>
        {products.map((product, index) => (
          <Grid item xs={12} sm={6} md={3} key={index}>
            <ProductCard product={product} />
            
          </Grid>
        ))}
      </Grid>
    </Container>
  );
}
