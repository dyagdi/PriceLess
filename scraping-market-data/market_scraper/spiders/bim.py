import scrapy
from datetime import datetime
from datetime import date

class BimSpider(scrapy.Spider):
    name = "bim"
    start_urls = [
        "https://www.bim.com.tr/",
        "https://www.bim.com.tr/?Bim_AktuelTarihKey=1223",
        "https://www.bim.com.tr/?Bim_AktuelTarihKey=100",
        "https://www.bim.com.tr/?Bim_AktuelTarihKey=1203",
        "https://www.bim.com.tr/?Bim_AktuelTarihKey=1207",
        "https://www.bim.com.tr/?Bim_AktuelTarihKey=1211",
        "https://www.bim.com.tr/?Bim_AktuelTarihKey=1208",
        "https://www.bim.com.tr/?Bim_AktuelTarihKey=1215",
        "https://www.bim.com.tr/?Bim_AktuelTarihKey=1216",
        "https://www.bim.com.tr/?Bim_AktuelTarihKey=1221",
        "https://www.bim.com.tr/?Bim_AktuelTarihKey=1224"
    ]
    current_date = date.today()
    custom_settings = {
        "FEEDS": {
            f"{name}_{current_date}.csv": {
                "format": "csv",
                "encoding": "utf8",
                "store_empty": False,
                "fields": None,
                "indent": 4,
                "item_export_kwargs": {
                    "export_empty_fields": True,
                }
            }
        }
    }

    # Initialize a set to track unique products by name
    unique_products = set()

    def parse(self, response):
        for product in response.css("div.product"):
            main_category = "Aktüel Ürünler"
            sub_category = response.css("h2.mainTitle::text").get().strip()
            lowest_category = sub_category

            name = product.css("h2.title::text").get()
            brand = product.css("h2.subTitle::text").get()
            full_name = f"{brand} {name}" if brand else name

            # Extract the discounted price components
            price_integer = product.css("a.gButton .text.quantify::text").get()
            price_fraction = product.css("div.kusurArea span.number::text").get()
            if price_integer and price_fraction:
                price = f"{price_integer.replace(',', '')}.{price_fraction}"
            elif price_integer:
                price = price_integer.replace(',', '.')
            else:
                price = None

            # Extract the original (high) price components
            high_price_integer = product.css("div.CountButton.strikethrough .text.quantify::text").get()
            high_price_fraction = product.css("div.CountButton.strikethrough .kusurArea span.number::text").get()
            if high_price_integer and high_price_fraction:
                high_price = f"{high_price_integer.replace(',', '')}.{high_price_fraction}"
            elif high_price_integer:
                high_price = high_price_integer.replace(',', '.')
            else:
                high_price = None

            # Extract the image link
            image_link = (product.css("div.image img::attr(xsrc)").get() or
                          product.css("div.image img::attr(data-src)").get() or
                          product.css("div.image img::attr(src)").get())

            # Product link
            product_link = response.urljoin(product.css("a::attr(href)").get())

            # Use full_name as the unique identifier
            unique_id = full_name

            # Check if the product has already been extracted
            if unique_id in self.unique_products or unique_id == None:
                continue  # Skip this product if it's a duplicate

            # Add the unique identifier to the set
            self.unique_products.add(unique_id)

            yield {
                "main_category": main_category,
                "sub_category": sub_category,
                "lowest_category": lowest_category,
                "name": full_name,
                "price": f"{price}" if price else None,
                "high_price": f"{high_price}" if high_price else None,
                "in_stock": True,
                "product_link": product_link,
                "image_url": image_link,
                "page_link": response.url,
                "date": datetime.now().strftime("%Y-%m-%d")
            }

        # Follow pagination links if they exist
        next_page = response.css("a.next-page::attr(href)").get()
        if next_page:
            yield response.follow(next_page, callback=self.parse)
