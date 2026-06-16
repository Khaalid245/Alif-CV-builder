from dataclasses import dataclass, field
from typing import List, Dict, Optional
from rest_framework import serializers

@dataclass
class ReviewCategories:
    professional_writing: int = 100
    ats_compatibility: int = 100
    projects: int = 100
    skills: int = 100
    career_story: int = 100

@dataclass
class TopAction:
    action: str
    estimated_improvement: int

@dataclass
class ReviewResult:
    overall_score: int = 100
    status: str = "Excellent"
    confidence: str = "98%"
    based_on: List[str] = field(default_factory=lambda: [
        "Grammar Rules", "Semantic Analysis", "ATS Rules", "Structure Analysis"
    ])
    categories: ReviewCategories = field(default_factory=ReviewCategories)
    top_action: Optional[TopAction] = None
    warnings: List[str] = field(default_factory=list)
    recommendations: List[str] = field(default_factory=list)

# DRF Serializers for the API Response
class ReviewCategoriesSerializer(serializers.Serializer):
    professional_writing = serializers.IntegerField()
    ats_compatibility = serializers.IntegerField()
    projects = serializers.IntegerField()
    skills = serializers.IntegerField()
    career_story = serializers.IntegerField()

class TopActionSerializer(serializers.Serializer):
    action = serializers.CharField()
    estimated_improvement = serializers.IntegerField()

class ReviewResultSerializer(serializers.Serializer):
    overall_score = serializers.IntegerField()
    status = serializers.CharField()
    confidence = serializers.CharField()
    based_on = serializers.ListField(child=serializers.CharField())
    categories = ReviewCategoriesSerializer()
    top_action = TopActionSerializer(allow_null=True)
    warnings = serializers.ListField(child=serializers.CharField())
    recommendations = serializers.ListField(child=serializers.CharField())
