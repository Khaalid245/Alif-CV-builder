import '../../cv/data/models/cv_models.dart';
import '../data/models/cv_intelligence_models.dart';

class LocalHeuristicsEngine {
  static const List<String> _actionVerbs = [
    'architected', 'spearheaded', 'optimized', 'developed', 'managed',
    'led', 'created', 'designed', 'implemented', 'improved', 'increased',
    'reduced', 'delivered', 'launched', 'negotiated', 'resolved', 'transformed',
    'mentored', 'orchestrated', 'pioneered', 'streamlined', 'integrated'
  ];

  /// Performs a fast, local analysis of the CV profile.
  CVAnalysisModel analyzeCompleteness(CVProfileModel profile) {
    List<RecommendationModel> recommendations = [];
    double totalScore = 100.0;
    
    // 1. Profile Summary Check
    if (profile.summary == null || profile.summary!.length < 50) {
      totalScore -= 10;
      recommendations.add(RecommendationModel(
        id: 'local_summary_short',
        title: 'Expand your Summary',
        description: 'Your summary is too short. Add at least 3-4 sentences highlighting your core value proposition.',
        category: 'critical',
        priority: 'high',
        actionText: 'Edit Summary',
        isImplemented: false,
        createdAt: DateTime.now(),
      ));
    }

    // 2. Experience Action Verbs Check
    bool hasActionVerbs = false;
    for (var exp in profile.experiences) {
      final descLower = exp.description?.toLowerCase() ?? '';
      for (var verb in _actionVerbs) {
        if (descLower.contains(verb)) {
          hasActionVerbs = true;
          break;
        }
      }
    }
    
    if (profile.experiences.isNotEmpty && !hasActionVerbs) {
      totalScore -= 15;
      recommendations.add(RecommendationModel(
        id: 'local_action_verbs',
        title: 'Use Action Verbs',
        description: 'Your experience descriptions are passive. Use strong action verbs like "Spearheaded", "Optimized", or "Delivered".',
        category: 'important',
        priority: 'high',
        actionText: 'Edit Experience',
        isImplemented: false,
        createdAt: DateTime.now(),
      ));
    }

    // 3. Skills Count Check
    if (profile.skills.length < 5) {
      totalScore -= 10;
      recommendations.add(RecommendationModel(
        id: 'local_skills_count',
        title: 'Add More Skills',
        description: 'You have fewer than 5 skills listed. Aim for 8-12 relevant skills to pass ATS filters.',
        category: 'suggestions',
        priority: 'medium',
        actionText: 'Add Skills',
        isImplemented: false,
        createdAt: DateTime.now(),
      ));
    }

    // 4. Contact Info Check
    if (profile.phone == null || profile.phone!.isEmpty) {
      totalScore -= 5;
      recommendations.add(RecommendationModel(
        id: 'local_contact_phone',
        title: 'Missing Phone Number',
        description: 'Recruiters often prefer calling. Make sure your phone number is included.',
        category: 'critical',
        priority: 'high',
        actionText: 'Edit Contact Info',
        isImplemented: false,
        createdAt: DateTime.now(),
      ));
    }

    return CVAnalysisModel(
      id: 'local_analysis_${DateTime.now().millisecondsSinceEpoch}',
      cvProfileId: profile.id,
      userId: profile.userId,
      overallScore: totalScore.clamp(0.0, 100.0),
      sectionScores: {
        'profile': SectionScoreModel(
          score: (profile.summary?.isNotEmpty ?? false) ? 100.0 : 0.0,
          maxScore: 100.0,
          weight: 1.0,
          status: 'good',
          strengths: [], weaknesses: [], suggestions: [], details: {}
        ),
      },
      recommendations: recommendations,
      submissionReadiness: SubmissionReadinessModel(
        isReady: totalScore >= 70,
        readinessScore: totalScore,
        readyAspects: [],
        missingAspects: recommendations.map((e) => e.title).toList(),
        improvementAreas: [],
        overallAssessment: totalScore >= 70 ? 'Good' : 'Needs Improvement',
        details: {},
      ),
      benchmarkingData: null,
      metadata: {'is_local_fallback': true},
      analyzedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
