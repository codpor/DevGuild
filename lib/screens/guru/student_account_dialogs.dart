import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../utils/result.dart';
import '../../utils/validators.dart';

Future<void> showStudentPasswordReset(
  BuildContext context,
  UserModel student,
) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) =>
        _PasswordResetDialog(studentId: student.id, studentName: student.name),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password siswa berhasil direset.')),
    );
  }
}

Future<void> showStudentStatusConfirmation(
  BuildContext context,
  UserModel student,
  bool active,
) async {
  final action = active ? 'Aktifkan Akun' : 'Nonaktifkan Akun';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(action),
      content: Text(
        active
            ? '${student.name} akan dapat login kembali.'
            : '${student.name} tidak dapat login sampai akun diaktifkan kembali. Karya, tiket, poin, dan badge tetap tersimpan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Konfirmasi'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final result = context.read<AuthProvider>().setStudentActive(
    student.id,
    active,
  );
  final message = result is Failure<UserModel>
      ? result.message
      : active
      ? 'Akun siswa diaktifkan.'
      : 'Akun siswa dinonaktifkan.';
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _PasswordResetDialog extends StatefulWidget {
  final String studentId;
  final String studentName;
  const _PasswordResetDialog({
    required this.studentId,
    required this.studentName,
  });
  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final result = context.read<AuthProvider>().resetStudentPassword(
      widget.studentId,
      _password.text,
    );
    if (result is Failure<UserModel>) {
      setState(() => _error = result.message);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Reset Password'),
    content: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tetapkan password baru untuk ${widget.studentName}.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                suffixIcon: IconButton(
                  tooltip: _obscure
                      ? 'Tampilkan password'
                      : 'Sembunyikan password',
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (value) {
                final error = Validators.validatePassword(value);
                if (error != null) return error;
                return value!.trim().isEmpty
                    ? 'Password tidak boleh hanya berisi spasi.'
                    : null;
              },
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirm,
              obscureText: _obscure,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password Baru',
              ),
              validator: (value) =>
                  Validators.validateConfirmPassword(value, _password.text),
              onFieldSubmitted: (_) => _save(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Batal'),
      ),
      ElevatedButton(onPressed: _save, child: const Text('Simpan Password')),
    ],
  );
}
