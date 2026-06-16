from dataclasses import dataclass, field
from typing import List, Dict, Optional
from rest_framework import serializers

@dataclass
class MissingSkill:
    name: str
    importance: str  # High, Medium, Low
    estimated_improvement: int

@dataclass
class ImprovementAction:
    action: str
    estimated_improvement: int

@dataclass
class JobFitCategories:
    technical_skills: int = 0
    communication: int = 0
    leadership: int = 0
    projects: int = 0
    education: int = 0
    experience: int = 0

@dataclass
class CareerMatchResult:
    overall_match: int = 0
    status: str = "Unknown"
    strengths: List[str] = field(default_factory=list)
    missing_skills: List[MissingSkill] = field(default_factory=list)
    present_keywords: List[str] = field(default_factory=list)
    missing_keywords: List[str] = field(default_factory=list)
    recommended_keywords: List[str] = field(default_factory=list)
    improvement_plan: List[ImprovementAction] = field(default_factory=list)
    categories: JobFitCategories = field(default_factory=JobFitCategories)

# Serializers
class MissingSkillSerializer(serializers.Serializer):
    name = serializers.CharField()
    importance = serializers.CharField()
    estimated_improvement = serializers.IntegerField()

class ImprovementActionSerializer(serializers.Serializer):
    action = serializers.CharField()
    estimated_improvement = serializers.IntegerField()

class JobFitCategoriesSerializer(serializers.Serializer):
    technical_skills = serializers.IntegerField()
    communication = serializers.IntegerField()
    leadership = serializers.IntegerField()
    projects = serializers.IntegerField()
    education = serializers.IntegerField()
    experience = serializers.IntegerField()

class CareerMatchResultSerializer(serializers.Serializer):
    overall_match = serializers.IntegerField()
    status = serializers.CharField()
    strengths = serializers.ListField(child=serializers.CharField())
    missing_skills = MissingSkillSerializer(many=True)
    present_keywords = serializers.ListField(child=serializers.CharField())
    missing_keywords = serializers.ListField(child=serializers.CharField())
    recommended_keywords = serializers.ListField(child=serializers.CharField())
    improvement_plan = ImprovementActionSerializer(many=True)
    categories = JobFitCategoriesSerializer()
