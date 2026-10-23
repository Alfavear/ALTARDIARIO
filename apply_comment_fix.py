content = open('lib/presentation/screens/feed_screen.dart', 'r', encoding='utf-8').read()

old_comment_end = """GestureDetector(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }"""

new_comment_end = """GestureDetector(
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
  }"""

content = content.replace(old_comment_end, new_comment_end, 1)

with open('lib/presentation/screens/feed_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Comment section updated successfully')