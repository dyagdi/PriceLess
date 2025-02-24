# General Information About the Scraping Code





## Scraped Data Format

Each code scrapes the data in the format:

|        main_category 	        |        sub_category 	        |         lowest_category 	          |        name 	        |            price 	            |                  high_price 	                  |             in_stock 	             |   product_link 	    |                  page_link                  |   image_url      |           date              |
|:-----------------------------:|:----------------------------:|:----------------------------------:|:--------------------:|:-----------------------------:|:----------------------------------------------:|:----------------------------------:|:-------------------:|:-------------------------------------------:|:-----------:|:-------------------------:|
| Main category of the product  | Sub-category of the product  | Lowest sub category of the product | Product name  | Current price of the product  | High price of the product if there is a discount for that product  | Availability of the product in stock  | URL of the product  | URL of the page that product is on |     URL of the image photo   |   Date that product was scraped  |


## Setting Up The Environment

### Go to project directory
```
$ cd scraping-market-data
```
### Create and activate a virtual environment
<span style="color: gray;">To ensure that the needed Python packages do not corrupt the Python packages in your local area</span>
```
$ virtualenv venv
$ source venv/bin/activate
```
### Install the needed Python packages
```
(venv) $ pip install -r requirements.txt
```

### Run the spiders
```
$ scrapy crawl <spider name>
```
Spider names

- sokmarket 
- carrefour 
- mopas 
- marketpaketi 
- migros 
- gimat
- bim (be careful with this one)


### Use one script to run spiders, merge datas and store data in one folder
<span style="color: grey;">Use this script to scrape datas into "market_scraper/data" directory, merge them together and store in one file under "market_scraper/data/merged_data" </span>
```
$ python run_spiders.py
```

The command above may not be working right.


