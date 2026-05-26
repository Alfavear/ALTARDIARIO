import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OracionScreen extends StatelessWidget {
  const OracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compañeros de Oración')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 64, color: AppTheme.accentGold),
            const SizedBox(height: 16),
            Text('Próximamente: Peticiones de Oración', 
                 style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}