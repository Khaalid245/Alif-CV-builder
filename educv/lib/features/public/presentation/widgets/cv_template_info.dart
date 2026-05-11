import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CVTemplateInfo {
  final String id;
  final String name;
  final String description;
  final List<String> bestFor;
  final List<String> features;
  final IconData icon;
  final bool isPopular;

  const CVTemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.bestFor,
    required this.features,
    required this.icon,
    required this.isPopular,
  });

  static final List<CVTemplateInfo> templates = [
    const CVTemplateInfo(
      id: 'classic',
      name: 'Classic',
      description:
          'A traditional two-column layout built for formal, corporate applications. Projects professionalism and structure at a glance.',
      bestFor: ['Corporate jobs', 'Government', 'Finance', 'Law'],
      features: [
        'Two-column layout with sidebar',
        'Contact info and skills in sidebar',
        'Navy blue professional header',
        'Skill level bars',
      ],
      icon: LucideIcons.columns,
      isPopular: false,
    ),
    const CVTemplateInfo(
      id: 'modern',
      name: 'Modern',
      description:
          'Clean single-column with bold blue header. Built for tech, startups, and anyone who wants to stand out in a competitive field.',
      bestFor: ['Tech companies', 'Startups', 'Internships', 'Creative roles'],
      features: [
        'Bold full-width blue header',
        'Timeline-style experience entries',
        'Skill chips instead of bars',
        'GitHub and LinkedIn links',
      ],
      icon: LucideIcons.layout,
      isPopular: true,
    ),
    const CVTemplateInfo(
      id: 'academic',
      name: 'Academic',
      description:
          'Structured centred academic format. Prioritises research, publications, and academic achievements over work experience.',
      bestFor: ['Research roles', 'Postgraduate', 'Scholarships', 'Teaching'],
      features: [
        'Centred formal header',
        'Publications section',
        'Research experience first',
        'Awards and honours section',
      ],
      icon: LucideIcons.graduationCap,
      isPopular: false,
    ),
  ];
}
