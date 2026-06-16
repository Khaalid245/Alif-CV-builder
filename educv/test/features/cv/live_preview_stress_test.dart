import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educv/features/cv/data/models/cv_models.dart';
import 'package:educv/features/cv/presentation/providers/live_cv_provider.dart';
import 'package:educv/features/cv/presentation/widgets/live_preview/cv_live_preview_widget.dart';

void main() {
  testWidgets('Live Preview Stress Test - extremely large resumes do not overflow', (WidgetTester tester) async {
    // 1. Generate an extremely large profile
    final extremelyLargeProfile = CVProfileModel(
      id: 'stress_test',
      phone: '1234567890',
      address: '123 Fake St',
      city: 'Test City',
      country: 'Test Country',
      linkedin: 'linkedin.com/in/test',
      github: 'github.com/test',
      portfolio: 'test.com',
      summary: 'This is a very long summary ' * 50,
      completionPercentage: 100,
      fullName: 'Stress Tester User With A Extremely Long Name So That It Wraps Around Multiple Lines And Pushes Layout Constraints',
      email: 'stress.tester@extremelylongdomain.com',
      studentId: 'STRESS-100',
      education: List.generate(
        15,
        (i) => EducationModel(
          id: 'edu_$i',
          degree: 'Degree $i with an extremely long title that should wrap nicely without overflowing the render flex boundary',
          fieldOfStudy: 'Field $i',
          institution: 'Institution $i with a long name',
          startYear: 2000 + i,
          isCurrent: false,
          description: 'Description ' * 20,
          order: i,
        ),
      ),
      experiences: List.generate(
        30,
        (i) => ExperienceModel(
          id: 'exp_$i',
          jobTitle: 'Job Title $i',
          company: 'Company $i',
          location: 'Location $i',
          startDate: DateTime(2000, 1, 1).add(Duration(days: 365 * i)),
          isCurrent: false,
          description: 'Achieved something great. ' * 30,
          order: i,
        ),
      ),
      skills: List.generate(
        100,
        (i) => SkillModel(
          id: 'skill_$i',
          name: 'Skill $i which is a bit long',
          level: 'Expert',
          category: 'Technical',
          order: i,
        ),
      ),
      languages: [],
      projects: List.generate(
        20,
        (i) => ProjectModel(
          id: 'proj_$i',
          title: 'Project $i',
          description: 'Did some cool stuff ' * 20,
          link: 'http://test.com',
          order: i,
        ),
      ),
      certifications: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 2. Setup ProviderScope overriding the live profile
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liveCvProfileProvider.overrideWith(() => ExtremelyLargeProfileNotifier(extremelyLargeProfile)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 1200,
              child: CVLivePreviewWidget(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 3. Verify no exceptions were thrown and the widget rendered
    expect(find.byType(CVLivePreviewWidget), findsOneWidget);
    
    // We expect the SingleChildScrollView to absorb all the height
    expect(tester.takeException(), isNull);
  });
}

class ExtremelyLargeProfileNotifier extends LiveCvProfileNotifier {
  final CVProfileModel _initial;
  ExtremelyLargeProfileNotifier(this._initial);
  
  @override
  CVProfileModel? build() {
    return _initial;
  }
}
