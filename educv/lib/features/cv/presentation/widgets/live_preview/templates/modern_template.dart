import 'package:flutter/material.dart';
import '../../../../data/models/cv_models.dart';

class ModernTemplate extends StatelessWidget {
  final CVProfileModel profile;

  const ModernTemplate({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName.isEmpty ? 'Your Name' : profile.fullName,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2563EB), height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [profile.email, profile.phone, profile.linkedin, profile.github, profile.portfolio].where((e) => e.isNotEmpty).join(' • '),
                      style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563)),
                    ),
                  ],
                ),
              ),
              if (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: NetworkImage(profile.photoUrl!), fit: BoxFit.cover),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (profile.summary.isNotEmpty) ...[
            _buildSectionTitle('SUMMARY'),
            Text(profile.summary, style: const TextStyle(fontSize: 11, color: Color(0xFF1F2937), height: 1.5)),
            const SizedBox(height: 16),
          ],
          if (profile.experiences.isNotEmpty) ...[
            _buildSectionTitle('EXPERIENCE'),
            ...profile.experiences.map((e) => _buildExperienceItem(e)),
            const SizedBox(height: 16),
          ],
          if (profile.education.isNotEmpty) ...[
            _buildSectionTitle('EDUCATION'),
            ...profile.education.map((e) => _buildEducationItem(e)),
            const SizedBox(height: 16),
          ],
          if (profile.projects.isNotEmpty) ...[
            _buildSectionTitle('PROJECTS'),
            ...profile.projects.map((e) => _buildProjectItem(e)),
            const SizedBox(height: 16),
          ],
          if (profile.skills.isNotEmpty) ...[
            _buildSectionTitle('SKILLS'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: profile.skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                child: Text(s.name, style: const TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), letterSpacing: 1.2)),
        Container(height: 2, width: 40, color: const Color(0xFF2563EB), margin: const EdgeInsets.only(top: 4, bottom: 12)),
      ],
    );
  }

  Widget _buildExperienceItem(ExperienceModel exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(exp.jobTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)))),
              const SizedBox(width: 8),
              Text('${exp.startDate.year} - ${exp.endDate?.year ?? 'Present'}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 2),
          Text(exp.company, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF2563EB))),
          const SizedBox(height: 4),
          if (exp.description.isNotEmpty)
            Text(exp.description, style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildEducationItem(EducationModel edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edu.degree, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                Text(edu.institution, style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563))),
              ],
            ),
          ),
          Text('${edu.startYear} - ${edu.endYear ?? 'Present'}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildProjectItem(ProjectModel proj) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(proj.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          const SizedBox(height: 4),
          Text(proj.description, style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), height: 1.4)),
        ],
      ),
    );
  }
}
