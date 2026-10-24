import 'package:flutter/material.dart';
import 'empty_state_view.dart';
import 'error_state_view.dart';
import 'loading_state_view.dart';

/// Wrapper unificado para vistas que consultan datos remotos.
/// Encapsula la lógica condicional para que cualquier pantalla o provider
/// pueda alternar limpiamente entre los 4 estados sin duplicar lógica if/else.
class AsyncStateBuilder<T> extends StatelessWidget {
  final bool isLoading;
  final Object? error;
  final List<T>? items;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context, List<T> data) builder;
  final String emptyTitle;
  final String emptyDescription;
  final IconData emptyIcon;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  const AsyncStateBuilder({
    super.key,
    required this.isLoading,
    required this.error,
    required this.items,
    required this.onRetry,
    required this.builder,
    this.emptyTitle = 'No hay elementos disponibles',
    this.emptyDescription = 'Comienza agregando un nuevo registro.',
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyActionLabel,
    this.onEmptyAction,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingStateView();
    }

    if (error != null) {
      return ErrorStateView(
        message:
            'Ocurrió un problema de comunicación. Revisa tu conexión e intenta de nuevo.',
        onRetry: onRetry,
      );
    }

    if (items == null || items!.isEmpty) {
      return EmptyStateView(
        icon: emptyIcon,
        title: emptyTitle,
        description: emptyDescription,
        actionLabel: emptyActionLabel,
        onAction: onEmptyAction,
      );
    }

    return builder(context, items!);
  }
}
