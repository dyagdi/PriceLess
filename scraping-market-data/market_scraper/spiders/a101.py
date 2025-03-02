import scrapy
from ..items import MarketItem
from datetime import date
import time
import traceback
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager
from scrapy.http import HtmlResponse


class A101Spider(scrapy.Spider):
    name = "a101"
    home_url = "https://www.a101.com.tr"
    current_date = date.today()
    clear_old_data = True  # Set to True to clear old data for today's date
    
    # Define the categories to scrape - using the same ones from your original code
    categories = {
        'Meyve, Sebze': 'https://www.a101.com.tr/kapida/meyve-sebze',
        'Et, Balık, Tavuk': 'https://www.a101.com.tr/kapida/et-balik-tavuk',
        'Süt Ürünleri, Kahvaltılık': 'https://www.a101.com.tr/kapida/sut-urunleri-kahvaltilik'
    }
    
    # Keep the CSV export if you still want it alongside database storage
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
    
    def __init__(self, *args, **kwargs):
        super(A101Spider, self).__init__(*args, **kwargs)
        self.driver = None
        self.product_count = 0
    
    def setup_driver(self):
        options = webdriver.ChromeOptions()
        options.add_argument("--disable-gpu")
        options.add_argument("--window-size=1920x1080")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_experimental_option("prefs", {"profile.managed_default_content_settings.images": 2})
        
        driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
        return driver
    
    def start_requests(self):
        # Initialize the Selenium driver
        self.driver = self.setup_driver()
        
        # Start with the predefined categories
        for category_name, category_url in self.categories.items():
            self.logger.info(f"Processing category: {category_name}")
            yield scrapy.Request(
                url=category_url,
                callback=self.parse_category,
                meta={'category_name': category_name}
            )
    
    def scroll_to_load_all_products(self, driver):
        self.logger.info("Scrolling to load all products...")
        last_height = driver.execute_script("return document.body.scrollHeight")
        while True:
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            time.sleep(3)  

            new_height = driver.execute_script("return document.body.scrollHeight")
            if new_height == last_height:
                time.sleep(5)
                new_height = driver.execute_script("return document.body.scrollHeight")
                if new_height == last_height:
                    break  
            last_height = new_height
        self.logger.info("Finished scrolling")
    
    def parse_category(self, response):
        category_name = response.meta['category_name']
        
        try:
            # Use Selenium to load the page and scroll to load all products
            self.driver.get(response.url)
            time.sleep(5)
            self.scroll_to_load_all_products(self.driver)
            
            # Extract subcategories using the exact selector from your original code
            subcategories = self.driver.find_elements(By.CSS_SELECTOR, "div[id^='productGroup_desktop']")
            
            if not subcategories:
                self.logger.warning(f"No subcategories found for {category_name}")
                return
            
            self.logger.info(f"Found {len(subcategories)} subcategories for {category_name}")
            
            for subcategory in subcategories:
                try:
                    # Extract subcategory name
                    subcategory_name = subcategory.find_element(By.TAG_NAME, "h1").text.strip()
                    self.logger.info(f"Processing subcategory: {subcategory_name}")
                    
                    # Extract products using the exact selectors from your original code
                    product_names = subcategory.find_elements(By.CSS_SELECTOR, "div.mobile\\:text-xs")
                    product_blocks = subcategory.find_elements(By.CSS_SELECTOR, "div.h-\\[39px\\].w-full.relative")
                    product_images = subcategory.find_elements(By.CSS_SELECTOR, "img")
                    
                    self.logger.info(f"Found {len(product_names)} products in {subcategory_name}")
                    
                    # Process products
                    for name, product_block, image in zip(product_names, product_blocks, product_images):
                        try:
                            product_name = name.text.strip()
                            product_image_url = image.get_attribute("src")
                            
                            # Extract high price (if available)
                            try:
                                high_price_elem = product_block.find_element(By.CSS_SELECTOR, "div.line-through")
                                high_price_text = high_price_elem.text.strip() if high_price_elem.text else None
                                high_price = self.parse_price(high_price_text) if high_price_text else None
                            except:
                                high_price = None
                            
                            # Extract current price
                            try:
                                price_elem = product_block.find_element(By.CSS_SELECTOR, "div.text-md")
                                price_text = price_elem.text.strip()
                                price = self.parse_price(price_text) if price_text else None
                            except:
                                price = None
                            
                            # Only yield if we have a product name and price
                            if product_name and price:
                                self.product_count += 1
                                self.logger.info(f"Product {self.product_count}: {product_name} - {price} TL")
                                
                                yield MarketItem(
                                    main_category=category_name,
                                    sub_category=subcategory_name,
                                    lowest_category=subcategory_name,
                                    name=product_name,
                                    price=price,
                                    high_price=high_price,
                                    in_stock=True,  # Assuming all displayed products are in stock
                                    product_link=self.driver.current_url,
                                    page_link=response.url,
                                    image_url=product_image_url,
                                    date=self.current_date
                                )
                        except Exception as e:
                            self.logger.error(f"Error processing product: {e}")
                            traceback.print_exc()
                
                except Exception as e:
                    self.logger.error(f"Error processing subcategory: {e}")
                    traceback.print_exc()
            
        except Exception as e:
            self.logger.error(f"Error parsing category {category_name}: {e}")
            traceback.print_exc()
    
    def parse_price(self, price_text):
        if not price_text:
            return None
        
        # Clean up the price text
        price_text = price_text.strip()
        price_text = price_text.replace('TL', '').replace('₺', '').strip()
        price_text = price_text.replace('.', '').replace(',', '.')
        
        try:
            return float(price_text)
        except ValueError:
            self.logger.warning(f"Could not parse price: {price_text}")
            return None
    
    def closed(self, reason):
        # Close the Selenium driver when the spider is closed
        self.logger.info(f"Spider closed: {reason}")
        self.logger.info(f"Total products scraped: {self.product_count}")
        if self.driver:
            self.driver.quit() 