import scrapy
from ..items import MarketItem  # Assuming MarketItem is defined in your project
from datetime import date
import traceback
import random

class GimatSpider(scrapy.Spider):
    name = "gimat"
    home_url = "https://www.gimatsepeti.com"
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
        },
        "DOWNLOAD_DELAY": 2,
        "AUTOTHROTTLE_ENABLED": True,
        "AUTOTHROTTLE_START_DELAY": 1,
        "AUTOTHROTTLE_MAX_DELAY": 5,
        "AUTOTHROTTLE_TARGET_CONCURRENCY": 1.0,
        "CONCURRENT_REQUESTS": 4,
        "ROBOTSTXT_OBEY": True,
        "HTTPCACHE_ENABLED": True,
        "DEPTH_LIMIT": 3,
    }
    
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0",
        "Accept": "application/json",
        "Accept-Language": "tr-TR,tr;q=0.5",
    }

    def start_requests(self):
        yield scrapy.Request(
            url=self.home_url,
            headers=self.headers,
            callback=self.parse
        )

    def parse(self, response):
        try:
            # Find main categories
            categories = response.css("li.has-sublist.mega-menu-categories")
            for category in categories:
                main_category_name = category.css("a.with-subcategories::text").get().strip()

                # Find subcategories within each main category
                sub_categories = category.css("div.sublist-wrap > ul.sublist > li.has-sublist")
                for sub_category in sub_categories:
                    sub_category_name = sub_category.css("a.with-subcategories span::text").get().strip()
                    sub_category_url = sub_category.css("a.with-subcategories::attr(href)").get()

                    # Find lowest categories within each subcategory
                    lowest_categories = sub_category.css("a.lastLevelCategory")
                    if lowest_categories:
                        for lowest_category in lowest_categories:
                            lowest_category_name = lowest_category.css("span::text").get().strip()
                            lowest_category_url = lowest_category.attrib["href"]

                            yield scrapy.Request(
                                url=response.urljoin(lowest_category_url),
                                callback=self.parse_products,
                                meta={
                                    "main_category": main_category_name,
                                    "sub_category": sub_category_name,
                                    "lowest_category": lowest_category_name
                                },
                                headers=self.headers
                            )
                    else:
                        # If no lowest category, treat subcategory as the lowest level
                        yield scrapy.Request(
                            url=response.urljoin(sub_category_url),
                            callback=self.parse_products,
                            meta={
                                "main_category": main_category_name,
                                "sub_category": sub_category_name,
                                "lowest_category": sub_category_name
                            },
                            headers=self.headers
                        )

        except Exception as e:
            traceback.print_exc()

    def parse_products(self, response):
        main_category = response.meta['main_category']
        sub_category = response.meta['sub_category']
        lowest_category = response.meta['lowest_category']

        # Loop over products on the page
        for product in response.css('.product-item'):

            #print("#########################")
            #print(product)
            #print("######################")
            name = product.css('.product-title a::text').get().strip()
            price = self.format_price(product.css('.actual-price::text').get())
            #image_url = product.css('.picture a img::attr(src)').get()
            image_url = product.css('img::attr(data-lazyloadsrc)').get()

            product_url = response.urljoin(product.css('.product-title a::attr(href)').get())

            yield MarketItem(
                main_category=main_category,
                sub_category=sub_category,
                lowest_category=lowest_category,
                name=name,
                price=price,
                high_price=None,
                in_stock=True,
                product_link=product_url,
                page_link=response.url,
                image_url=image_url,
                date=self.current_date.strftime('%Y-%m-%d')
            )

    def format_price(self, raw_price):
        if raw_price:
            return float(raw_price.replace("₺", "").replace(",", ".").strip())
        return None
