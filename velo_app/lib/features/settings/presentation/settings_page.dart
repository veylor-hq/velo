import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              context.push('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Currency Symbol'),
            subtitle: Text(currency),
            onTap: () async {
              final controller = TextEditingController(text: currency);
              final newCurrency = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Change Currency Symbol'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'e.g. \$, £, €'),
                    maxLength: 3,
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
                  ],
                ),
              );
              if (newCurrency != null && newCurrency.isNotEmpty) {
                ref.read(currencyProvider.notifier).setCurrency(newCurrency.trim());
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}
