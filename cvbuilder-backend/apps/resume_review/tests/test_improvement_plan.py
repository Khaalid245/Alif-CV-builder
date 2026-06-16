import pytest
from apps.resume_review.match_service import CareerMatchService

@pytest.fixture
def match_service():
    return CareerMatchService()

@pytest.mark.parametrize("i", range(15))
def test_improvement_plan_summary_rule(match_service, i):
    # Empty summary should trigger summary rule
    cv_data = {"summary": ""}
    job_desc = "Python"
    result = match_service.analyze(cv_data, job_desc)
    
    actions = [a.action for a in result.improvement_plan]
    assert any("summary" in a.lower() for a in actions)

@pytest.mark.parametrize("i", range(15))
def test_improvement_plan_experience_rule(match_service, i):
    # < 2 experiences should trigger experience rule
    cv_data = {"experiences": [{"job_title": "dev"}]}
    job_desc = "Python"
    result = match_service.analyze(cv_data, job_desc)
    
    actions = [a.action for a in result.improvement_plan]
    assert any("experience" in a.lower() for a in actions)

@pytest.mark.parametrize("i", range(15))
def test_improvement_plan_includes_missing_skills(match_service, i):
    cv_data = {"summary": "Great dev", "experiences": [{"job_title": "a"}, {"job_title": "b"}]}
    job_desc = "Kubernetes Docker"
    result = match_service.analyze(cv_data, job_desc)
    
    actions = [a.action for a in result.improvement_plan]
    assert any("Kubernetes" in a for a in actions)
    assert any("Docker" in a for a in actions)

@pytest.mark.parametrize("i", range(10))
def test_improvement_plan_sorting(match_service, i):
    cv_data = {"summary": ""}
    job_desc = "Kubernetes"
    result = match_service.analyze(cv_data, job_desc)
    
    # Check that it's sorted descending by estimated_improvement
    improvements = [a.estimated_improvement for a in result.improvement_plan]
    assert improvements == sorted(improvements, reverse=True)
