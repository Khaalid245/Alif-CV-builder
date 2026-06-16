import unittest
from apps.resume_intelligence.context import ResumeContext
from apps.resume_intelligence.stages.classify import ClassifyStage

class TestClassifyStage(unittest.TestCase):
    def setUp(self):
        self.stage = ClassifyStage()

    def _test_classify(self, text, expected):
        self.assertEqual(self.stage.classify_text(text), expected)

    # Garbage
    def test_garbage_chatgpt(self): self._test_classify("chatgpt.com/share/xxx", "Garbage")
    def test_garbage_lorem(self): self._test_classify("Lorem ipsum dolor sit amet", "Garbage")
    def test_garbage_ai_model(self): self._test_classify("As an AI language model, I cannot", "Garbage")
    def test_garbage_openai(self): self._test_classify("Powered by openai", "Garbage")
    def test_garbage_placeholder(self): self._test_classify("This is a placeholder text", "Garbage")
    def test_garbage_insert(self): self._test_classify("[insert company name]", "Garbage")
    def test_garbage_draft(self): self._test_classify("Here is a draft of your resume", "Garbage")
    def test_garbage_legacy_issue_1(self): self._test_classify("nfinitytech proposes", "Garbage")
    def test_garbage_legacy_issue_2(self): self._test_classify("The team proposes a new architecture", "Garbage")

    # Languages
    def test_lang_english(self): self._test_classify("English", "Language")
    def test_lang_spanish(self): self._test_classify("Spanish", "Language")
    def test_lang_arabic(self): self._test_classify("Arabic", "Language")
    def test_lang_french_fluent(self): self._test_classify("Fluent French", "Language")
    def test_lang_mandarin_native(self): self._test_classify("Native Mandarin", "Language")
    def test_lang_hindi(self): self._test_classify("Hindi", "Language")
    def test_lang_japanese(self): self._test_classify("Japanese", "Language")

    # Certifications
    def test_cert_aws(self): self._test_classify("AWS Certified Solutions Architect", "Certification")
    def test_cert_comptia(self): self._test_classify("CompTIA Security+", "Certification")
    def test_cert_cisco(self): self._test_classify("Cisco CCNA", "Certification")
    def test_cert_coursera(self): self._test_classify("Coursera Machine Learning", "Certification")
    def test_cert_general(self): self._test_classify("Professional Scrum Master Certificate", "Certification")
    def test_cert_practitioner(self): self._test_classify("Cloud Practitioner", "Certification")

    # Awards
    def test_award_hackathon(self): self._test_classify("First Place Winner at Hackathon", "Award")
    def test_award_scholarship(self): self._test_classify("Presidential Scholarship", "Award")
    def test_award_dean(self): self._test_classify("Dean's List 2021", "Award")
    def test_award_honor(self): self._test_classify("Graduated with highest honor", "Award")
    def test_award_valedictorian(self): self._test_classify("High School Valedictorian", "Award")
    def test_award_medalist(self): self._test_classify("Gold Medalist in Math Olympiad", "Award")

    # Publications
    def test_pub_journal(self): self._test_classify("Published in Journal of Science", "Publication")
    def test_pub_doi(self): self._test_classify("Research paper DOI: 10.1000/182", "Publication")
    def test_pub_ieee(self): self._test_classify("IEEE Conference Proceedings", "Publication")
    def test_pub_arxiv(self): self._test_classify("Preprint available on arXiv", "Publication")
    def test_pub_author(self): self._test_classify("Lead author of machine learning study", "Publication")
    def test_pub_coauthor(self): self._test_classify("Co-author on quantum computing paper", "Publication")

    # Skills
    def test_skill_python(self): self._test_classify("Python", "Skill")
    def test_skill_django(self): self._test_classify("Django Framework", "Skill")
    def test_skill_soft(self): self._test_classify("Team Leadership", "Skill")
    def test_skill_docker(self): self._test_classify("Docker", "Skill")
    def test_skill_kubernetes(self): self._test_classify("Kubernetes", "Skill")
    def test_skill_data_analysis(self): self._test_classify("Data Analysis", "Skill")
    
    # Projects
    def test_proj_app(self): self._test_classify("React Native Weather App", "Project")
    def test_proj_github(self): self._test_classify("github.com/user/repo", "Project")
    def test_proj_system(self): self._test_classify("Inventory Management System", "Project")
    def test_proj_clone(self): self._test_classify("Netflix Clone", "Project")
    def test_proj_dashboard(self): self._test_classify("Analytics Dashboard", "Project")

    # Experiences
    def test_exp_developed(self): self._test_classify("Developed REST APIs using Django", "Experience")
    def test_exp_managed(self): self._test_classify("Managed a team of 5 engineers", "Experience")
    def test_exp_increased(self): self._test_classify("Increased revenue by 20%", "Experience")
    def test_exp_orchestrated(self): self._test_classify("Orchestrated the migration to AWS", "Experience")
    def test_exp_long_bullet(self): self._test_classify("Regularly participated in agile sprint planning and reviews", "Experience")
    def test_exp_verb_middle(self): self._test_classify("Successfully designed and executed a new marketing campaign", "Experience")

    # Unknowns
    def test_unk_empty(self): self._test_classify("", "Unknown")
    def test_unk_spaces(self): self._test_classify("   ", "Unknown")

    # Context Integration
    def test_analyze_skills_mixed(self):
        ctx = ResumeContext(normalized_data={
            'skills': [
                {'name': 'Python'},
                {'name': 'Developed a scalable backend'}
            ]
        })
        self.stage.process(ctx)
        classifications = ctx.metadata.get('classifications', {})
        self.assertEqual(classifications['skill_0'], 'Skill')
        self.assertEqual(classifications['skill_1'], 'Experience')
        self.assertIn('skills', ctx.metadata.get('mixed_sections', []))
        self.assertTrue(any("Experience bullet found in skills" in w['message'] for w in ctx.warnings))

    def test_analyze_experiences_mixed(self):
        ctx = ResumeContext(normalized_data={
            'experiences': [
                {'description': 'Led the development team.\nPython'}
            ]
        })
        self.stage.process(ctx)
        classifications = ctx.metadata.get('classifications', {})
        self.assertEqual(classifications['exp_0_bullet_0'], 'Experience')
        self.assertEqual(classifications['exp_0_bullet_1'], 'Skill')
        self.assertIn('experience', ctx.metadata.get('mixed_sections', []))
        self.assertTrue(any("Single skill found in experience bullets" in w['message'] for w in ctx.warnings))

    def test_analyze_garbage_blocks_pipeline(self):
        ctx = ResumeContext(normalized_data={
            'experiences': [
                {'description': 'chatgpt.com/xxxxx'}
            ]
        })
        self.stage.process(ctx)
        self.assertTrue(any("Garbage data detected" in e['message'] for e in ctx.errors))
