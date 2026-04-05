import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

import '../../../core/storage/secure_storage.dart';
import '../../../core/config.dart';
import '../../../core/settings/haptics_provider.dart';

class ServerSetupPage extends ConsumerStatefulWidget {
  const ServerSetupPage({super.key});

  @override
  ConsumerState<ServerSetupPage> createState() => _ServerSetupPageState();
}

class _ServerSetupPageState extends ConsumerState<ServerSetupPage> {
  final _serverUrlController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingUrl();
  }

  Future<void> _loadExistingUrl() async {
    const storage = SecureStorageService();
    final url = await storage.getServerUrl();
    setState(() {
      _serverUrlController.text = url ?? AppConfig.baseUrl;
      _isLoading = false;
    });
  }

  Future<void> _saveAndContinue() async {
    ref.read(hapticsConfigProvider.notifier).light();
    setState(() => _isLoading = true);
    
    final url = _serverUrlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a server URL')));
      setState(() => _isLoading = false);
      return;
    }

    const storage = SecureStorageService();
    await storage.setServerUrl(url);
    
    if (mounted) {
      context.go('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.dns, size: 60, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'HOST CONFIGURATION',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Point the application safely to your secure server ecosystem.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _serverUrlController,
                decoration: const InputDecoration(
                  labelText: 'Server API URL',
                  prefixIcon: Icon(Icons.cloud),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _saveAndContinue,
                  child: const Text('CONNECT & CONTINUE'),
                ),
            ],
          ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut).slideY(begin: 0.05, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),
        ),
      ),
    );
  }
}
