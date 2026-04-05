import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/settings/haptics_provider.dart';
import '../../../../core/settings/default_tab_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final themeMode = ref.watch(themeModeProvider);
    final hapticsEnabled = ref.watch(hapticsConfigProvider);
    final defaultTabAsync = ref.watch(defaultTabProvider);
    final defaultTab = defaultTabAsync.value ?? 1;

    final tabNames = ['Details', 'Fuel', 'Odometer', 'Supply'];

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
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme Mode'),
            subtitle: Text(themeMode.name.toUpperCase()),
            onTap: () {
              final current = ref.read(themeModeProvider);
              final next = current == ThemeMode.system
                  ? ThemeMode.dark
                  : (current == ThemeMode.dark ? ThemeMode.light : ThemeMode.system);
              ref.read(themeModeProvider.notifier).setTheme(next);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Tactile response on actions'),
            value: hapticsEnabled,
            onChanged: (val) {
              ref.read(hapticsConfigProvider.notifier).toggle(val);
            },
          ),
          ListTile(
            leading: const Icon(Icons.tab),
            title: const Text('Default Car Tab'),
            subtitle: Text(tabNames[defaultTab < 0 || defaultTab > 3 ? 1 : defaultTab]),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (index) => ListTile(
                    title: Text(tabNames[index]),
                    trailing: defaultTab == index ? const Icon(Icons.check) : null,
                    onTap: () {
                      ref.read(defaultTabProvider.notifier).setTab(index);
                      Navigator.pop(ctx);
                    },
                  )),
                )
              );
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
            leading: const Icon(Icons.info),
            title: const Text('About Veylor'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('About Veylor', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Veylor Group\n\nAutomotive Tracking System.\nDesigned globally.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
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
