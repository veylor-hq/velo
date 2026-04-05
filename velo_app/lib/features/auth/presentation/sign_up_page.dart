import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

import '../providers/auth_provider.dart';
import '../../../core/settings/haptics_provider.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    ref.read(hapticsConfigProvider.notifier).light();
    if (_passwordController.text != _repeatPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // Navigate to sign-in page
        context.go('/signin');

        // Show Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User was created')),
        );

        // Show Bottom Sheet to verify email
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email, size: 48, color: Colors.deepPurple),
                const SizedBox(height: 16),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Go verify your email address by opening a link in your email app.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut).slideY(begin: 0.05, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        final data = e.response?.data;
        final detail = data is Map ? data['detail'] : null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(detail?.toString() ?? e.message ?? 'An error occurred')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _repeatPasswordController,
              decoration: const InputDecoration(labelText: 'Repeat Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
            TextButton(
              onPressed: () => context.go('/signin'),
              child: const Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }
}
