"""
Serializers for the pdf_generator app.
"""
from rest_framework import serializers
from apps.cv.models import GeneratedCV


class GeneratedCVSerializer(serializers.ModelSerializer):
    """
    Serializes a GeneratedCV record for API responses.
    Includes a constructed download URL for Flutter to use directly.
    """
    template_display = serializers.CharField(source='get_template_display', read_only=True)
    download_url     = serializers.SerializerMethodField()

    class Meta:
        model  = GeneratedCV
        fields = [
            'id', 'template', 'template_display',
            'download_url', 'file_size', 'download_count', 'generated_at',
        ]
        read_only_fields = fields

    def get_download_url(self, obj) -> str:
        """Constructs the API download URL for this generated CV."""
        request = self.context.get('request')
        url = f'/api/v1/cv/download/{obj.id}/'
        if request:
            return request.build_absolute_uri(url)
        return url
