import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/dio_client.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  void _showPasswordChangeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _ChangePasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The email isn't easily accessible from authState without parsing the token yourself 
    // or adding it, but we have the ability to change password as requested.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.person, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 24),
          const Text(
            'Your Profile',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: _showPasswordChangeSheet,
            icon: const Icon(Icons.lock),
            label: const Text('Change Password'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          )
        ],
      ),
    );
  }
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_currentController.text.isEmpty || _newController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final payload = {
        'current_password': _currentController.text,
        'new_password': _newController.text,
      };

      await ref.read(dioProvider).post('/api/public/auth/password/change', data: payload);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated securely')));
      }
    } on DioException catch (e) {
      if (mounted) {
        final data = e.response?.data;
        final detail = data is Map ? data['detail'] : null;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(detail?.toString() ?? e.message ?? 'An error occurred')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _currentController, decoration: const InputDecoration(labelText: 'Current Password'), obscureText: true),
          TextField(controller: _newController, decoration: const InputDecoration(labelText: 'New Password'), obscureText: true),
          const SizedBox(height: 24),
          if (_isLoading) const Center(child: CircularProgressIndicator())
          else ElevatedButton(onPressed: _submit, child: const Text('Update Password')),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
