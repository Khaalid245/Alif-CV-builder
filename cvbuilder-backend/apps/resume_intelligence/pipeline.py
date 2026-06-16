"""
Pipeline orchestrator.
"""
from typing import List
from .context import ResumeContext
from .stages.normalize import NormalizeStage
from .stages.classify import ClassifyStage

class ResumePipeline:
    """
    Executes stages sequentially on a ResumeContext.
    Follows the Pipeline Design Pattern.
    """
    def __init__(self):
        # Configured Pipeline Stages
        self.stages = [
            NormalizeStage(),
            ClassifyStage(),
        ]
        
    def execute(self, context: ResumeContext) -> ResumeContext:
        """
        Runs the context through all configured stages.
        """
        context.add_log("Pipeline execution started")
        for stage in self.stages:
            context.add_log(f"Executing stage: {stage.__class__.__name__}")
            context = stage.process(context)
            
            # If critical errors were added, we could optionally halt.
            # For now, let it run through all stages.
            
        context.add_log("Pipeline execution completed")
        return context
