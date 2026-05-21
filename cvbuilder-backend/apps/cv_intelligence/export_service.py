"""
CV Intelligence Analysis Export Service.
Generates professional PDF reports containing analysis results, recommendations, and benchmarking data.
"""
import base64
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

from django.conf import settings
from django.template.loader import render_to_string
from django.utils import timezone

from apps.cv_intelligence.models import CVAnalysisHistory
from apps.cv_intelligence.benchmarking_service import CVBenchmarkingService

logger = logging.getLogger(__name__)


class CVAnalysisExportService:
    """
    Service for exporting CV Intelligence analysis results to PDF.
    Generates comprehensive reports with analysis data, recommendations, and benchmarking.
    """

    def __init__(self, user):
        self.user = user
        self.benchmarking_service = CVBenchmarkingService()

    def generate_analysis_report(self) -> Dict:
        """
        Main entry point. Generates a comprehensive CV analysis PDF report.
        Returns dict with file path, URL, and metadata.
        Raises CVAnalysisExportError on any failure.
        """
        try:
            # Get latest analysis data
            analysis_data = self._fetch_analysis_data()
            if not analysis_data:
                raise CVAnalysisExportError("No CV analysis found. Please run an analysis first.")

            # Prepare context for template
            context = self._prepare_template_context(analysis_data)
            
            # Generate filename and paths
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f'cv_analysis_report_{timestamp}.pdf'
            output_dir = self._ensure_output_directory()
            filepath = output_dir / filename

            # Render HTML template
            html = self._render_template(context)
            
            # Generate PDF
            file_size = self._generate_pdf(html, filepath)
            
            # Return file information
            rel_path = str(filepath.relative_to(Path(settings.MEDIA_ROOT)))
            rel_url = self._get_relative_url(filepath)

            # SECURITY: Don't log user email, use user ID instead
            logger.info(f'Analysis report generated: {filename} for user {self.user.id}')

            return {
                'filename': filename,
                'file_path': rel_path,
                'pdf_url': rel_url,
                'file_size': file_size,
                'generated_at': timezone.now().isoformat(),
            }

        except Exception as exc:
            # SECURITY: Don't log user email, use user ID instead
            logger.exception(f'Analysis report generation failed for user {self.user.id}: {exc}')
            raise CVAnalysisExportError(f'Report generation failed: {exc}') from exc

    def _fetch_analysis_data(self) -> Optional[Dict]:
        """Fetch the latest CV analysis data for the user."""
        try:
            # Get latest analysis from history
            latest_analysis = CVAnalysisHistory.objects.filter(user=self.user).first()
            if not latest_analysis:
                return None

            # Get benchmarking data
            try:
                benchmarking_data = self.benchmarking_service.get_user_benchmarking_data(self.user)
            except Exception as e:
                # SECURITY: Don't log user email, use user ID instead
                logger.warning(f'Failed to get benchmarking data for user {self.user.id}: {e}')
                benchmarking_data = None

            return {
                'analysis': latest_analysis,
                'benchmarking': benchmarking_data,
            }

        except Exception as exc:
            # SECURITY: Don't log user email, use user ID instead
            logger.error(f'Failed to fetch analysis data for user {self.user.id}: {exc}')
            return None

    def _prepare_template_context(self, analysis_data: Dict) -> Dict:
        """Prepare the context data for the PDF template."""
        analysis = analysis_data['analysis']
        benchmarking = analysis_data.get('benchmarking')
        
        # Parse section scores
        section_scores = analysis.section_scores or {}
        
        # Parse recommendations
        recommendations = analysis.recommendations or []
        
        # Group recommendations by priority/type
        critical_recommendations = []
        important_recommendations = []
        suggestions = []
        
        for rec in recommendations:
            if isinstance(rec, dict):
                priority = rec.get('priority', 'medium').lower()
                if priority in ['critical', 'high']:
                    critical_recommendations.append(rec)
                elif priority == 'medium':
                    important_recommendations.append(rec)
                else:
                    suggestions.append(rec)
            else:
                # Handle string recommendations
                suggestions.append({'title': str(rec), 'description': ''})

        # Parse strengths and weaknesses
        strengths = analysis.strengths or []
        weaknesses = analysis.weaknesses or []

        # Prepare performance level description
        performance_descriptions = {
            'excellent': 'Your CV demonstrates excellent quality and completeness.',
            'strong': 'Your CV shows strong performance with room for minor improvements.',
            'average': 'Your CV meets basic standards but has significant improvement potential.',
            'needs_improvement': 'Your CV needs substantial improvements to meet competitive standards.',
            'poor': 'Your CV requires major improvements across multiple areas.'
        }

        context = {
            # User information
            'user_name': self.user.full_name or f'User {self.user.id}',
            'user_id': str(self.user.id),
            'generated_at': timezone.now(),
            'report_date': timezone.now().strftime('%B %d, %Y'),
            
            # Analysis metadata
            'analysis_date': analysis.created_at,
            'analysis_version': analysis.analysis_version or '1.0',
            
            # Scores
            'overall_score': float(analysis.overall_score),
            'readiness_score': float(analysis.readiness_score) if analysis.readiness_score else None,
            'readiness_grade': analysis.readiness_grade or 'N/A',
            
            # Section scores
            'section_scores': section_scores,
            'has_section_scores': bool(section_scores),
            
            # Recommendations
            'critical_recommendations': critical_recommendations,
            'important_recommendations': important_recommendations,
            'suggestions': suggestions,
            'total_recommendations': len(recommendations),
            
            # Strengths and weaknesses
            'strengths': strengths,
            'weaknesses': weaknesses,
            'has_strengths': bool(strengths),
            'has_weaknesses': bool(weaknesses),
            
            # Benchmarking data
            'benchmarking': benchmarking,
            'has_benchmarking': benchmarking is not None,
        }

        # Add benchmarking specific fields if available
        if benchmarking:
            context.update({
                'percentile_rank': benchmarking.get('percentile_rank', 0),
                'user_rank': benchmarking.get('user_rank', 0),
                'total_participants': benchmarking.get('total_participants', 0),
                'performance_level': benchmarking.get('performance_level', 'average'),
                'performance_description': performance_descriptions.get(
                    benchmarking.get('performance_level', 'average'),
                    'Performance level not available.'
                ),
                'average_score': benchmarking.get('average_score', 0),
                'top_score': benchmarking.get('top_score', 0),
                'score_gap_to_average': benchmarking.get('score_gap_to_average', 0),
                'benchmark_insights': benchmarking.get('benchmark_insights', []),
            })

        return context

    def _render_template(self, context: Dict) -> str:
        """Render the HTML template with the analysis context."""
        template_path = 'cv_intelligence/analysis_report.html'
        try:
            return render_to_string(template_path, context)
        except Exception as exc:
            raise CVAnalysisExportError(f'Template rendering failed: {exc}') from exc

    def _generate_pdf(self, html: str, output_path: Path) -> int:
        """
        Convert HTML string to PDF using WeasyPrint.
        Returns the file size in bytes.
        """
        try:
            from weasyprint import HTML, CSS
            from weasyprint.text.fonts import FontConfiguration

            # Define CSS for better PDF styling
            css_content = """
            @page {
                size: A4;
                margin: 2cm;
                @top-center {
                    content: "CV Analysis Report";
                    font-size: 10pt;
                    color: #666;
                }
                @bottom-center {
                    content: "Page " counter(page) " of " counter(pages);
                    font-size: 10pt;
                    color: #666;
                }
            }
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                line-height: 1.6;
                color: #333;
            }
            .header {
                border-bottom: 2px solid #2563eb;
                padding-bottom: 1rem;
                margin-bottom: 2rem;
            }
            .score-card {
                background: #f8fafc;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                padding: 1rem;
                margin: 1rem 0;
            }
            .section-title {
                color: #2563eb;
                border-bottom: 1px solid #e2e8f0;
                padding-bottom: 0.5rem;
                margin-bottom: 1rem;
            }
            .recommendation {
                background: #fef3c7;
                border-left: 4px solid #f59e0b;
                padding: 0.75rem;
                margin: 0.5rem 0;
            }
            .critical {
                background: #fee2e2;
                border-left-color: #ef4444;
            }
            .strength {
                background: #dcfce7;
                border-left: 4px solid #22c55e;
                padding: 0.75rem;
                margin: 0.5rem 0;
            }
            .weakness {
                background: #fef2f2;
                border-left: 4px solid #ef4444;
                padding: 0.75rem;
                margin: 0.5rem 0;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin: 1rem 0;
            }
            th, td {
                border: 1px solid #e2e8f0;
                padding: 0.75rem;
                text-align: left;
            }
            th {
                background: #f8fafc;
                font-weight: 600;
            }
            """

            font_config = FontConfiguration()
            css = CSS(string=css_content)
            
            HTML(string=html).write_pdf(
                str(output_path),
                stylesheets=[css],
                font_config=font_config,
            )
            return output_path.stat().st_size

        except ImportError:
            raise CVAnalysisExportError(
                'WeasyPrint is not installed. Run: pip install weasyprint'
            )
        except Exception as exc:
            raise CVAnalysisExportError(f'PDF conversion failed: {exc}') from exc

    def _ensure_output_directory(self) -> Path:
        """Create the user-specific output directory if it doesn't exist."""
        user_folder = str(self.user.id)
        output_dir = Path(settings.MEDIA_ROOT) / 'analysis_reports' / user_folder
        output_dir.mkdir(parents=True, exist_ok=True)
        return output_dir

    def _get_relative_url(self, filepath: Path) -> str:
        """Return the media-relative URL for the generated PDF file."""
        relative = filepath.relative_to(Path(settings.MEDIA_ROOT))
        return f'{settings.MEDIA_URL}{relative}'.replace('\\\\', '/')


class CVAnalysisExportError(Exception):
    """Raised when CV analysis export fails for any reason."""
    pass