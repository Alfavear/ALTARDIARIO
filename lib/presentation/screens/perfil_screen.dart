import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 64, color: AppTheme.primaryBlue),
            const SizedBox(height: 16),
            Text('Tu progreso y estadísticas aparecerán aquí', 
                 style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}