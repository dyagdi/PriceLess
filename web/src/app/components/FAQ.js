'use client';
import * as React from 'react';
import Accordion from '@mui/material/Accordion';
import AccordionDetails from '@mui/material/AccordionDetails';
import AccordionSummary from '@mui/material/AccordionSummary';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';

export default function FAQ() {
  const [expanded, setExpanded] = React.useState(false);

  const handleChange = (panel) => (event, isExpanded) => {
    setExpanded(isExpanded ? panel : false);
  };

  const faqItems = [
    {
      id: 'panel1',
      question: 'Priceless nasıl çalışır?',
      answer: 'Priceless, farklı marketlerdeki ürün fiyatlarını karşılaştırmanıza olanak sağlayan bir platformdur. Düzenli olarak güncellenen veritabanımız sayesinde, marketlerdeki güncel fiyatları görüntüleyebilir ve en uygun fiyatlı ürünleri bulabilirsiniz.'
    },
    {
      id: 'panel2',
      question: 'Fiyatlar ne sıklıkla güncelleniyor?',
      answer: 'Fiyatlar düzenli olarak güncellenmektedir. Marketlerin fiyat değişikliklerini takip ederek, size en güncel bilgileri sunmaya çalışıyoruz.'
    },
    {
      id: 'panel3',
      question: 'Hangi marketlerin fiyatlarını karşılaştırabiliyorum?',
      answer: 'Şu anda Türkiye\'nin önde gelen zincir marketlerinin (A101, BİM, ŞOK, Migros, CarrefourSA vb.) fiyatlarını karşılaştırabilirsiniz.'
    },
    {
      id: 'panel4',
      question: 'Ürün fiyatları arasında fark görürsem ne yapmalıyım?',
      answer: 'Fiyat farklılıkları marketler arasında normal bir durumdur. Eğer bir fiyatın güncel olmadığını düşünüyorsanız, bize bildirebilirsiniz. Ekibimiz en kısa sürede kontrol edip gerekli güncellemeleri yapacaktır.'
    },
    {
      id: 'panel5',
      question: 'Priceless uygulamasını nasıl kullanabilirim?',
      answer: 'Uygulamamızı kullanmak çok kolay! İstediğiniz ürünü arama çubuğuna yazabilir veya kategoriler üzerinden gezinebilirsiniz. Ürünlerin farklı marketlerdeki fiyatlarını görebilir ve size en uygun olanı seçebilirsiniz.'
    },
    {
      id: 'panel6',
      question: 'Ürünleri satın alabilir miyim?',
      answer: 'Priceless bir fiyat karşılaştırma platformudur. Doğrudan satış yapmamaktayız, ancak size en uygun fiyatlı ürünlerin hangi markette olduğunu göstererek alışverişinizde yardımcı oluyoruz.'
    },
    {
      id: 'panel7',
      question: 'Fiyat alarmı kurabilir miyim?',
      answer: 'Evet, takip etmek istediğiniz ürünler için fiyat alarmı kurabilirsiniz. Belirlediğiniz fiyata düştüğünde size bildirim göndereceğiz.'
    },
    {
      id: 'panel8',
      question: 'Uygulama ücretsiz mi?',
      answer: 'Evet, Priceless tamamen ücretsiz bir uygulamadır. Herhangi bir ücret ödemeden tüm özellikleri kullanabilirsiniz.'
    }
  ];

  return (
    <Container sx={{ py: 8 }} id="faq">
      <Typography variant="h4" align="center" gutterBottom>
        Sıkça Sorulan Sorular
      </Typography>
      <Typography variant="body2" color="text.secondary" align="center" sx={{ mb: 4 }}>
        Priceless hakkında merak edilenler
      </Typography>
      {faqItems.map((item) => (
        <Accordion
          key={item.id}
          expanded={expanded === item.id}
          onChange={handleChange(item.id)}
          sx={{ mb: 1 }}
        >
          <AccordionSummary
            expandIcon={<ExpandMoreIcon />}
            aria-controls={`${item.id}-content`}
            id={`${item.id}-header`}
          >
            <Typography sx={{ fontWeight: 'medium' }}>
              {item.question}
            </Typography>
          </AccordionSummary>
          <AccordionDetails>
            <Typography color="text.secondary">
              {item.answer}
            </Typography>
          </AccordionDetails>
        </Accordion>
      ))}
    </Container>
  );
}
