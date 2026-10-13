import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/local_image.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../utils/result.dart';
import '../../widgets/image_upload_field.dart';

class ProfilePhotoScreen extends StatefulWidget {
  final String userId;
  final LocalImage? initialPhoto;
  final Future<LocalImage?> Function()? pickImage;
  const ProfilePhotoScreen({
    super.key,
    required this.userId,
    this.initialPhoto,
    this.pickImage,
  });
  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  LocalImage? _photo;
  @override
  void initState() {
    super.initState();
    _photo = widget.initialPhoto;
  }

  void _save() {
    final result = context.read<AuthProvider>().updateProfilePhoto(
      _photo,
      userId: widget.userId,
    );
    if (result is Failure<UserModel>) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Foto profil diperbarui.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Foto Profil')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ImageUploadField(
          value: _photo,
          label: 'Foto Profil',
          pickImage: widget.pickImage,
          onChanged: (photo) => setState(() => _photo = photo),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _save, child: const Text('Simpan Foto')),
      ],
    ),
  );
}
