import pytest
from apps.resume_review.match_service import CareerMatchService

@pytest.fixture
def match_service():
    return CareerMatchService()

@pytest.mark.parametrize("i", range(20))
def test_keyword_extraction_from_jd(match_service, i):
    # JD has Python, Django, AWS
    # CV has Python
    job_desc = "We are looking for Python, Django, and AWS"
    cv_data = {"skills": [{"name": "Python"}]}
    
    result = match_service.analyze(cv_data, job_desc)
    assert "Python" in result.present_keywords
    assert "Django" in result.missing_keywords
    assert "Aws" in result.missing_keywords

@pytest.mark.parametrize("i", range(15))
def test_keyword_extraction_from_experiences(match_service, i):
    job_desc = "Looking for Docker and Kubernetes"
    cv_data = {
        "experiences": [
            {"job_title": "DevOps", "description": "Worked with Docker and Kubernetes"}
        ]
    }
    
    result = match_service.analyze(cv_data, job_desc)
    assert "Docker" in result.present_keywords
    assert "Kubernetes" in result.present_keywords
    assert len(result.missing_keywords) == 0

@pytest.mark.parametrize("i", range(10))
def test_recommended_keywords_limit(match_service, i):
    # KNOWN_SKILLS has a bunch, let's trigger many missing
    job_desc = "python django rest api postgresql docker aws kubernetes ci/cd redis javascript react"
    cv_data = {}
    result = match_service.analyze(cv_data, job_desc)
    
    assert len(result.recommended_keywords) <= 5
    assert len(result.missing_keywords) > 5
