import os, sys
os.environ['HF_HUB_DISABLE_SYMLINKS_WARNING'] = '1'

from apps.cv_intelligence.ai.ml_scoring_service import MLScoringService

service = MLScoringService.get_instance()
service.warm_up()

print("Model available:", service.is_available)
print("Model name:", service.MODEL_NAME)
print()

tests = [
    ("Architected microservices on AWS, reducing latency by 40%", "Software Engineer", ["architected","AWS","microservices"], "HIGH"),
    ("Responsible for some code stuff", "Software Engineer", ["architected","AWS","microservices"], "LOW"),
    ("Led product roadmap and stakeholder alignment across 3 teams", "Product Manager", ["roadmap","stakeholder","strategy"], "HIGH"),
    ("Helped with meetings", "Product Manager", ["roadmap","stakeholder","strategy"], "LOW"),
]

print("--- Role Match Tests ---")
all_pass = True
for bullet, role, kws, expected in tests:
    r = service.compute_role_match(bullet, role, kws)
    score = r["score"]
    if expected == "HIGH":
        passed = score >= 40
    else:
        passed = score <= 60
    status = "PASS" if passed else "FAIL"
    if not passed:
        all_pass = False
    print(f"  [{status}] score={score:3d}/100 sim={r['similarity']:.3f} method={r['method']}")
    print(f"         Role={role} | Expected={expected}")
    print(f"         Bullet: {bullet[:60]}")
    print()

print("--- Skill Extraction Test ---")
cv_text = "Built Python Django backend, deployed on AWS with Docker and Kubernetes"
skills = service.extract_skills_semantic(
    cv_text,
    ["Python", "Django", "AWS", "Docker", "Kubernetes", "Java", "Figma", "React"]
)
print("Text:", cv_text)
print("Skills found:", skills)
print()

print("=== RESULT:", "ALL TESTS PASSED" if all_pass else "SOME TESTS FAILED", "===")
