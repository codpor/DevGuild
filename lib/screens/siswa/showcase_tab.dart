import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme.dart';

class ShowcaseTab extends StatelessWidget {
  const ShowcaseTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final projects = provider.validatedProjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Showcase Karya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddProjectDialog(context),
          ),
        ],
      ),
      body: projects.isEmpty
          ? const Center(child: Text('Belum ada karya yang divalidasi'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemCount: projects.length,
              itemBuilder: (context, i) => _ProjectCard(project: projects[i]),
            ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final linkAksesC = TextEditingController();
    final linkGithubC = TextEditingController();
    final teamC = TextEditingController();
    final techC = TextEditingController();
    String category = 'Web App';
    final provider = Provider.of<AppProvider>(context, listen: false);
    final user = provider.currentUser!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Upload Karya',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Karya akan direview oleh guru sebelum ditampilkan.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                // Mock image picker
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 40, color: AppTheme.primary),
                        SizedBox(height: 8),
                        Text('Tap untuk upload screenshot',
                            style: TextStyle(color: AppTheme.textSecondary)),
                        Text('(Fitur photo: perlu Firebase Storage)',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300)),
                  ),
                  items: [
                    'Web App',
                    'Web',
                    'Python',
                    'JavaScript',
                    'Mobile',
                    'Lainnya'
                  ]
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setModalState(() => category = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleC,
                  decoration: const InputDecoration(labelText: 'Nama Karya'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descC,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Deskripsi', alignLabelWithHint: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: linkAksesC,
                  decoration: const InputDecoration(
                    labelText: 'Link Akses / Demo (opsional)',
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.link, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: linkGithubC,
                  decoration: const InputDecoration(
                    labelText: 'Link Repository / GitHub (opsional)',
                    hintText: 'https://github.com/...',
                    prefixIcon: Icon(Icons.code, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: techC,
                  decoration: const InputDecoration(
                    labelText: 'Teknologi yang Digunakan',
                    hintText: 'PHP, MySQL, Bootstrap',
                    prefixIcon: Icon(Icons.build_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: teamC,
                  decoration: InputDecoration(
                    labelText: 'Tim Pengembang',
                    hintText: 'Nama1, Nama2, Nama3',
                    prefixIcon: const Icon(Icons.group_outlined, size: 20),
                    helperText:
                        'Pisahkan dengan koma. Default: ${user.name}',
                    helperStyle: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (titleC.text.isEmpty || descC.text.isEmpty) return;
                    final teamList = teamC.text.isEmpty
                        ? [user.name]
                        : teamC.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                    final techList = techC.text.isEmpty
                        ? <String>[]
                        : techC.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                    provider.addProject(ProjectModel(
                      id: 'p${DateTime.now().millisecondsSinceEpoch}',
                      authorId: user.id,
                      authorName: user.name,
                      authorKelas: user.kelas,
                      title: titleC.text,
                      description: descC.text,
                      category: category,
                      linkAkses: linkAksesC.text.trim(),
                      linkGithub: linkGithubC.text.trim(),
                      teamMembers: teamList,
                      teknologi: techList,
                      createdAt: DateTime.now(),
                    ));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Karya berhasil disubmit! Menunggu validasi guru.'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  child: const Text('Submit Karya'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Web App':
        return const Color(0xFF6C63FF);
      case 'Python':
        return const Color(0xFF3B82F6);
      case 'JavaScript':
        return const Color(0xFFF59E0B);
      case 'Mobile':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(project.category);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(project: project),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail placeholder with gradient
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      catColor,
                      catColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.code,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.7)),
                ),
              ),
            ),
            // ── Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(project.authorName,
                      maxLines: 1,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(project.category,
                            style: TextStyle(
                                color: catColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      const Icon(Icons.favorite,
                          size: 13, color: AppTheme.accent),
                      const SizedBox(width: 2),
                      Text('${project.likes}',
                          style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  PROJECT DETAIL SCREEN
// ═══════════════════════════════════════════════
class ProjectDetailScreen extends StatelessWidget {
  final ProjectModel project;
  const ProjectDetailScreen({super.key, required this.project});

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Web App':
        return const Color(0xFF6C63FF);
      case 'Python':
        return const Color(0xFF3B82F6);
      case 'JavaScript':
        return const Color(0xFFF59E0B);
      case 'Mobile':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final catColor = _categoryColor(project.category);
    // Get fresh project data from provider
    final freshProject = provider.allProjects.firstWhere(
      (p) => p.id == project.id,
      orElse: () => project,
    );
    final isLiked = provider.hasLikedProject(freshProject.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Karya')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero thumbnail
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [catColor, catColor.withValues(alpha: 0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.6)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(freshProject.category,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title + Validated badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(freshProject.title,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      if (freshProject.isValidated)
                        Container(
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  size: 14, color: AppTheme.success),
                              SizedBox(width: 4),
                              Text('Tervalidasi',
                                  style: TextStyle(
                                      color: AppTheme.success,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Like button + count
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            provider.toggleLikeProject(freshProject.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isLiked
                                ? AppTheme.accent.withValues(alpha: 0.12)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isLiked
                                    ? AppTheme.accent
                                    : Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: isLiked
                                      ? AppTheme.accent
                                      : AppTheme.textSecondary),
                              const SizedBox(width: 6),
                              Text('${freshProject.likes}',
                                  style: TextStyle(
                                      color: isLiked
                                          ? AppTheme.accent
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Description
                  const _SectionTitle(icon: Icons.description_outlined, title: 'Deskripsi'),
                  const SizedBox(height: 8),
                  Text(freshProject.description,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, height: 1.6)),
                  const SizedBox(height: 20),

                  // ── Teknologi
                  if (freshProject.teknologi.isNotEmpty) ...[
                    const _SectionTitle(
                        icon: Icons.build_outlined, title: 'Teknologi'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: freshProject.teknologi
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(t,
                                    style: TextStyle(
                                        color: catColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Link Akses
                  if (freshProject.linkAkses.isNotEmpty) ...[
                    const _SectionTitle(
                        icon: Icons.link, title: 'Link Akses / Demo'),
                    const SizedBox(height: 8),
                    _LinkCard(
                      url: freshProject.linkAkses,
                      icon: Icons.open_in_new,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Link Github
                  if (freshProject.linkGithub.isNotEmpty) ...[
                    const _SectionTitle(
                        icon: Icons.code, title: 'Repository'),
                    const SizedBox(height: 8),
                    _LinkCard(
                      url: freshProject.linkGithub,
                      icon: Icons.code,
                      color: const Color(0xFF333333),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Tim Pengembang
                  if (freshProject.teamMembers.isNotEmpty) ...[
                    const _SectionTitle(
                        icon: Icons.group_outlined, title: 'Tim Pengembang'),
                    const SizedBox(height: 8),
                    ...freshProject.teamMembers.map((member) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    AppTheme.primary.withValues(alpha: 0.15),
                                child: Text(member[0],
                                    style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Text(member,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],

                  // ── Author
                  const _SectionTitle(
                      icon: Icons.person_outline, title: 'Dibuat oleh'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          catColor.withValues(alpha: 0.06),
                          catColor.withValues(alpha: 0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: catColor.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              catColor.withValues(alpha: 0.15),
                          child: Text(freshProject.authorName[0],
                              style: TextStyle(
                                  color: catColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(freshProject.authorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(freshProject.authorKelas,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Guru feedback
                  if (freshProject.guruFeedback.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _SectionTitle(
                        icon: Icons.rate_review_outlined,
                        title: 'Catatan Guru'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.info.withValues(alpha: 0.2)),
                      ),
                      child: Text(freshProject.guruFeedback,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, height: 1.5)),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section title widget
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textPrimary),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}

// ── Link card with copy
class _LinkCard extends StatelessWidget {
  final String url;
  final IconData icon;
  final Color color;
  const _LinkCard(
      {required this.url, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(url,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link disalin ke clipboard!'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.copy, size: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
