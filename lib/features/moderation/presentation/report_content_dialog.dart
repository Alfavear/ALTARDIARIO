import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/providers/app_providers.dart';
import '../providers/moderation_providers.dart';

class ReportContentDialog extends ConsumerStatefulWidget {
  final String targetType;
  final String targetId;
  final String targetTitle;
  final String targetAuthor;

  const ReportContentDialog({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetTitle,
    required this.targetAuthor,
  });

  @override
  ConsumerState<ReportContentDialog> createState() =>
      _ReportContentDialogState();
}

class _ReportContentDialogState extends ConsumerState<ReportContentDialog> {
  static const _reasons = [
    'Lenguaje ofensivo',
    'Acoso o intimidación',
    'Spam',
    'Contenido inapropiado',
    'Desinformación',
    'Otro',
  ];

  String? _selectedReason;
  String? _customReason;
  String? _errorMessage;
  bool _sending = false;

  Future<void> _submit() async {
    final uid = ref.read(effectiveUserUidProvider);
    final reason =
        _selectedReason == 'Otro' ? _customReason?.trim() : _selectedReason;
    if (uid == null) return;
    if (reason == null || reason.isEmpty) {
      setState(
        () => _errorMessage = 'Escribe el motivo o elige una de las opciones.',
      );
      return;
    }

    setState(() {
      _sending = true;
      _errorMessage = null;
    });
    try {
      await ref.read(moderationRepositoryProvider).reportarContenido(
            reporterId: uid,
            targetType: widget.targetType,
            targetId: widget.targetId,
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
      title: Text(
          'Reportar ${widget.targetType == 'reflexion' ? 'reflexión' : 'comentario'}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Qué ocurre con "${widget.targetTitle}" de ${widget.targetAuthor}?',
              style: const TextStyle(fontSize: 14),
            ),
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
                children: [
                  ..._reasons.map(
                    (reason) => RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(reason),
                      value: reason,
                    ),
                  ),
                  if (_selectedReason == 'Otro') ...[
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Especifica el motivo',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      maxLength: 200,
                      onChanged: (value) => _customReason = value,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
