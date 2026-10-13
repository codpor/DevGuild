import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme.dart';

class ProjectStatusBadge extends StatelessWidget {
  final ProjectModel project;
  const ProjectStatusBadge({super.key, required this.project});

  static String label(ProjectModel project) {
    if (project.isRejected) return 'Ditolak';
    if (project.isValidated) return 'Disetujui';
    return 'Menunggu Review';
  }

  @override
  Widget build(BuildContext context) {
    final color = project.isRejected
        ? AppTheme.error
        : project.isValidated
        ? AppTheme.success
        : AppTheme.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label(project),
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
