GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ReportContentDialog(
                          targetType: 'comentario',
                          targetId: comment.id,
                          targetTitle: comment.texto.length > 50
                              ? '${comment.texto.substring(0, 50)}...'
                              : comment.texto,
                          targetAuthor: comment.userName,
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.flag_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final uid = ref.read(effectiveUserUidProvider);
                      if (uid == null) return;
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Bloquear usuario'),
                          content: Text(
                              '¿Seguro que quieres bloquear a ${comment.userName}? No podrás ver su contenido ni interactuar con él.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Bloquear'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref
                            .read(firestoreServiceProvider)
                            .bloquearUsuario(uid, comment.userId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Usuario bloqueado')),
                          );
                        }
                      }
                    },
                    child: const Icon(
                      Icons.block_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }