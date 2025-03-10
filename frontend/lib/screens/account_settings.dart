import 'package:flutter/material.dart';

class AccountSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Ayarları'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildChangePasswordSection(context),
          Divider(),
          _buildCloseAccountSection(context),
          Divider(),
          _buildLogoutSection(context),
        ],
      ),
    );
  }


  Widget _buildChangePasswordSection(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.lock, color: Colors.blue, size: 30),
      title: Text('Şifre Değiştir', style: TextStyle(fontSize: 18)),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChangePasswordPage()),
        );
      },
    );
  }

  
  Widget _buildLogoutSection(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.exit_to_app, color: Colors.orange, size: 30),
      title: Text('Çıkış Yap', style: TextStyle(fontSize: 18)),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        _showLogoutDialog(context);
      },
    );
  }
  
  Widget _buildCloseAccountSection(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.delete, color: Colors.red, size: 30),
      title: Text('Hesabı Kapat', style: TextStyle(fontSize: 18)),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        _showCloseAccountDialog(context);
      },
    );
  }

   void _showCloseAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hesabı Kapat'),
          content: Text('Hesabınızı kapatmak istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                // yapılacak
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hesabınız başarıyla kapatıldı.')),
                );
              },
              child: const Text('Onayla', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                //yapılacak
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Başarıyla çıkış yaptınız.')),
                );
              },
              child: const Text('Evet', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Değiştir'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mevcut Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Yeni Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Yeni Şifreyi Onayla',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // yapılacak
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Şifreniz başarıyla değiştirildi.')),
                );
              },
              child: const Text('Şifreyi Değiştir'),
            ),
          ],
        ),
      ),
    );
  }
}