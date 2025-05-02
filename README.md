# PriceLess

-Backend ve flutter project klasörleri sabit kalacak. Backend klasörünün içine venv oluşturulacak (python -m venv venv). python manage.py runserver venv açıkken (source venv/bin/activate) çalışacak. Backend klasöründe PriceLess'ın içindeki settingste herkes kendi database bağlantı bilgilerini girecek. 

-Simülatör olarak Iphone 16 Plus kullanıldı.(Ben XCODE üzerinden seçtim)

-Backend klasörünün içindeki requirements.txt venv içine kurulması gereken libler/dependencyler.

-Venv içindeyken "pip install -r requirements.txt" komutu ile bunları yüklemeliyiz ki dependecy sorunu çıkmasın :)

-Frontend kısmı için ayrıca venv açmadım.

-Backend içinde .env dosyası oluşturulacak. içine şunları kopyalayıp yapıştırın:

```
DATABASE_ENGINE='django.db.backends.postgresql'
DATABASE_NAME='small_db'
DATABASE_USER='postgres'
DATABASE_PASSWORD='***'
DATABASE_HOST='localhost'
DATABASE_PORT='5432'

```
