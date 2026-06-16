from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.cv.models import CVProfile
from apps.cv.serializers import CVProfileSerializer
from .match_service import CareerMatchService
from .match_models import CareerMatchResultSerializer

class CareerMatchView(APIView):
    """
    API Endpoint for Career Match Intelligence.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        """
        Expects a CVProfile ID and a Job Description text.
        """
        cv_id = request.data.get('cv_id')
        job_description = request.data.get('job_description', '')

        if not job_description:
            return Response({"error": "Job description is required."}, status=status.HTTP_400_BAD_REQUEST)

        if not cv_id:
            raw_data = request.data.get('cv_data')
            if not raw_data:
                return Response({"error": "Either cv_id or cv_data is required."}, status=status.HTTP_400_BAD_REQUEST)
        else:
            try:
                cv = CVProfile.objects.get(id=cv_id, student=request.user)
                raw_data = CVProfileSerializer(cv).data
            except CVProfile.DoesNotExist:
                return Response({"error": "CV not found."}, status=status.HTTP_404_NOT_FOUND)

        # Separate Business Logic into the Service Layer
        service = CareerMatchService()
        match_result = service.analyze(raw_data, job_description)

        # Serialize Response
        serializer = CareerMatchResultSerializer(match_result)
        return Response(serializer.data, status=status.HTTP_200_OK)
