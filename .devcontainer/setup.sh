#!/usr/bin/env bash
set -euo pipefail

APP_NAME="shanghai"

# Check Flutter
flutter doctor -v || true

# Create the app if it doesn't exist
if [ ! -d "$APP_NAME" ]; then
  echo "Creating Flutter app $APP_NAME ..."
  flutter create "$APP_NAME"
fi

cd "$APP_NAME"

# Enable web and add packages
flutter config --enable-web || true
flutter pub add go_router flutter_riverpod http intl || true

# Folders
mkdir -p lib/features/home lib/features/settings

# router.dart
cat > lib/router.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_page.dart';
import 'features/settings/settings_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const HomePage()),
    GoRoute(path: '/settings', builder: (ctx, st) => const SettingsPage()),
  ],
);
EOF

# theme.dart
cat > lib/theme.dart << 'EOF'
import 'package:flutter/material.dart';

ThemeData appTheme(BuildContext context) {
  final base = ThemeData(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
EOF

# Home page
cat > lib/features/home/home_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adventures')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Welcome! This starter runs on your phone via Codespaces.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.go('/settings'),
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }
}
EOF

# Settings page
cat > lib/features/settings/settings_page.dart << 'EOF'
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Configure your app settings here.'),
      ),
    );
  }
}
EOF

# main.dart
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Adventures',
      theme: appTheme(context),
      routerConfig: router,
    );
  }
}
EOF

flutter pub get

echo "✅ Setup complete. To start: cd $APP_NAME && flutter run -d web-server"
