import unittest
from apps.resume_intelligence.context import ResumeContext
from apps.resume_intelligence.pipeline import ResumePipeline

class TestResumePipeline(unittest.TestCase):
    def test_pipeline_execution(self):
        pipeline = ResumePipeline()
        ctx = ResumeContext(resume_data={'name': 'john doe'})
        
        result_ctx = pipeline.execute(ctx)
        
        self.assertIn("Pipeline execution started", result_ctx.logs)
        self.assertIn("Executing stage: NormalizeStage", result_ctx.logs)
        self.assertIn("Pipeline execution completed", result_ctx.logs)
        
        # Verify normalization actually happened (NormalizeStage capitalizes 'name')
        self.assertEqual(result_ctx.normalized_data['name'], 'John Doe')

    def test_pipeline_isolation(self):
        """Ensures original resume_data is never modified by the pipeline."""
        pipeline = ResumePipeline()
        original_data = {'city': 'london'}
        ctx = ResumeContext(resume_data=original_data)
        
        result_ctx = pipeline.execute(ctx)
        
        self.assertEqual(result_ctx.normalized_data['city'], 'London')
        self.assertEqual(original_data['city'], 'london')
        self.assertEqual(result_ctx.resume_data['city'], 'london')
