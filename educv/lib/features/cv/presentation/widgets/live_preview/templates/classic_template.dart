import 'package:flutter/material.dart';
import '../../../../data/models/cv_models.dart';

class ClassicTemplate extends StatelessWidget {
  final CVProfileModel profile;

  const ClassicTemplate({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            profile.fullName.isEmpty ? 'Your Name' : profile.fullName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.normal, fontFamily: 'Times New Roman'),
          ),
          const SizedBox(height: 8),
          Text(
            [profile.address, profile.city, profile.country].where((e) => e.isNotEmpty).join(', '),
            style: const TextStyle(fontSize: 11, fontFamily: 'Times New Roman'),
          ),
          Text(
            [profile.email, profile.phone, profile.linkedin].where((e) => e.isNotEmpty).join(' | '),
            style: const TextStyle(fontSize: 11, fontFamily: 'Times New Roman'),
          ),
          const SizedBox(height: 24),
          if (profile.summary.isNotEmpty) ...[
            _buildSectionTitle('PROFESSIONAL SUMMARY'),
            Text(profile.summary, style: const TextStyle(fontSize: 11, fontFamily: 'Times New Roman', height: 1.5)),
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
          if (profile.skills.isNotEmpty) ...[
            _buildSectionTitle('SKILLS'),
            Text(profile.skills.map((s) => s.name).join(', '), style: const TextStyle(fontSize: 11, fontFamily: 'Times New Roman')),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Times New Roman'), textAlign: TextAlign.center),
        const Divider(color: Colors.black, thickness: 1, height: 16),
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
              Expanded(child: Text('${exp.jobTitle}, ${exp.company}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Times New Roman'))),
              const SizedBox(width: 8),
              Text('${exp.startDate.year} - ${exp.endDate?.year ?? 'Present'}', style: const TextStyle(fontSize: 11, fontFamily: 'Times New Roman')),
            ],
          ),
          const SizedBox(height: 4),
          if (exp.description.isNotEmpty)
            Text(exp.description, style: const TextStyle(fontSize: 11, fontFamily: 'Times New Roman', height: 1.4)),
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
          Expanded(child: Text('${edu.degree}, ${edu.institution}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Times New Roman'))),
          const SizedBox(width: 8),
          Text('${edu.startYear} - ${edu.endYear ?? 'Present'}', style: const TextStyle(fontSize: 11, fontFamily: 'Times New Roman')),
        ],
      ),
    );
  }
}
