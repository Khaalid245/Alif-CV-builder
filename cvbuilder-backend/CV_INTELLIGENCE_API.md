# Enhanced CV Intelligence API Documentation

## Overview

The Enhanced CV Intelligence system provides comprehensive CV content analysis with deterministic scoring algorithms. It validates CV content, scores each section from 0-100, generates actionable recommendations, and determines submission readiness.

## Key Features

✅ **Deterministic Algorithms**: No AI dependencies, fully rule-based scoring  
✅ **Section-by-Section Scoring**: Profile, Experience, Education, Skills, Projects (0-100 each)  
✅ **Submission Readiness**: Automatic determination based on score thresholds  
✅ **Categorized Recommendations**: Critical, Important, Suggestions, Strengths  
✅ **Clean Architecture**: Service layer, proper separation of concerns  
✅ **Production Ready**: Comprehensive error handling, logging, audit trails  

## API Endpoints

### 1. CV Analysis

#### GET `/api/v1/cv/analyze/`
Get existing analysis or create new one if none exists.

**Response:**
```json
{
  "success": true,
  "message": "CV analysis retrieved successfully.",
  "data": {
    "id": "uuid",
    "overall_score": 75,
    "profile_score": 80,
    "experience_score": 85,
    "education_score": 70,
    "skills_score": 75,
    "projects_score": 65,
    "grade": "B",
    "is_submission_ready": true,
    "recommendations": {
      "critical": [],
      "important": [
        "Add more detailed project descriptions (100+ words)",
        "Include specific metrics and achievements"
      ],
      "suggestions": [
        "Consider adding GitHub or portfolio link",
        "Add recent projects to show current skills"
      ],
      "strengths": [
        "Excellent experience section - well detailed and comprehensive"
      ]
    },
    "total_issues": 3,
    "critical_issues": 0,
    "total_recommendations": 4,
    "analyzed_at": "2024-01-15T10:30:00Z",
    "last_updated": "2024-01-15T10:30:00Z"
  }
}
```

#### POST `/api/v1/cv/analyze/`
Force new analysis regardless of existing results.

**Response:** Same as GET, but always performs fresh analysis.

### 2. CV Score Summary

#### GET `/api/v1/cv/score/`
Get detailed score breakdown and summary.

**Response:**
```json
{
  "success": true,
  "message": "CV score retrieved successfully.",
  "data": {
    "analysis_available": true,
    "analysis_id": "uuid",
    "overall_score": 75,
    "grade": "B",
    "is_submission_ready": true,
    "score_breakdown": {
      "profile": 80,
      "experience": 85,
      "education": 70,
      "skills": 75,
      "projects": 65
    },
    "summary": {
      "total_issues": 3,
      "critical_issues": 0,
      "total_recommendations": 4
    },
    "recommendations": {
      "critical": [],
      "important": ["..."],
      "suggestions": ["..."],
      "strengths": ["..."]
    },
    "analysis_date": "2024-01-15T10:30:00Z",
    "last_updated": "2024-01-15T10:30:00Z"
  }
}
```

### 3. Intelligence Dashboard

#### GET `/api/v1/cv/dashboard/`
Get comprehensive dashboard overview.

**Response:**
```json
{
  "success": true,
  "message": "CV intelligence dashboard data retrieved successfully.",
  "data": {
    "analysis_available": true,
    "overall_score": 75,
    "grade": "B",
    "pending_suggestions": 0,
    "pending_issues": 0,
    "last_updated": "2024-01-15T10:30:00Z"
  }
}
```

## Scoring Algorithm Details

### Overall Score Calculation
```
Overall Score = (Profile × 25%) + (Experience × 25%) + (Education × 20%) + (Skills × 15%) + (Projects × 15%)
```

### Section Scoring Breakdown

#### Profile Section (0-100 points)
- **Contact Information (40 points)**
  - Phone: 10 points
  - City: 10 points  
  - Country: 10 points
  - Address: 10 points
- **Professional Summary (30 points)**
  - Length (20+ words): 25 points
  - Quality content: 5 points
