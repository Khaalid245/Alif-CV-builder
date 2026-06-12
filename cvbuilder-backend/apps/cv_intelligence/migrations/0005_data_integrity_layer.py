"""
Migration: Add is_latest + diff_from_previous to CVAnalysis,
and diff_from_previous to CVAnalysisHistory.

Recommendation 3 — Structured Data Integrity Layer.

Key contract:
  - CVAnalysis.is_latest=True  → the one canonical "current" record
  - CVAnalysis.is_latest=False → retained historical snapshot (never deleted again)
  - diff_from_previous         → structured diff vs the preceding analysis
"""
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('cv_intelligence', '0004_add_role_intelligence_config'),
    ]

    operations = [
        # ── CVAnalysis: is_latest ──────────────────────────────────────────────
        migrations.AddField(
            model_name='cvanalysis',
            name='is_latest',
            field=models.BooleanField(
                default=True,
                db_index=True,
                help_text='True only for the most recent analysis. Previous records are retained.',
            ),
        ),

        # ── CVAnalysis: diff_from_previous ────────────────────────────────────
        migrations.AddField(
            model_name='cvanalysis',
            name='diff_from_previous',
            field=models.JSONField(
                default=dict,
                help_text='Structured diff between this and the immediately preceding analysis',
            ),
        ),

        # ── CVAnalysisHistory: diff_from_previous ─────────────────────────────
        migrations.AddField(
            model_name='cvanalysishistory',
            name='diff_from_previous',
            field=models.JSONField(
                default=dict,
                help_text='Diff vs the immediately preceding history snapshot',
            ),
        ),

        # ── Composite index on (user, is_latest) for fast current-record lookup
        migrations.AddIndex(
            model_name='cvanalysis',
            index=models.Index(
                fields=['user', 'is_latest'],
                name='cv_analyses_user_is_latest_idx',
            ),
        ),
    ]
