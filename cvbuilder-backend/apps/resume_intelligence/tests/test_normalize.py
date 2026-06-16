import unittest
from apps.resume_intelligence.context import ResumeContext
from apps.resume_intelligence.stages.normalize import NormalizeStage

class TestNormalizeStage(unittest.TestCase):
    def setUp(self):
        self.stage = NormalizeStage()
        self.ctx = ResumeContext()

    def test_whitespace_cleanup(self):
        self.ctx.resume_data = {'summary': 'This   is  a test'}
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['summary'], 'This is a test')
        
    def test_capitalization_city(self):
        self.ctx.resume_data = {'city': 'london'}
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['city'], 'London')
        
    def test_capitalization_job_title(self):
        self.ctx.resume_data = {'job_title': 'software engineer'}
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['job_title'], 'Software Engineer')
        
    def test_capitalization_exceptions(self):
        self.ctx.resume_data = {'degree': 'bachelor of science'}
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['degree'], 'B.Sc.')
        
    def test_capitalization_preserves_acronyms(self):
        self.ctx.resume_data = {'company': 'IBM corporation'}
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['company'], 'IBM Corporation')
        
    def test_degree_normalization(self):
        degrees = ['bsc', 'b.s.', 'bs', 'bachelor of science']
        for d in degrees:
            ctx = ResumeContext(resume_data={'degree': d})
            res = self.stage.process(ctx)
            self.assertEqual(res.normalized_data['degree'], 'B.Sc.')
            
    def test_location_normalization(self):
        locations = ['mogadisho', 'mogadishu']
        for loc in locations:
            ctx = ResumeContext(resume_data={'location': loc})
            res = self.stage.process(ctx)
            self.assertEqual(res.normalized_data['location'], 'Mogadishu, Somalia')
            
    def test_typo_correction(self):
        self.ctx.resume_data = {'field_of_study': 'Computer sceince'}
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['field_of_study'], 'Computer Science')
        
    def test_typo_preserves_punctuation(self):
        self.ctx.resume_data = {'summary': 'I studied computer sceince, and business.'}
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['summary'], 'I studied computer Science, and business.')
        
    def test_list_normalization(self):
        self.ctx.resume_data = {'skills': [{'name': 'python'}, {'name': 'java'}]}
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['skills'][0]['name'], 'Python')
        self.assertEqual(res.normalized_data['skills'][1]['name'], 'Java')
        
    def test_multiline_description(self):
        self.ctx.resume_data = {
            'description': 'Developed API.\n  Fixed bugs in   production.\n'
        }
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['description'], 'Developed API.\nFixed bugs in production.')

    def test_dict_recursion(self):
        self.ctx.resume_data = {
            'education': {
                'institution': 'harvard university',
                'location': 'sf'
            }
        }
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['education']['institution'], 'Harvard University')
        self.assertEqual(res.normalized_data['education']['location'], 'San Francisco, CA')

    def test_hyphenated_words(self):
        self.ctx.resume_data = {'job_title': 'full-stack developer'}
        res = self.stage.process(self.ctx)
        self.assertEqual(res.normalized_data['job_title'], 'Full-Stack Developer')
