import 'package:flutter/material.dart';
import '../../../../data/models/cv_models.dart';

class AcademicTemplate extends StatelessWidget {
  final CVProfileModel profile;

  const AcademicTemplate({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              profile.fullName.isEmpty ? 'Your Name' : profile.fullName.toUpperCase(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Georgia', letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              [profile.email, profile.phone, profile.linkedin].where((e) => e.isNotEmpty).join(' • '),
              style: const TextStyle(fontSize: 10, fontFamily: 'Georgia', fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 32),
          
          if (profile.education.isNotEmpty) ...[
            _buildSectionTitle('EDUCATION'),
            ...profile.education.map((e) => _buildEducationItem(e)),
            const SizedBox(height: 20),
          ],
          
          if (profile.experiences.isNotEmpty) ...[
            _buildSectionTitle('RESEARCH & EXPERIENCE'),
            ...profile.experiences.map((e) => _buildExperienceItem(e)),
            const SizedBox(height: 20),
          ],
          
          if (profile.certifications.isNotEmpty) ...[
            _buildSectionTitle('CERTIFICATIONS & AWARDS'),
            ...profile.certifications.map((c) => _buildCertificationItem(c)),
            const SizedBox(height: 20),
          ],
          
          if (profile.skills.isNotEmpty) ...[
            _buildSectionTitle('SKILLS'),
            Text(profile.skills.map((s) => s.name).join(', '), style: const TextStyle(fontSize: 11, fontFamily: 'Georgia')),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
        const Divider(color: Colors.black87, thickness: 1, height: 12),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildEducationItem(EducationModel edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(edu.institution, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Georgia'))),
              const SizedBox(width: 8),
              Text('${edu.startYear} - ${edu.endYear ?? 'Present'}', style: const TextStyle(fontSize: 11, fontFamily: 'Georgia')),
            ],
          ),
          Text(edu.degree, style: const TextStyle(fontSize: 11, fontFamily: 'Georgia', fontStyle: FontStyle.italic)),
        ],
      ),
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
              Expanded(child: Text(exp.company, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Georgia'))),
              const SizedBox(width: 8),
              Text('${exp.startDate.year} - ${exp.endDate?.year ?? 'Present'}', style: const TextStyle(fontSize: 11, fontFamily: 'Georgia')),
            ],
          ),
          Text(exp.jobTitle, style: const TextStyle(fontSize: 11, fontFamily: 'Georgia', fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          if (exp.description.isNotEmpty)
            Text(exp.description, style: const TextStyle(fontSize: 11, fontFamily: 'Georgia', height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCertificationItem(CertificationModel cert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text('${cert.name}, ${cert.issuer}', style: const TextStyle(fontSize: 11, fontFamily: 'Georgia'))),
          const SizedBox(width: 8),
          Text(cert.issueDate.year.toString(), style: const TextStyle(fontSize: 11, fontFamily: 'Georgia')),
        ],
      ),
    );
  }
}
