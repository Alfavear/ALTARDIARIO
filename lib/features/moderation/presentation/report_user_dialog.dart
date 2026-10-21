import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/providers/app_providers.dart';

class ReportUserDialog extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const ReportUserDialog({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends ConsumerState<ReportUserDialog> {
  static const _reasons = [
    'Lenguaje ofensivo',
    'Acoso o intimidación',
    'Spam',
    'Contenido inapropiado',
  ];

  String? _selectedReason;
  String? _errorMessage;
  bool _sending = false;

  Future<void> _submit() async {
    final uid = ref.read(effectiveUserUidProvider);
    final reason = _selectedReason;
    if (uid == null || reason == null) return;

    setState(() {
      _sending = true;
      _errorMessage = null;
    });
    try {
      await ref.read(firestoreServiceProvider).reportarContenido(
            reporterId: uid,
            targetType: 'usuario',
            targetId: widget.userId,
            reason: reason,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Gracias. Revisaremos tu reporte.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo enviar el reporte. Inténtalo de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reportar usuario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¿Qué ocurre con ${widget.userName}?'),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: _selectedReason,
            onChanged: (value) {
              if (!_sending) setState(() => _selectedReason = value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _reasons
                  .map(
                    (reason) => RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(reason),
                      value: reason,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _sending || _selectedReason == null ? null : _submit,
          child: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar reporte'),
        ),
      ],
    );
  }
}
