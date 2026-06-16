import unittest
from apps.resume_intelligence.context import ResumeContext

class TestResumeContext(unittest.TestCase):
    def test_context_initialization(self):
        ctx = ResumeContext()
        self.assertEqual(ctx.resume_data, {})
        self.assertEqual(ctx.normalized_data, {})
        self.assertEqual(ctx.warnings, [])
        self.assertEqual(ctx.errors, [])
        self.assertEqual(ctx.logs, [])
        
    def test_add_log(self):
        ctx = ResumeContext()
        ctx.add_log("Test log")
        self.assertIn("Test log", ctx.logs)
        
    def test_add_warning(self):
        ctx = ResumeContext()
        ctx.add_warning("Test warning", section="skills")
        self.assertEqual(ctx.warnings[0], {'section': 'skills', 'message': 'Test warning'})
        
    def test_add_error(self):
        ctx = ResumeContext()
        ctx.add_error("Test error")
        self.assertEqual(ctx.errors[0], {'section': 'general', 'message': 'Test error'})
        
    def test_context_preserves_resume_data(self):
        data = {'name': 'John Doe'}
        ctx = ResumeContext(resume_data=data)
        self.assertEqual(ctx.resume_data['name'], 'John Doe')
