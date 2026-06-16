import pytest
from apps.resume_review.match_service import CareerMatchService

@pytest.fixture
def match_service():
    return CareerMatchService()

@pytest.mark.parametrize("i", range(15))
def test_missing_skills_importance_logic(match_service, i):
    # Short word -> Low, Medium word -> Medium, Long word -> High
    job_desc = "C++ Java Kubernetes"
    result = match_service.analyze({}, job_desc)
    
    missing = {s.name.lower(): s for s in result.missing_skills}
    assert "c++" in missing
    assert missing["c++"].importance == "Low"
    assert missing["c++"].estimated_improvement == 2
    
    assert "java" in missing
    assert missing["java"].importance == "Medium"
    assert missing["java"].estimated_improvement == 3
    
    assert "kubernetes" in missing
    assert missing["kubernetes"].importance == "High"
    assert missing["kubernetes"].estimated_improvement == 5

@pytest.mark.parametrize("i", range(5))
def test_missing_skills_empty(match_service, i):
    job_desc = "Python"
    result = match_service.analyze({"skills": [{"name": "Python"}]}, job_desc)
    assert len(result.missing_skills) == 0
