from django.urls import path
from .review_api import ResumeReviewView
from .match_api import CareerMatchView

urlpatterns = [
    path('analyze/', ResumeReviewView.as_view(), name='resume_review_analyze'),
    path('match/', CareerMatchView.as_view(), name='career_match'),
]
