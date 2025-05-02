'use client';
import * as React from 'react';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import ProductCard from './ProductCard';

export default function Categories({ categoryProducts }) {
  if (!categoryProducts || categoryProducts.length === 0) {
    return null;
  }

  // Group products by category
  const productsByCategory = categoryProducts.reduce((acc, product) => {
    if (!acc[product.category]) {
      acc[product.category] = [];
    }
    acc[product.category].push(product);
    return acc;
  }, {});

  return (
    <Container sx={{ py: 4 }} id="categories">
      <Typography variant="h4" gutterBottom align="center">
        Kategoriler
      </Typography>
      <Typography variant="body2" color="text.secondary" align="center" sx={{ mb: 3 }}>
        Her kategorideki en iyi fırsatları keşfedin
      </Typography>
      {Object.entries(productsByCategory).map(([category, products]) => (
        <Box key={category} sx={{ mb: 4 }}>
          <Typography variant="h5" gutterBottom sx={{ mt: 4 }}>
            {category}
          </Typography>
          <Grid container spacing={3}>
            {products.map((product, index) => (
              <Grid item xs={12} sm={6} md={3} key={index}>
                <ProductCard product={product} />
              </Grid>
            ))}
          </Grid>
        </Box>
      ))}
    </Container>
  );
} 