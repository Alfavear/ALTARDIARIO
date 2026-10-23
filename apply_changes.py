content = open('lib/presentation/screens/public_profile_screen.dart', 'r', encoding='utf-8').read()

# 1. Add import for report_content_dialog
old_imports = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/reflexion.dart';
import '../../data/models/usuario.dart';
import '../providers/app_providers.dart';
import 'followers_screen.dart';"""

new_imports = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/reflexion.dart';
import '../../data/models/usuario.dart';
import '../../features/moderation/presentation/report_content_dialog.dart';
import '../providers/app_providers.dart';
import 'followers_screen.dart';"""

content = content.replace(old_imports, new_imports, 1)

# 2. Add PopupMenuButton to appBar actions
old_appbar = """return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text('Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),"""

new_appbar = """return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text('Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: !isSelf && uid != null
            ? [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'report') {
                      showDialog(
                        context: context,
                        builder: (_) => ReportContentDialog(
                          targetType: 'usuario',
                          targetId: userId,
                          targetTitle: displayName,
                          targetAuthor: displayName,
                        ),
                      );
                    } else if (value == 'block') {
                      await ref
                          .read(firestoreServiceProvider)
                          .bloquearUsuario(uid!, userId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuario bloqueado')),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'report',
                      child: ListTile(
                        leading: const Icon(Icons.flag_outlined),
                        title: const Text('Reportar'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'block',
                      child: ListTile(
                        leading: const Icon(Icons.block_outlined),
                        title: const Text('Bloquear'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),"""

content = content.replace(old_appbar, new_appbar, 1)

with open('lib/presentation/screens/public_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Changes applied successfully')