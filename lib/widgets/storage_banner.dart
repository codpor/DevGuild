import 'dart:async';

import 'package:flutter/material.dart';

import '../repositories/local_repository.dart';

class StorageBanner extends StatelessWidget {
  final LocalRepository repository;
  final Widget child;
  const StorageBanner({
    super.key,
    required this.repository,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<SaveStatus>(
    valueListenable: repository.saveStatus,
    builder: (context, status, _) => Column(
      children: [
        if (status != SaveStatus.saved)
          Material(
            color: status == SaveStatus.failed
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    if (status == SaveStatus.saving) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        status == SaveStatus.failed
                            ? repository.saveErrorMessage
                            : 'Menyimpan perubahan...',
                      ),
                    ),
                    if (status == SaveStatus.failed)
                      TextButton(
                        onPressed: () => unawaited(
                          repository.flush().catchError((Object _) {}),
                        ),
                        child: const Text('Coba lagi'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(child: child),
      ],
    ),
  );
}
