import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'change_password_page.dart';
import '../services/api_service.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await ApiService.logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılırken bir hata oluştu: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    try {
      print('Starting account deletion process...');
      final success = await ApiService.deleteAccount();
      print('Account deletion result: $success');
      
      if (success && context.mounted) {
        print('Account deleted successfully, navigating to auth page');
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );
      } else if (context.mounted) {
        print('Account deletion failed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesap silinirken bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      print('Error during account deletion: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hesap silinirken bir hata oluştu: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Ayarları'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          _buildSection(
            title: 'Güvenlik',
            children: [
              _buildListTile(
                title: 'Şifre Değiştir',
                icon: Icons.lock_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXl),
          _buildSection(
            title: 'Hesap',
            children: [
              _buildListTile(
                title: 'Hesabı Kapat',
                icon: Icons.delete_outline,
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
              ),
              _buildListTile(
                title: 'Çıkış Yap',
                icon: Icons.logout,
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Kapat'),
        content: const Text('Hesabınızı kapatmak istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleDeleteAccount(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Hesabı Kapat'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleLogout(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
