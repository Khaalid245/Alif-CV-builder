from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from .review_service import ResumeReviewService
from .review_models import ReviewResultSerializer
from apps.cv.models import CVProfile
from apps.cv.serializers import CVProfileSerializer

class ResumeReviewView(APIView):
    """
    API Endpoint for analyzing Resume Health.
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        """
        Expects a CVProfile ID to analyze.
        """
        cv_id = request.data.get('cv_id')
        if not cv_id:
            # Optionally fallback to checking body data directly if not persisted,
            # but usually it's persisted first. If full payload is sent:
            raw_data = request.data
        else:
            try:
                # Security: ensure user owns the CV
                cv = CVProfile.objects.get(id=cv_id, student=request.user)
                # Serialize completely to mimic the raw input dict
                raw_data = CVProfileSerializer(cv).data
            except CVProfile.DoesNotExist:
                return Response({"error": "CV not found."}, status=status.HTTP_404_NOT_FOUND)

        # Separate Business Logic into the Service Layer
        service = ResumeReviewService()
        review_result = service.analyze(raw_data)
        
        # Serialize Response
        serializer = ReviewResultSerializer(review_result)
        return Response(serializer.data, status=status.HTTP_200_OK)
