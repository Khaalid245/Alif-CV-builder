"""
CV models for EduCV.
All models link to CVProfile which links to the student.
Ownership is always enforced through cv__student == request.user.
"""
import uuid
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db.models import Count


class CVProfile(models.Model):
    """
    One CV profile per student — the root of all CV data.
    All other CV sections (Education, Experience, etc.) link here.
    completion_percentage is recalculated every time a section is saved.
    """
    id      = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    student = models.OneToOneField(
        'users.User',
        on_delete=models.CASCADE,
        related_name='cv_profile',
    )

    # ── Contact & Personal Info ───────────────────────────────────────────────
    phone     = models.CharField(max_length=20, blank=True, default='')
    address   = models.CharField(max_length=255, blank=True, default='')
    city      = models.CharField(max_length=100, blank=True, default='')
    country   = models.CharField(max_length=100, blank=True, default='')
    summary   = models.TextField(blank=True, default='', max_length=1000)

    # ── Online Presence ───────────────────────────────────────────────────────
    linkedin  = models.URLField(blank=True, default='')
    github    = models.URLField(blank=True, default='')
    portfolio = models.URLField(blank=True, default='')

    # ── Photo ─────────────────────────────────────────────────────────────────
    photo = models.ImageField(upload_to='profile_photos/', null=True, blank=True)

    # ── Completion ────────────────────────────────────────────────────────────
    completion_percentage = models.IntegerField(default=0)

    # ── Timestamps ────────────────────────────────────────────────────────────
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'cv_profiles'

    def __str__(self):
        return f'CV — {self.student.email}'

    def calculate_completion(self) -> int:
        """
        Calculates CV completion percentage using a single annotated query
        instead of 7 separate database hits.

        Weights:
          Profile basics (phone, city, country, summary) = 20%
          Education (at least 1 entry)                   = 20%
          Experience (at least 1 entry)                  = 20%
          Skills (at least 2 entries)                    = 15%
          Languages (at least 1 entry)                   = 10%
          Projects (at least 1 entry)                    = 10%
          Certifications (at least 1 entry)              =  5%
        """
        # Single query with all counts annotated
        counts = CVProfile.objects.filter(pk=self.pk).aggregate(
            edu_count=Count('educations',     distinct=True),
            exp_count=Count('experiences',    distinct=True),
            ski_count=Count('skills',         distinct=True),
            lan_count=Count('languages',      distinct=True),
            pro_count=Count('projects',       distinct=True),
            cer_count=Count('certifications', distinct=True),
        )

        score = 0

        # Profile basics — 5 points each
        if self.phone:   score += 5
        if self.city:    score += 5
        if self.country: score += 5
        if self.summary: score += 5

        # Sections
        if counts['edu_count'] >= 1: score += 20
        if counts['exp_count'] >= 1: score += 20
        if counts['ski_count'] >= 2: score += 15
        if counts['lan_count'] >= 1: score += 10
        if counts['pro_count'] >= 1: score += 10
        if counts['cer_count'] >= 1: score +=  5

        return min(score, 100)

    def update_completion(self):
        """Recalculates and saves the completion percentage."""
        self.completion_percentage = self.calculate_completion()
        self.save(update_fields=['completion_percentage', 'updated_at'])


class Education(models.Model):
    """University degrees, diplomas, and academic qualifications."""
    id             = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    cv             = models.ForeignKey(CVProfile, on_delete=models.CASCADE, related_name='educations')
    degree         = models.CharField(max_length=255)
    field_of_study = models.CharField(max_length=255)
    institution    = models.CharField(max_length=255)
    start_year     = models.IntegerField(validators=[MinValueValidator(1950), MaxValueValidator(2100)])
    end_year       = models.IntegerField(
        null=True, blank=True,
        validators=[MinValueValidator(1950), MaxValueValidator(2100)],
    )
    is_current  = models.BooleanField(default=False)
    gpa         = models.DecimalField(max_digits=4, decimal_places=2, null=True, blank=True)
    description = models.TextField(blank=True, default='', max_length=1000)
    order       = models.IntegerField(default=0)

    class Meta:
        db_table = 'cv_educations'
        ordering = ['order', '-start_year']

    def __str__(self):
        return f'{self.degree} — {self.institution}'


class Experience(models.Model):
    """Work experience, internships, and part-time jobs."""
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    cv         = models.ForeignKey(CVProfile, on_delete=models.CASCADE, related_name='experiences')
    job_title  = models.CharField(max_length=255)
    company    = models.CharField(max_length=255)
    location   = models.CharField(max_length=255, blank=True, default='')
    start_date = models.DateField()
    end_date   = models.DateField(null=True, blank=True)
    is_current = models.BooleanField(default=False)
    description = models.TextField(blank=True, default='', max_length=600)
    order       = models.IntegerField(default=0)

    class Meta:
        db_table = 'cv_experiences'
        ordering = ['order', '-start_date']

    def __str__(self):
        return f'{self.job_title} at {self.company}'


