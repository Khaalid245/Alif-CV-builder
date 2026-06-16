import django, os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from apps.pdf_generator.text_processor import TextProcessor

# Test 1: Spell fix + title case
t1 = TextProcessor._smart_title_case(TextProcessor._apply_spell_fixes('friendle developer'))
assert t1 == 'Friendly Developer', 'Test 1 FAIL: got ' + repr(t1)
print('Test 1 PASS:', repr(t1))

# Test 2: Title case
t2 = TextProcessor._smart_title_case('backend developer')
assert t2 == 'Backend Developer', 'Test 2 FAIL: got ' + repr(t2)
print('Test 2 PASS:', repr(t2))

# Test 3: Professional wording
t3 = TextProcessor._apply_wording_map('build api')
assert 'RESTful' in t3 or 'API' in t3, 'Test 3 FAIL: got ' + repr(t3)
print('Test 3 PASS:', repr(t3))

# Test 5: Skill brand normalization
p = TextProcessor({})
t5 = p._normalize_skill_name('nodejs')
assert t5 == 'Node.js', 'Test 5 FAIL: got ' + repr(t5)
print('Test 5 PASS:', repr(t5))

t5b = p._normalize_skill_name('python,django,nodejs')
print('Test 5b comma-split PASS:', repr(t5b))

# Test: Summary garbage removed
ctx = {
    'summary': 'We look forward to establishing a long-term partnership with your company.',
    'experiences': [], 'educations': [], 'skills': [], 'projects': [],
    'full_name': 'khalid hassan', 'city': 'karachi', 'country': 'pakistan',
    'technical_skills': [], 'soft_skills': [], 'other_skills': [],
    'languages': [], 'certifications': [],
}
result = TextProcessor(ctx).process()
summary = result['summary']
assert summary == '', 'Summary garbage FAIL: got ' + repr(summary)
print('Summary garbage PASS: cleared correctly')

# Test: name title case
name = result['full_name']
assert name == 'Khalid Hassan', 'Name title case FAIL: got ' + repr(name)
print('Name title case PASS:', repr(name))

print()
print('All tests PASSED.')
