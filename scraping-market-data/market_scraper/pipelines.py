# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
from itemadapter import ItemAdapter
import psycopg2
from datetime import date
from decouple import config


class SokMarketScraperPipeline:
    def process_item(self, item, spider):
        return item


class ReorderFieldsPipeline:
    def process_item(self, item, spider):
        # Define the desired order of fields
        field_order = [
            "main_category",
            "sub_category",
            "lowest_category",
            "name",
            "price",
            "high_price",
            "in_stock",
            "product_link",
            "page_link",
            "image_url",
            "date"
        ]
        # Create a new dictionary with the fields in the desired order
        reordered_item = {field: item.get(field) for field in field_order}
        item = reordered_item
        return item


class PostgreSQLPipeline:
    def __init__(self):
        # Database connection parameters - use environment variables or config
        self.conn = None
        self.cur = None

    def open_spider(self, spider):
        # Connect to the database when the spider starts
        try:
            print(f"Attempting to connect to database: {config('DATABASE_NAME', default='unknown')}")
            self.conn = psycopg2.connect(
                host=config('DATABASE_HOST', default='localhost'),
                database=config('DATABASE_NAME'),
                user=config('DATABASE_USER'),
                password=config('DATABASE_PASSWORD'),
                port=config('DATABASE_PORT', default='5432')
            )
            print("Database connection successful!")
            self.cur = self.conn.cursor()
            
            # Create table if it doesn't exist
            print(f"Creating table {spider.name}_products if it doesn't exist")
            self.create_table(spider.name)
            print(f"Table {spider.name}_products created or already exists")
            
            # Clear old data if needed (optional)
            if hasattr(spider, 'clear_old_data') and spider.clear_old_data:
                print(f"Clearing old data for {spider.name}")
                self.clear_old_data(spider.name)
                
        except Exception as e:
            print(f"Database connection error: {e}")
            spider.logger.error(f"Database connection error: {e}")
            # Print the full traceback for debugging
            import traceback
            traceback.print_exc()

    def close_spider(self, spider):
        # Close database connection when spider finishes
        if self.conn:
            self.conn.close()

    def create_table(self, market_name):
        # Create a table for the specific market if it doesn't exist
        table_name = f"{market_name}_products"
        
        self.cur.execute(f"""
            CREATE TABLE IF NOT EXISTS {table_name} (
                id SERIAL PRIMARY KEY,
                main_category TEXT,
                sub_category TEXT,
                lowest_category TEXT,
                name TEXT,
                price REAL,
                high_price REAL,
                in_stock BOOLEAN,
                product_link TEXT,
                page_link TEXT,
                image_url TEXT,
                date DATE,
                market_name TEXT,
                UNIQUE(name, date)
            )
        """)
        self.conn.commit()

    def clear_old_data(self, market_name):
        # Clear old data for today's date
        today = date.today()
        table_name = f"{market_name}_products"
        
        self.cur.execute(f"""
            DELETE FROM {table_name} 
            WHERE date = %s
        """, (today,))
        self.conn.commit()

    def process_item(self, item, spider):
        # Insert item into the database
        try:
            table_name = f"{spider.name}_products"
            print(f"Processing item for table {table_name}")
            
            # Convert in_stock to boolean if it's not already
            in_stock = item.get('in_stock')
            if isinstance(in_stock, str):
                in_stock = in_stock.lower() == 'true'
            
            # Insert data into the table with ON CONFLICT DO UPDATE
            self.cur.execute(f"""
                INSERT INTO {table_name} (
                    main_category, sub_category, lowest_category, 
                    name, price, high_price, in_stock, 
                    product_link, page_link, image_url, date, market_name
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (name, date) DO UPDATE 
                SET price = EXCLUDED.price, 
                    high_price = EXCLUDED.high_price, 
                    in_stock = EXCLUDED.in_stock
            """, (
                item.get('main_category'),
                item.get('sub_category'),
                item.get('lowest_category'),
                item.get('name'),
                item.get('price'),
                item.get('high_price'),
                in_stock,
                item.get('product_link'),
                item.get('page_link'),
                item.get('image_url'),
                spider.current_date,
                spider.name
            ))
            self.conn.commit()
            print(f"Item successfully inserted into {table_name}")
            
        except Exception as e:
            print(f"Error inserting item into database: {e}")
            spider.logger.error(f"Error inserting item into database: {e}")
            # Print the full traceback for debugging
            import traceback
            traceback.print_exc()
            
        return item