- **Online Presence (20 points)**
  - LinkedIn: 10 points
  - GitHub/Portfolio: 10 points
- **Photo (10 points)**
  - Professional photo: 10 points

#### Experience Section (0-100 points)
- **Basic Presence (30 points)**
  - At least one experience entry
- **Multiple Entries (30 points)**
  - 2+ entries: 15 points
  - 3+ entries: additional 15 points
- **Quality & Duration (40 points)**
  - Total experience duration
  - Detailed descriptions (100+ words each)
  - Quantified achievements

#### Education Section (0-100 points)
- **Basic Information (60 points)**
  - Degree, institution, field of study
- **Additional Details (40 points)**
  - GPA (if ≥3.5): 10 points
  - Description/coursework: 10 points
  - Multiple entries: 20 points

#### Skills Section (0-100 points)
- **Quantity (80 points)**
  - 2-4 skills: 30 points
  - 5-8 skills: 60 points
  - 8+ skills: 80 points
- **Quality (20 points)**
  - Category diversity: 10 points
  - Advanced/Expert levels: 10 points

#### Projects Section (0-100 points)
- **Basic Presence (40 points)**
  - At least one project
- **Multiple Projects (30 points)**
  - 2+ projects: 20 points
  - 3+ projects: 30 points
- **Quality Indicators (30 points)**
  - Detailed descriptions: 15 points
  - Project links: 15 points

## Submission Readiness Criteria

A CV is considered "submission ready" when:
- Overall score ≥ 70%
- Profile score ≥ 60%
- Experience score ≥ 60%
- Education score ≥ 60%
- Skills score ≥ 60%
- Projects score ≥ 50%

## Recommendation Categories

### Critical Issues
- Missing essential sections (experience, education)
- Missing contact information
- Empty or severely inadequate content

### Important Improvements
- Weak language in descriptions
- Missing quantification
- Insufficient detail in key sections

### Suggestions
- Optional enhancements
- Additional content ideas
- Formatting improvements

### Strengths
- Well-performing sections (score ≥ 90%)
- Comprehensive content areas

## Error Handling

All endpoints return consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "error": {
    "message": "Detailed error message",
    "details": {}
  }
}
```

Common error scenarios:
- **404**: CV profile not found
- **401**: Authentication required
- **500**: Internal server error during analysis

## Authentication

All endpoints require JWT authentication:
```
Authorization: Bearer <jwt_token>
```

## Rate Limiting

- Anonymous users: 20 requests/hour
- Authenticated users: 200 requests/hour
- Analysis endpoints: 10 requests/hour

## Usage Examples

### Basic Analysis Flow
```javascript
// 1. Get or create analysis
const analysis = await fetch('/api/v1/cv/analyze/', {
  headers: { 'Authorization': `Bearer ${token}` }
});

// 2. Check if submission ready
if (analysis.data.is_submission_ready) {
  console.log('CV is ready for submission!');
} else {
  console.log('Improvements needed:', analysis.data.recommendations.critical);
}

// 3. Force refresh after CV updates
const refreshed = await fetch('/api/v1/cv/analyze/', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${token}` }
});
```

### Dashboard Integration
```javascript
// Get dashboard overview
const dashboard = await fetch('/api/v1/cv/dashboard/', {
  headers: { 'Authorization': `Bearer ${token}` }
});

// Display score with grade
console.log(`CV Score: ${dashboard.data.overall_score}% (${dashboard.data.grade})`);
```

## Implementation Notes

- **Deterministic**: Same CV content always produces same scores
- **No External Dependencies**: Pure algorithmic analysis
- **Scalable**: Efficient database queries with proper indexing
- **Auditable**: All analysis actions logged for compliance
- **Extensible**: Easy to add new scoring criteria or sections

## Database Schema

The system uses the existing `cv_intelligence` app models:
- `CVAnalysis`: Stores analysis results and scores
- `AnalysisIssue`: Individual issues found during analysis
- `ContentRecommendation`: Specific improvement suggestions
- `AnalysisConfiguration`: Configurable scoring parameters