class Skill(models.Model):
    """Technical and soft skills with proficiency levels."""

    class Level(models.TextChoices):
        BEGINNER     = 'beginner',     'Beginner'
        INTERMEDIATE = 'intermediate', 'Intermediate'
        ADVANCED     = 'advanced',     'Advanced'
        EXPERT       = 'expert',       'Expert'

    class Category(models.TextChoices):
        TECHNICAL = 'technical', 'Technical'
        SOFT      = 'soft',      'Soft'
        LANGUAGE  = 'language',  'Language'
        OTHER     = 'other',     'Other'

    id       = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    cv       = models.ForeignKey(CVProfile, on_delete=models.CASCADE, related_name='skills')
    name     = models.CharField(max_length=100)
    level    = models.CharField(max_length=15, choices=Level.choices, default=Level.INTERMEDIATE)
    category = models.CharField(max_length=15, choices=Category.choices, default=Category.TECHNICAL)
    order    = models.IntegerField(default=0)

    class Meta:
        db_table = 'cv_skills'
        ordering = ['order', 'category', 'name']
        # Prevent duplicate skill names within the same CV
        constraints = [
            models.UniqueConstraint(fields=['cv', 'name'], name='unique_skill_per_cv')
        ]

    def __str__(self):
        return f'{self.name} ({self.level})'


class Language(models.Model):
    """Spoken and written languages with proficiency levels."""

    class Proficiency(models.TextChoices):
        BASIC          = 'basic',          'Basic'
        CONVERSATIONAL = 'conversational', 'Conversational'
        PROFESSIONAL   = 'professional',   'Professional'
        NATIVE         = 'native',         'Native'

    id          = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    cv          = models.ForeignKey(CVProfile, on_delete=models.CASCADE, related_name='languages')
    language    = models.CharField(max_length=100)
    proficiency = models.CharField(max_length=15, choices=Proficiency.choices, default=Proficiency.CONVERSATIONAL)

    class Meta:
        db_table = 'cv_languages'
        ordering = ['language']
        # Prevent duplicate languages within the same CV
        constraints = [
            models.UniqueConstraint(fields=['cv', 'language'], name='unique_language_per_cv')
        ]

    def __str__(self):
        return f'{self.language} — {self.proficiency}'


class Project(models.Model):
    """Personal, academic, or professional projects."""
    id          = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    cv          = models.ForeignKey(CVProfile, on_delete=models.CASCADE, related_name='projects')
    title       = models.CharField(max_length=255)
    description = models.TextField(blank=True, default='', max_length=600)
    link        = models.URLField(blank=True, default='')
    start_date  = models.DateField(null=True, blank=True)
    end_date    = models.DateField(null=True, blank=True)
    order       = models.IntegerField(default=0)

    class Meta:
        db_table = 'cv_projects'
        ordering = ['order', '-start_date']

    def __str__(self):
        return self.title


class Certification(models.Model):
    """Professional certifications and courses."""
    id             = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    cv             = models.ForeignKey(CVProfile, on_delete=models.CASCADE, related_name='certifications')
    name           = models.CharField(max_length=255)
    issuer         = models.CharField(max_length=255)
    issue_date     = models.DateField()
    expiry_date    = models.DateField(null=True, blank=True)
    credential_url = models.URLField(blank=True, default='')

    class Meta:
        db_table = 'cv_certifications'
        ordering = ['-issue_date']

    def __str__(self):
        return f'{self.name} — {self.issuer}'


class GeneratedCV(models.Model):
    """
    Tracks every PDF generated by a student.
    Used for download history, analytics, and re-download links.
    """

    class Template(models.TextChoices):
        CLASSIC  = 'classic',  'Classic'
        MODERN   = 'modern',   'Modern'
        ACADEMIC = 'academic', 'Academic'

    id             = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    cv             = models.ForeignKey(
        CVProfile,
        on_delete=models.CASCADE,
        related_name='generated_cvs',
    )
    template       = models.CharField(max_length=10, choices=Template.choices)
    # Relative path from MEDIA_ROOT — never store absolute paths
    file_path      = models.CharField(max_length=500, blank=True, default='')
    file_size      = models.IntegerField(default=0, help_text='File size in bytes')
    download_count = models.IntegerField(default=0)
    generated_at   = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'cv_generated'
        ordering = ['-generated_at']
        indexes = [
            models.Index(fields=['template'],     name='idx_generatedcv_template'),
            models.Index(fields=['generated_at'], name='idx_generatedcv_generated_at'),
        ]

    def __str__(self):
        # Use cv_id to avoid an extra DB query for student email
        return f'{self.template} CV — cv:{self.cv_id}'
