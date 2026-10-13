import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_strings.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../utils/result.dart';
import '../../utils/validators.dart';

class ProjectRevisionScreen extends StatefulWidget {
  final String projectId;
  const ProjectRevisionScreen({super.key, required this.projectId});
  @override
  State<ProjectRevisionScreen> createState() => _ProjectRevisionScreenState();
}

class _ProjectRevisionScreenState extends State<ProjectRevisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _demo = TextEditingController();
  final _github = TextEditingController();
  final _team = TextEditingController();
  final _tech = TextEditingController();
  String _category = AppStrings.projectCategories.first;

  @override
  void initState() {
    super.initState();
    final project = context
        .read<ProjectProvider>()
        .allProjects
        .where((project) => project.id == widget.projectId)
        .firstOrNull;
    if (project != null) {
      _title.text = project.title;
      _description.text = project.description;
      _demo.text = project.linkAkses;
      _github.text = project.linkGithub;
      _team.text = project.teamMembers.join(', ');
      _tech.text = project.teknologi.join(', ');
      if (AppStrings.projectCategories.contains(project.category)) {
        _category = project.category;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _description,
      _demo,
      _github,
      _team,
      _tech,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final result = context.read<ProjectProvider>().resubmitProject(
      projectId: widget.projectId,
      title: _title.text,
      description: _description.text,
      category: _category,
      linkAkses: _demo.text,
      linkGithub: _github.text,
      teamMembers: _team.text.split(','),
      teknologi: _tech.text.split(','),
    );
    if (result is Failure<ProjectModel>) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Revisi dikirim. Menunggu review guru.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final project = context
        .watch<ProjectProvider>()
        .allProjects
        .where((project) => project.id == widget.projectId)
        .firstOrNull;
    final canRevise =
        user != null &&
        user.role == 'Siswa' &&
        project != null &&
        project.authorId == user.id &&
        project.isRejected &&
        !project.isValidated;
    if (!canRevise) {
      return Scaffold(
        appBar: AppBar(title: const Text('Revisi Karya')),
        body: const Center(child: Text('Karya ini tidak dapat direvisi.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Revisi Karya')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Perbaiki karya sesuai catatan guru, lalu kirim untuk ditinjau ulang.',
            ),
            if (project.guruFeedback.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Catatan guru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(project.guruFeedback),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Nama Karya'),
              validator: (value) =>
                  Validators.validateRequired(value, 'Nama karya'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              validator: (value) =>
                  Validators.validateRequired(value, 'Deskripsi'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: AppStrings.projectCategories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _demo,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Link Demo (opsional)',
              ),
              validator: Validators.validateOptionalUrl,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _github,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Link GitHub (opsional)',
              ),
              validator: Validators.validateOptionalUrl,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tech,
              decoration: const InputDecoration(
                labelText: 'Teknologi',
                helperText: 'Pisahkan dengan koma',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _team,
              decoration: const InputDecoration(
                labelText: 'Tim Pengembang',
                helperText: 'Pisahkan dengan koma',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Kirim Revisi'),
            ),
          ],
        ),
      ),
    );
  }
}
