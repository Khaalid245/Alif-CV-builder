"""
PDF Generation Service for EduCV.
Handles all PDF generation logic — views stay clean.

Flow:
  1. Fetch all student CV data from DB
  2. Convert photo to base64 (WeasyPrint cannot use file paths)
  3. Render each HTML template with Django template engine
  4. Convert HTML → PDF using WeasyPrint
  5. Save to media/generated_cvs/{student_id}/
  6. Return file paths and sizes
"""
import base64
import logging
from datetime import datetime
from pathlib import Path

from django.conf import settings
from django.template.loader import render_to_string
from django.utils import timezone

logger = logging.getLogger(__name__)


class CVGenerationService:
    """
    Orchestrates generation of all 3 CV PDFs for a student.
    Each method has a single responsibility.
    All errors are caught, logged, and re-raised as clean exceptions.
    """

    TEMPLATES = ['classic', 'modern', 'academic']

    def __init__(self, student):
        self.student = student

    # ── Public Interface ───────────────────────────────────────────────────────

    def generate_all(self) -> list:
        """
        Main entry point. Generates all 3 PDFs.
        Returns a list of dicts with template name, file path, and file size.
        Raises CVGenerationError on any failure.
        """
        self._validate_minimum_data()
        context = self._fetch_student_data()
        output_dir = self._ensure_output_directory()

        results = []
        generated_files = []
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')  # shared across all 3

        try:
            for template_name in self.TEMPLATES:
                filename  = f'{template_name}_{timestamp}.pdf'
                filepath  = output_dir / filename

                html    = self._render_template(template_name, context)
                size    = self._generate_pdf(html, filepath)
                rel_url = self._get_relative_url(filepath)

                results.append({
                    'template':  template_name,
                    'file_path': str(filepath),
                    'pdf_url':   rel_url,
                    'file_size': size,
                })
                generated_files.append(filepath)
                logger.info('PDF generated: %s for student %s', filename, self.student.email)

        except Exception as exc:
            # Clean up any partially generated files before raising
            self._cleanup_files(generated_files)
            logger.exception('PDF generation failed for student %s: %s', self.student.email, exc)
            raise CVGenerationError(f'PDF generation failed: {exc}') from exc

        return results

    # ── Validation ─────────────────────────────────────────────────────────────

    def _validate_minimum_data(self):
        """
        Ensures the student has the minimum required data before generating.
        Raises CVGenerationError with a clear message if not.
        """
        errors = []

        if not self.student.full_name:
            errors.append('Full name is required.')

        try:
            cv = self.student.cv_profile
        except Exception:
            errors.append('CV profile not found. Please fill in your CV details first.')
            raise CVGenerationError(' '.join(errors))

        if not cv.educations.exists():
            errors.append('At least one education entry is required.')

        if errors:
            raise CVGenerationError(' '.join(errors))

    # ── Data Fetching ──────────────────────────────────────────────────────────

    def _fetch_student_data(self) -> dict:
        """
        Fetches all CV data and returns it as a flat context dict
        ready to be passed into Django templates.
        """
        cv = self.student.cv_profile

        # Fetch skills once and filter in Python — avoids 3 separate DB queries
        all_skills = list(cv.skills.all().order_by('order', 'category', 'name'))

        return {
            'full_name':  self.student.full_name,
            'email':      self.student.email,
            'student_id': self.student.student_id,
            'phone':     cv.phone,
            'address':   cv.address,
            'city':      cv.city,
            'country':   cv.country,
            'summary':   cv.summary,
            'linkedin':  cv.linkedin,
            'github':    cv.github,
            'portfolio': cv.portfolio,
            'photo_base64': self._photo_to_base64(cv.photo),
            'initials': self._get_initials(self.student.full_name),
            'educations':     list(cv.educations.all().order_by('order', '-start_year')),
            'experiences':    list(cv.experiences.all().order_by('order', '-start_date')),
            'skills':         all_skills,
            'languages':      list(cv.languages.all().order_by('language')),
            'projects':       list(cv.projects.all().order_by('order', '-start_date')),
            'certifications': list(cv.certifications.all().order_by('-issue_date')),
            # Grouped skills filtered in Python — no extra DB queries
            'technical_skills': [s for s in all_skills if s.category == 'technical'],
            'soft_skills':      [s for s in all_skills if s.category == 'soft'],
            'other_skills':     [s for s in all_skills if s.category not in ('technical', 'soft')],
            'generated_at': timezone.now(),
        }

    # ── Template Rendering ─────────────────────────────────────────────────────

    def _render_template(self, template_name: str, context: dict) -> str:
        """
        Renders the HTML template with the student context.
        Uses Django's template engine for {% if %}, {% for %}, {{ }} support.
        """
        template_path = f'cv_templates/{template_name}.html'
        try:
            return render_to_string(template_path, context)
        except Exception as exc:
            raise CVGenerationError(f'Template rendering failed for {template_name}: {exc}') from exc

    # ── PDF Generation ─────────────────────────────────────────────────────────

    def _generate_pdf(self, html: str, output_path: Path) -> int:
        """
        Converts HTML string to PDF using WeasyPrint.
        Returns the file size in bytes.
        WeasyPrint is imported here to avoid import errors if not installed.
        """
        try:
            from weasyprint import HTML, CSS
            from weasyprint.text.fonts import FontConfiguration

            font_config = FontConfiguration()
            HTML(string=html).write_pdf(
                str(output_path),
                font_config=font_config,
            )
            return output_path.stat().st_size

        except ImportError:
            raise CVGenerationError(
                'WeasyPrint is not installed. Run: pip install weasyprint'
            )
        except Exception as exc:
            raise CVGenerationError(f'WeasyPrint PDF conversion failed: {exc}') from exc

    # ── File Management ────────────────────────────────────────────────────────

    def _ensure_output_directory(self) -> Path:
        """
        Creates the student-specific output directory if it doesn't exist.
        Path: media/generated_cvs/{student_id}/
        """
        student_folder = str(self.student.id)
        output_dir = Path(settings.MEDIA_ROOT) / 'generated_cvs' / student_folder
        output_dir.mkdir(parents=True, exist_ok=True)
        return output_dir

    def _get_relative_url(self, filepath: Path) -> str:
        """Returns the media-relative URL for a generated PDF file."""
        relative = filepath.relative_to(Path(settings.MEDIA_ROOT))
        return f'{settings.MEDIA_URL}{relative}'.replace('\\', '/')

    def _cleanup_files(self, files: list):
        """Removes partially generated files on failure — no orphaned files."""
        for f in files:
            try:
                if Path(f).exists():
                    Path(f).unlink()
                    logger.info('Cleaned up partial file: %s', f)
            except Exception as cleanup_exc:
                logger.warning('Could not clean up file %s: %s', f, cleanup_exc)

    # ── Helpers ────────────────────────────────────────────────────────────────

    def _photo_to_base64(self, photo_field) -> str | None:
        """
        Converts a student's profile photo to a base64 data URI.
        WeasyPrint cannot resolve Django media file:// paths,
        so photos must be embedded as base64 data URIs.
        Returns None if no photo is set.
        """
        if not photo_field:
            return None
        try:
            photo_path = Path(settings.MEDIA_ROOT) / str(photo_field)
            if not photo_path.exists():
                return None
            with open(photo_path, 'rb') as f:
                encoded = base64.b64encode(f.read()).decode('utf-8')
            ext = photo_path.suffix.lower().lstrip('.')
            mime = 'jpeg' if ext in ('jpg', 'jpeg') else ext
            return f'data:image/{mime};base64,{encoded}'
        except Exception as exc:
            logger.warning('Could not encode photo for student %s: %s', self.student.email, exc)
            return None

    @staticmethod
    def _get_initials(full_name: str) -> str:
        """Returns up to 2 initials from a full name for the avatar fallback."""
        parts = full_name.strip().split()
        if len(parts) >= 2:
            return f'{parts[0][0]}{parts[-1][0]}'.upper()
        return full_name[0].upper() if full_name else 'S'


class CVGenerationError(Exception):
    """Raised when CV generation fails for any reason."""
    pass
